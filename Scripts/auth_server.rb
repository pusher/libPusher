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
    
    post "/private/auth" do
      puts ">> Authenticating private channel:#{params[:channel_name]} socket:#{params[:socket_id]}"
      response = Pusher[params[:channel_name]].authenticate(params[:socket_id])
      [200, {"Content-Type" => "application/json"}, response.to_json]
    end
    
    post "/presence/auth" do
      puts ">> Authenticating presence channel:#{params[:channel_name]} socket:#{params[:socket_id]}"
      response = Pusher[params[:channel_name]].authenticate(params[:socket_id], {
        :user_id => 1, 
        :user_info => {:name => "Joe Bloggs", :email => "joebloggs@example.com"}
      })
      [200, {"Content-Type" => "application/json"}, response.to_json]
    end
  end
end
