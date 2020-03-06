#! /usr/bin/env ruby

require 'json'
require 'set'

REMEMBERME = ENV['COOKIE']
USER_ID = 2802859

def request(method: 'POST', endpoint: nil, data: nil)
  req = [
    'curl',
    '-sSL',
    '-X', method,
    endpoint,
    '-H', '"Content-Type: application/json"',
    '-d', JSON.dump(data),
    '--cookie', "'rememberMe=#{REMEMBERME}'",
  ].join(' ')
  JSON.parse(`#{req}`)
end

def formatted(pb)
  pb['title'][0..27].ljust(30) +
    pb['solvedCount'].to_s.rjust(6) + "  " +
    "https://www.codingame.com#{pb['detailsPageUrl']}"
end

def by_language(all_problems)
  easiest = all_problems.select { |p| p['level'] == 'easy' || p['level'] == 'tutorial' }.sort_by { |p| p['solvedCount'] }.last(20).reverse

  progress = request(
    endpoint: 'https://www.codingame.com/services/Puzzle/findProgressByIds',
    data: [easiest.map { |p| p['id'] }, USER_ID, 2],
  )
  by_language = Hash.new { |h, k| h[k] = Set.new() }
  progress.each do |pb|
    submissions = request(
      endpoint: 'https://www.codingame.com/services/TestSessionQuestionSubmission/findAllSubmissions',
      data: [pb['testSessionHandle']],
    )
    submissions.each do |submission|
      next unless submission['score'] == 100
      by_language[submission['programmingLanguageId']] << pb['id']
    end
  end

  by_language.each do |lang, solved|
    next if solved.size >= 15
    next_up = easiest.select { |pb| !solved.include?(pb['id']) }.map { |pb| pb['id'] }
    next_up = next_up.map { |id| progress.find { |pb| pb['id'] == id } }
    puts "#{lang.ljust(15)} (#{solved.size}):"
    next_up.first(5).each { |pb| puts "\t#{formatted(pb)}" }
  end
end


all_problems = request(
  endpoint: 'https://www.codingame.com/services/Puzzle/findAllMinimalProgress',
  data: [USER_ID],
)

if (ARGV.include?('--lang'))
  by_language(all_problems)
  exit 0
end

levels = all_problems.map { |r| r['level'] }.uniq

unsolved = {}
c = {}
ids = []

levels.each do |l|
  problems = all_problems.select do |problem|
    problem['level'] == l && problem['validatorScore'] < 100
  end
  c[l] = {
    total: all_problems.count { |p| p['level'] == l },
    unsolved: problems.size,
  }
  c[l][:solved] = c[l][:total] - c[l][:unsolved]
  unsolved[l] = problems
  ids += problems.sort_by { |p| p['solvedCount'] }.last(5).map { |p| p['id'] }
  ids += problems.sort_by { |p| p['creationTime'] }.last(5).map { |p| p['id'] }
end
ids.uniq!

res = request(
  endpoint: 'https://www.codingame.com/services/Puzzle/findProgressByIds',
  data: [ids, USER_ID, 2],
)

c.keys.sort_by { |l| -c[l][:unsolved] }.each do |l|
  problems = unsolved[l]
  next if l == 'optim' || l == 'multi'
  next if problems.empty?

  solved_percent = (100 * c[l][:solved] / c[l][:total]).round
  puts "\n#{l}\t\t#{solved_percent}% solved\t#{c[l][:unsolved]} / #{c[l][:total]} left\n\n"
  problems.sort_by { |p| p['solvedCount'] }.last(5).reverse_each do |problem|
    pb = res.find { |e| e['id'] == problem['id'] }
    puts formatted(pb)
  end

  puts "\n\tNewest:"
  problems.sort_by { |p| p['creationTime'] }.last(5).reverse_each do |problem|
    pb = res.find { |e| e['id'] == problem['id'] }
    puts "\t#{formatted(pb)}"
  end
end
