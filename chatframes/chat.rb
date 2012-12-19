# coding: utf-8
require 'sinatra'
set server: 'thin', connections: []

$users_connected = []

get '/' do	
  if params[:user]
    $users_connected << params[:user] unless $users_connected.include?(params[:user])
  end
  halt erb(:login) unless params[:user]
  erb :chat, locals: { user: params[:user].gsub(/\W/, '') }
end

get '/stream', provides: 'text/event-stream' do
  stream :keep_open do |out|    
    settings.connections << out
    out.callback { settings.connections.delete(out) }
  end  
end

get '/users' do
  erb :users, :layout => false
end

post '/' do
  settings.connections.each do |out| 
    out << "data: #{params[:msg]}\n\n" 
  end
  204 # response without entity body
end
