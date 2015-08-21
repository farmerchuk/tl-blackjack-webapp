require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'my_secret'


get "/welcome" do
  erb :welcome
end

get "/redirect" do
  redirect "/welcome"
end

get "/alt_profile" do
  erb :"alt_views/alt_profile"
end

post "/profile" do
  erb :profile
end
