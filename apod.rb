#! /usr/bin/ruby

require 'pathname'
require 'logger'

LOGGER = Logger.new('/tmp/apod.log')

DIR = Pathname.new(File.absolute_path(__dir__)).join('.apod').to_s
URL = 'https://apod.nasa.gov/apod'.freeze

def puts(message)
  LOGGER.info(message)
  Kernel.puts message
end

Dir.mkdir(DIR) unless Dir.exists?(DIR)

list = `curl -sSL -XGET #{URL}/archivepix.html 2>/dev/null | head -n 1000`.force_encoding('ISO-8859-1').encode('UTF-8')

limit = ARGV[0].to_s =~ /\d+/ ? ARGV[0].to_i : 1

downloaded = 0

list.scan(/(\d{4})\s+([A-Z][a-z]+)\s+(\d+)\s*:\s+\<a\s+href="([^"]+)"/).each_with_index do |m, i|

  break if downloaded >= limit

  file = "#{DIR}/#{m[0..2].join('_')}"
  next if system("[ -f #{file}\.* ]")

  page = `curl -sSL -XGET #{URL}/#{m[3]} 2>/dev/null`.force_encoding('ISO-8859-1').encode('UTF-8')

  img = page.match(%r{<a\s+href="(image/[^"]+)"})

  if img.nil?
    puts "Skipping #{m[0..2].join('_')}, no link found."
    next
  else
    img = img[1]
  end

  file += ".#{img.split('.')[-1]}"

  img_url = "#{URL}/#{img}"

  unless File.exists?(file)
    puts "Downloading #{img_url} into #{file}"
    tmp_file = "/tmp/apod_image"
    `curl -sSL -o #{tmp_file} #{img_url} 2>/dev/null && mv #{tmp_file} #{file}`
    downloaded += 1
  end

  if i == 0
    puts "Setting #{file} as background"
    `cp #{file} /home/thierry/.apod/latest`
  end
end

