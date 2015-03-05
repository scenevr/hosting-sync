#!/usr/bin/ruby

require 'restclient'
require 'pathname'

user = ENV['U']
password = ENV['P']
HOST = "scenevr.hosting"
ALLOWED_EXTENSIONS = %w/png jpg gif mp3 mp4 ogg obj xml js mtl/

if !user
  puts "Usage: U=ben P=password #{$0}"
  puts ""
  puts "  WARNING! This script deletes everything in your scenevr.hosting folder, and uploads"
  puts "  the content of the working directory.\n\n"
  exit
end

puts "Deleting everything.."

RestClient::Request.new(
  :method => :get,
  :url => "http://#{HOST}/uploads/delete_all",
  :user => user,
  :password => password,
).execute

puts "Naive upload..."

Dir.glob("./**/*").each do |f|
  next if Pathname.new(f).directory?

  extension = File.extname(f).sub(/^./,'')

  next unless (ALLOWED_EXTENSIONS.find { |e| e == extension })

  puts " * " + f

  request = RestClient::Request.new(
    :method => :post,
    :url => "http://#{HOST}/uploads/",
    :user => user,
    :password => password,
    :payload => {
      :multipart => true,
      :upl => File.new(f, 'rb'),
      :relative_path => Pathname.new(f).dirname.to_s + "/"
  })      

  puts "   * " + request.execute
end

puts "Restarting..."

request = RestClient::Request.new(
  :method => :get,
  :url => "http://#{HOST}/uploads/restart",
  :user => user,
  :password => password,
).execute

puts "Done."