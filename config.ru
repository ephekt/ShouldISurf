require 'rubygems'
require 'bundler'
require 'date'
require 'time'

Bundler.require

require "sinatra/reloader" if ENV['MODE'] == "dev"

FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new("log/sinatra.log", "a")
$stdout.reopen(log)
$stderr.reopen(log)

require './surf'
run Surf
