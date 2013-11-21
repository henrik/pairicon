require "rubygems"
require "bundler"
Bundler.require :default, (ENV["RACK_ENV"] || "development").to_sym

require_relative "icon"

set :views, -> { root }

TITLE = "Pairicon"
MAX = 4

get "/" do
  @title = TITLE
  @names = params[:name].reject(&:empty?).first(MAX)
  @url = Icon.new(*@names).url
  slim :index
end
