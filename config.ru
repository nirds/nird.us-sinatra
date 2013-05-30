require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'split/dashboard'

Bundler.require

require "./app/app"

config = YAML.load(File.read("secrets.yml"))[:split_dashboard]
Split::Dashboard.use Rack::Auth::Basic do |username, password|
  username == config[:username] && password == config[:password]
end

run Rack::URLMap.new \
  "/"                => NirdApp.new,
  "/split_dashboard" => Split::Dashboard.new
