require "rubygems"
require "bundler"
Bundler.require :default, (ENV["RACK_ENV"] || "development").to_sym

set :views, -> { root }

TITLE = "Pairicon"

get "/" do
  @title = TITLE
  slim :index
end
