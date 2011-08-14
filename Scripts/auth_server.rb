require 'rubygems'
require 'sinatra'
require 'pusher'

module Pusher
  class FakeAuthServer < Sinatra::Base
    get "/" do
      [200, {}, "It works!"]
    end
    
    post "/pusher/auth" do
      response = Pusher[params[:channel_name]].authenticate(params[:socket_id])
      [200, {"Content-Type" => "application/json"}, response.to_json]
    end
  end
end
