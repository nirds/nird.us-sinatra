require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'split/dashboard'

Bundler.require

require "./app/app"

SECRETS = YAML.load(File.read("secrets.yml"))
Split::Dashboard.use Rack::Auth::Basic do |username, password|
  username == SECRETS[:split_dashboard][:username]
  password == SECRETS[:split_dashboard][:password]
end

run Rack::URLMap.new \
  "/"                => NirdApp.new,
  "/split_dashboard" => Split::Dashboard.new
