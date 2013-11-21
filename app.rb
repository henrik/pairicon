require "rubygems"
require "bundler"
Bundler.require :default, (ENV["RACK_ENV"] || "development").to_sym

require_relative "icon"

set :views, -> { root }

TITLE = "Pairicon"
MAX = 4

get "/" do
  render_with_names params[:name]
end

get %r{/(\w+(?:\+\w+)+)\.png\z} do |names|
  names = clean_names(names.split("+"))
  url = icon_url_from_names(names)
  redirect to(url)
end

get %r{/(\w+(?:\+\w+)+)} do |names|
  render_with_names names.split("+")
end

def render_with_names(names)
  @title = TITLE
  @names = clean_names(names)
  @url = icon_url_from_names(@names)
  slim :index
end

def icon_url_from_names(names)
  if names.length > 1
    Icon.new(*names).url
  else
    nil
  end
end

def clean_names(raw_names)
  Array(raw_names).reject(&:empty?).first(MAX)
end
