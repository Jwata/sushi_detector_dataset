#!/usr/bin/env ruby

require 'csv'
require 'open-uri'
require 'open_uri_redirections'
require 'uri'

# dev
require 'looksee'
require 'pry-byebug'

def main(csv_file, sushi_type)
  CSV.foreach(csv_file, headers: :first_row) do |row|
    save_image(row, sushi_type)
  end
end

def save_image(row, sushi_type)
  href = row['href']
  img_url = URI::decode_www_form(URI.parse(href).query).to_h['imgurl']

  puts img_url
  image_data = open(img_url, allow_redirections: :all).read
  image_ext = '.jpg'
  image_hash = Digest::MD5.hexdigest(image_data)

  open("data/images/#{sushi_type}_#{image_hash}#{image_ext}", 'w') do |file|
    file << image_data
    file.close
  end
rescue => _e
  puts _e
end

csv_file = ARGV[0]
sushi_type = File.basename(csv_file).split('.').first.split('_').first

main(csv_file, sushi_type)
