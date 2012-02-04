# tendrilio.rb
require 'rubygems'
require 'sinatra'

get '/' do
  @title = "Tendrilio"
  erb :index, :layout => :layout
end

get '/auth' do
  
end
