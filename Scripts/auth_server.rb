require 'rubygems'
require 'sinatra'
require 'pusher'
require 'json'

# this needs to be created
load File.join(File.dirname(__FILE__), *%w[auth_credentials.rb])

module Pusher
  class FakeAuthServer < Sinatra::Base
    get "/" do
      [200, {}, "It works!"]
    end
    
    post "/pusher/auth" do
      puts ">> Authenticating channel:#{params[:channel_name]} socket:#{params[:socket_id]}"
      response = Pusher[params[:channel_name]].authenticate(params[:socket_id])
      puts ">> Response: #{response.inspect}"
      [200, {"Content-Type" => "application/json"}, response.to_json]
    end
  end
end
