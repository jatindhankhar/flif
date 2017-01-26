require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'jwt'
require 'data_mapper'
require 'giphy'
require_relative 'launcher.rb'

$FLIF_APP_ID = ENV['FLIF_APP_ID']

# Setting some constraints
set :public_folder, 'public'
#set :protection, :except => [:http_origin]
#use Rack::Protection::HttpOrigin, :origin_whitelist => ['https://web.flock.co']
set :protection, :except => :frame_options

# Confiuring Corssing Origin and Datamapper
configure do
	enable :cross_origin
	DataMapper.setup :default ,"sqlite://#{Dir.pwd}/database.db"
end

class User
	include DataMapper::Resource
	property :id, Serial
	property :userId, String
	property :token, String
end

DataMapper.finalize.auto_upgrade!

def decode_token token
	JWT.decode(token,nil,false).first["appId"]
end

def verified? decoded_token
	$FLIF_APP_ID == decoded_token
end

def parse_body body
  JSON.parse body.read
end

def respond_to_slash_command response
	puts "Name is #{response["userName"]}"
	puts "userId  is #{response["chat"]}"
	puts response
end

get '/' do
	"Hello World"
end

post '/events' do
	response =  parse_body request.body
	puts response
	case response["name"]
	when "app.install"
		@user = User.new(userId: response["userId"],token: response["token"])
		@user.save!
	when "app.uninstall"
		User.first(userId: response["userId"]).destroy
	else
	   puts "Unknown event #{response["name"]} :  #{response}"
	end
	status 200
end

get '/events' do
	puts params
	status 200
	"Events"
end

get  '/test' do
	  puts request.env['rack.request.query_hash']
 unless  params['flockEventToken'] and params['flockEvent']
	 "Flock Exclusive App Only"
	 halt 200
 end

 if verified?(decode_token(params["flockEventToken"]))
	puts "Verified Token"
        @flockEvent = JSON.parse params['flockEvent']
        search_text = @flockEvent['text'].strip
        if search_text.empty?
	# If no text string passed, show top 25 from trending list
        @gifs = Giphy.trending(limit: 25)
        else
	 @gifs = Giphy.search(search_text,{limit: 25})
	end
     #  File.read(File.join('public', 'flock.html'))
	@userId = "35"
        erb :index
  else
	@error = "Sorry this app works with Flock Only"
 end

end

post '/send' do
   payload = parse_body request.body
   puts payload
 #  byebug
  token =  User.first(userId: payload['data']['user_id']).token
   puts token
   if token.nil?
	{"error" => "Not such user", "status" => "failure"}.to_json
   else
	send_attachments payload['data']["gif_list"],payload["data"]["chat_id"],token
        {"status" => "success"}.to_json
   end
end
