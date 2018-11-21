#! /usr/bin/env ruby

DIR = File.absolute_path('.apod')
URL = 'https://apod.nasa.gov/apod'.freeze

Dir.mkdir(DIR) unless Dir.exists?(DIR)

list = `curl -sSL -XGET #{URL}/archivepix.html 2>/dev/null | head -n200`

downloaded = 0

list.scan(/(\d{4})\s+([A-Z][a-z]+)\s+(\d+)\s*:\s+\<a\s+href="([^"]+)"/).each_with_index do |m, i|

  break if downloaded == 10

  file = "#{DIR}/#{m[0..2].join('_')}"
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
    `gsettings set org.gnome.desktop.background picture-uri file://#{file}`
  end
end

