require 'sinatra'
require 'sinatra/activerecord'
require 'haml'

set :database, 'sqlite3:///shortened_urls.db'
set :address, 'localhost:4567'

class ShortenedUrl < ActiveRecord::Base
  # Validates whether the value of the specified attributes are unique across the system.
  validates_uniqueness_of :url
  # Validates that the specified attributes are not blank
  validates_presence_of :url
  #validates_format_of :url, :with => /.*/
  validates_format_of :url, 
       :with => %r{^(https?|ftp)://.+}i, 
       :allow_blank => true, 
       :message => "The URL must start with http://, https://, or ftp:// ."
end


get '/' do
  haml :index
end

post '/' do
  custom_error = false
  if (params[:custom] != "") && (ShortenedUrl.find_by_custom(params[:custom]))
    params.update({"custom"=>""})
    custom_error = true
  end
  @long_url = ShortenedUrl.find_or_create_by_url_and_custom(params[:url], params[:custom])
  if @long_url.valid?
    haml :success, :locals => { :address => settings.address, :custom_error => custom_error}
  else
    haml :index
  end
end

post '/search' do
  @url = ShortenedUrl.find_by_url(params[:search_input]) 
  if !@url
    @url = ShortenedUrl.find_by_custom(params[:search_input])
    if !@url
      @url = ShortenedUrl.find_by_id(params[:search_input].to_i)
    end
  end
  haml :search, :locals => { :address => settings.address }
end

get '/show' do
  @urls = ShortenedUrl.find(:all)
  haml :show, :locals => { :address => settings.address }
end
  
get '/:shortened' do
  long_url = ShortenedUrl.find_by_custom(params[:shortened])
  if !long_url
    long_url = ShortenedUrl.find_by_id(params[:shortened].to_i(36))
    if !long_url
      redirect "/"
    end
  end
  redirect long_url.url
end

