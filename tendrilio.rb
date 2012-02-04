# tendrilio.rb
require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

get '/' do
  @title = "Tendrilio"
  erb :index, :layout => :layout
end

get '/configure' do
  erb :configure
end

get '/request' do
  response = Twilio::TwiML::Response.new do |r|
    r.Redirect 'http://tendrilio.herokuapp.com/smstest'
  end
  puts response.text

end

get '/smstest' do
  # Twilio credentials
  account_sid = ENV['TWILIO_SID']
  auth_token = ENV['TWILIO_TOKEN']
  caller_id = ENV['TWILIO_CALLER_ID']
  
  # set up a client to talk to the Twilio REST API
  @client = Twilio::REST::Client.new account_sid, auth_token
  
  @client.account.sms.messages.create(
    :from => caller_id,
    :to => '+19546090220',
    :body => 'Hey there!'
  )
  
  redirect('/')
end