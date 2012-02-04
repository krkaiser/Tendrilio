# tendrilio.rb
require 'rubygems'
require 'sinatra'
require 'twilio-ruby'
require 'open-uri'

get '/' do
  @title = "Tendrilio"
  erb :index, :layout => :layout
end

get '/configure' do
  erb :configure
end

get '/tendril' do
  tendril_token = ENV['TENDRIL_TOKEN']
  
  open("http://dev.tendrilinc.com/connect/account/63/pricing/schedule;from=2011-12-30T00:00:00-0000;to=2011-12-31T00:00:00-0000",
      'Accept' => 'application/json',
      'Content-Type' => 'application/json', 
      'Access_Token' => tendril_token ) { |f|
          return f.read
        }
end

post '/request' do
  # Twilio credentials
  account_sid = ENV['TWILIO_SID']
  auth_token = ENV['TWILIO_TOKEN']
  caller_id = ENV['TWILIO_CALLER_ID']
  
  # set up a client to talk to the Twilio REST API
  @client = Twilio::REST::Client.new account_sid, auth_token
  
  message = ""
  
  @client.account.sms.messages.create(
    :from => caller_id,
    :to => '+19546090220',
    :body => message
  )
  
  response = Twilio::TwiML::Response.new do |r|
    r.Redirect 'http://tendrilio.herokuapp.com/smstest'
  end
  puts response.text
end