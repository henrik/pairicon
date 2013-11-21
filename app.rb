require "rubygems"
require "bundler"
Bundler.require :default, (ENV["RACK_ENV"] || "development").to_sym

require_relative "icon"

set :views, -> { root }

TITLE = "Pairicon"
MAX = 4

get "/" do
  with_names params[:name]
end

get %r{/(\w+(?:\+\w+)+)} do |names|
  with_names names.split("+")
end

def with_names(names)
  @title = TITLE
  @names = Array(names).reject(&:empty?).first(MAX)
  @url = Icon.new(*@names).url if @names.length > 1
  slim :index
end
