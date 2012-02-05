# tendrilio.rb
require 'rubygems'
require 'sinatra'
require 'twilio-ruby'
require 'open-uri'
require 'json'
require 'pony'

get '/' do
  @title = "Tendrilio"
  erb :index, :layout => :layout
end

get '/configure' do
  erb :configure
end

get '/pricing' do
  tendril_token = ENV['TENDRIL_TOKEN']
  result = nil
  
  open("http://dev.tendrilinc.com/connect/account/default-account/pricing/schedule;from=2012-02-01T00:00:00-0000;to=2012-03-01T00:00:00-0000",
      'Accept' => 'application/json',
      'Content-Type' => 'application/json', 
      'Access_Token' => tendril_token ) { |f|
          result = JSON.parse(f.read)
        }
   return result['effectivePriceRecords']['effectivePriceRecord'][0]
end

get '/consumption' do
  tendril_token = ENV['TENDRIL_TOKEN']
  result = nil
  
  open("http://dev.tendrilinc.com//connect/user/current-user/account/default-account/consumption/MONTHLY;from=2012-02-01T00:00:00-0000;to=2012-03-01T00:00:00-0000;limit-to-latest=20;include-submetering-devices=false",
      'Accept' => 'application/json',
      'Content-Type' => 'application/json', 
      'Access_Token' => tendril_token ) { |f|
          result = JSON.parse(f.read)
        }
   return result["componentList"]["component"][1][1]
end

get '/prediction' do
  tendril_token = ENV['TENDRIL_TOKEN']
  result = nil
  open("http://dev.tendrilinc.com//connect/user/current-user/account/default-account/consumption/MONTHLY/projection;source=ACTUAL",
      'Accept' => 'application/json',
      'Content-Type' => 'application/json', 
      'Access_Token' => tendril_token ) { |f|
          result = JSON.parse(f.read)
        }
   body result['cost']
end


get '/weather' do
  result = nil
  
   weatherbug_token = ENV['WEATHERBUG_TOKEN']
   open("http://i.wxbug.net/REST/Direct/GetForecast.ashx?zip=#{params[:zip]}&nf=1&c=US&l=en&api_key=#{weatherbug_token}") { |f|
      result = JSON.parse(f.read)
     }
   
   return result
   
end

get '/test' do

end


post '/request' do
  # Twilio credentials
  account_sid = ENV['TWILIO_SID']
  auth_token = ENV['TWILIO_TOKEN']
  caller_id = ENV['TWILIO_CALLER_ID']
  
  smsbody = params['body']
  

  if smsbody == "prediction"
    status, headers, body = call env.merge("PATH_INFO" => '/prediction')
    message = "We estimate your power bill this month will be " + body[0]
  else
    message = "Sorry we dont recognize that request " + smsbody 
  end
  
  # set up a client to talk to the Twilio REST API
  @client = Twilio::REST::Client.new account_sid, auth_token
  
  @client.account.sms.messages.create(
    :from => caller_id,
    :to => '+19546090220',
    :body => message
  )
  
  response = Twilio::TwiML::Response.new do |r|
    r.Redirect 'http://tendrilio.herokuapp.com/'
  end
  puts response.text
end

