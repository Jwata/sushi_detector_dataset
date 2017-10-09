#!/usr/bin/env ruby

require 'csv'
require 'open-uri'
require 'base64'

# dev
require 'looksee'
require 'pry-byebug'

DATA_URI_REGEXP =  /^data:([-\w]+\/[-\w\+\.]+)?;base64,(.*)/m
URL_REGEXP = /https?:\/\/[\S]+/

def main(csv_file, sushi_type)
  id = 0
  CSV.foreach(csv_file, headers: :first_row) do |row|
    id += 1
    save_image(row, sushi_type, id)
  end
end

def save_image(row, sushi_type, id)
  _href, src, _name = row.values_at('href', 'src', 'name')
  puts src
  image_data = if match = DATA_URI_REGEXP.match(src)
    Base64.decode64(match[2])
  elsif URL_REGEXP =~ src
    open(src).read
  end

  if image_data
    open("data/images/#{sushi_type}_#{id}.jpg", 'w') do |file|
      file << image_data
      file.close
    end
  end
rescue => _e
  puts _e
end

csv_file = ARGV[0]
sushi_type = File.basename(csv_file).split('.').first.split('_').first

main(csv_file, sushi_type)
