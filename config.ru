require 'rubygems'
require 'bundler'
require 'date'
require 'time'

Bundler.require

FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new("log/sinatra.log", "a")
$stdout.reopen(log)
$stderr.reopen(log)

require './surf'
run Surf
