require 'rubygems'
require 'sinatra'
require 'pusher'
require 'json'

# this needs to be created
load File.join(File.dirname(__FILE__), *%w[auth_credentials.rb])

module Pusher
  class FakeAuthServer < Sinatra::Base
    use Rack::Auth::Basic, 'Restricted' do |username, password|
      [username, password] == ['admin', 'letmein']
    end
    
    get "/" do
      [200, {}, "It works!"]
    end
    
    post "/private/auth" do
      puts ">> Authenticating private channel:#{params[:channel_name]} socket:#{params[:socket_id]}"
      response = Pusher[params[:channel_name]].authenticate(params[:socket_id])
      [200, {"Content-Type" => "application/json"}, response.to_json]
    end
    
    AVAILABLE_USERS = [
      {:user_id => 1, :user_info => {:name => "User 1", :email => "user1@example.com"}},
      {:user_id => 2, :user_info => {:name => "User 2", :email => "user2@example.com"}},
      {:user_id => 3, :user_info => {:name => "User 3", :email => "user3@example.com"}},
      {:user_id => 4, :user_info => {:name => "User 4", :email => "user4@example.com"}},
      {:user_id => 5, :user_info => {:name => "User 5", :email => "user5@example.com"}}
    ]
    
    post "/presence/auth" do
      puts ">> Authenticating presence channel:#{params[:channel_name]} socket:#{params[:socket_id]}"
      
      if (user = AVAILABLE_USERS.pop)
        response = Pusher[params[:channel_name]].authenticate(params[:socket_id], user)
        [200, {"Content-Type" => "application/json"}, response.to_json]
      else
        [403, {'Content-Type' => "text/plain"}, "Not authorized"]
      end
    end
  end
end
