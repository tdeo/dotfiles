#! /usr/bin/env ruby

require 'json'

SESSION = ENV['SESSION']

res = `curl -sSL -XPOST https://www.codingame.com/services/Puzzle/findAllMinimalProgress -H 'Content-Type: application/json' -d '[2802859]' --cookie "cgSession=#{SESSION}"`

res = JSON.parse(res)

levels = res.map { |r| r['level'] }.uniq

r = {}

levels.each do |l|
  problems = res.select { |r| r['level'] == l && r['validatorScore'] < 100 }
  r[l] = problems.sort_by { |p| p['solvedCount'] }.reverse.first(5).map { |p| p['id'] }
end

res = `curl -sSL -XPOST https://www.codingame.com/services/Puzzle/findProgressByIds -H 'Content-Type: application/json' -d '#{JSON.dump([r.values.flatten, 2802859, 2])}' --cookie "cgSession=#{SESSION}"`

res = JSON.parse(res)

r.each do |l, ids|
  puts "\n" + l
  ids.each do |id|
    pb = res.find { |e| e['id'] == id }
    puts "#{pb['title'][0..27].ljust(30)} #{pb['solvedCount'].to_s.rjust(6)} #{pb['validatorScore']} https://www.codingame.com#{pb['detailsPageUrl']}"
  end
end
