#! /usr/bin/env ruby

require 'json'

REMEMBERME = ENV['COOKIE']

res = `curl -sSL -XPOST https://www.codingame.com/services/Puzzle/findAllMinimalProgress -H 'Content-Type: application/json' -d '[2802859]' --cookie "rememberMe=#{REMEMBERME}"`

res = JSON.parse(res)

levels = res.map { |r| r['level'] }.uniq

r = {}
c = {}
ids = []

levels.each do |l|
  problems = res.select do |problem|
    problem['level'] == l && problem['validatorScore'] < 100
  end
  c[l] = {
    total: res.count { |p| p['level'] == l },
    unsolved: problems.size,
  }
  c[l][:solved] = c[l][:total] - c[l][:unsolved]
  r[l] = problems
  ids += problems.sort_by { |p| p['solvedCount'] }.last(5).map { |p| p['id'] }
  ids += problems.sort_by { |p| p['creationTime'] }.last(5).map { |p| p['id'] }
end
ids.uniq!

res = `curl -sSL -XPOST https://www.codingame.com/services/Puzzle/findProgressByIds -H 'Content-Type: application/json' -d '#{JSON.dump([ids, 2802859, 2])}' --cookie "rememberMe=#{REMEMBERME}"`

res = JSON.parse(res)

def formatted(pb)
  pb['title'][0..27].ljust(30) +
    pb['solvedCount'].to_s.rjust(6) + "  " +
    "https://www.codingame.com#{pb['detailsPageUrl']}"
end


c.keys.sort_by { |l| -c[l][:unsolved] }.each do |l|
  problems = r[l]
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
