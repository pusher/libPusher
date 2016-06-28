require 'rubygems'
require 'sinatra'
require 'pusher'
require 'json'
require 'uuid'

# auth_credentials.rb needs to be created or values set in ENV
auth_creds_file_path = File.join(File.dirname(__FILE__), *%w[auth_credentials.rb])

if File.exists?(auth_creds_file_path)
  load auth_creds_file_path
else
  Pusher.app_id = ENV['PUSHER_APP_ID']
  Pusher.key = ENV['PUSHER_APP_KEY']
  Pusher.secret = ENV['PUSHER_APP_SECRET']
end

$uuid = UUID.new

module Pusher
  AVAILABLE_USERS = [
    {:user_id => $uuid.generate.to_s, :user_info => {:name => "User 1", :email => "user1@example.com"}},
    {:user_id => $uuid.generate.to_s, :user_info => {:name => "User 2", :email => "user2@example.com"}},
    {:user_id => $uuid.generate.to_s, :user_info => {:name => "User 3", :email => "user3@example.com"}},
    {:user_id => $uuid.generate.to_s, :user_info => {:name => "User 4", :email => "user4@example.com"}},
    {:user_id => $uuid.generate.to_s, :user_info => {:name => "User 5", :email => "user5@example.com"}}
  ].freeze

  def self.users
    @users ||= AVAILABLE_USERS.dup
  end

  def self.reset_users
    @users = AVAILABLE_USERS.dup
  end

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

    post "/private/slowauth" do
      puts ">> Authenticating private channel:#{params[:channel_name]} socket:#{params[:socket_id]}"
      response = Pusher[params[:channel_name]].authenticate(params[:socket_id])
      sleep(1)
      [200, {"Content-Type" => "application/json"}, response.to_json]
    end

    post "/presence/auth" do
      puts ">> Authenticating presence channel:#{params[:channel_name]} socket:#{params[:socket_id]}"

      if (user = Pusher.users.pop)
        puts ">> Authenticated (#{Pusher.users.length} users remaining)"

        response = Pusher[params[:channel_name]].authenticate(params[:socket_id], user)
        [200, {"Content-Type" => "application/json"}, response.to_json]
      else
        puts ">> Authentication failed, no users available."

        [403, {'Content-Type' => "text/plain"}, "Not authorized"]
      end
    end

    post "/reset" do
      puts ">> Users reset."
      Pusher.reset_users
      [200, {}, "OK"]
    end
  end
end
