require "sinatra"
require "securerandom"
require "redis"
require_relative "lib/meat"

class SinatraApp < Sinatra::Base

  CHAR_LIMIT = 10_000
  REDIS_SHARELINK_NAMESPACE = "sharelink:"
  REDIS_SHARELINK_EXPIRES_IN_SECS = 600 # 10 minutes

  $redis = if ENV["RACK_ENV"] == "production"
    Redis.new(url: ENV["REDIS_URL"])
  else
    Redis.new
  end

  get "/" do
    erb :index
  end

  get "/a/:uuid" do
    if(html = get_sharelink(uuid: params[:uuid]))
      html
    else
      "Generated content '#{params[:uuid]}' doesn't exist or has expired mate!"
    end
  end

  post "/process" do
    s = StoryMaker.new(text: params[:text].to_s[0..CHAR_LIMIT], save_to_file: false)
    uuid = SecureRandom.uuid
    html = s.compile!
    set_sharelink(uuid: uuid, html: html)
    redirect "/a/#{uuid}"
  end

  private
  def get_sharelink(uuid:)
    redis_key = "#{REDIS_SHARELINK_NAMESPACE}uuid"
    $redis.get(redis_key)
  end

  def set_sharelink(uuid:, html:)
    redis_key = "#{REDIS_SHARELINK_NAMESPACE}uuid"
    $redis.set(redis_key, html)
    $redis.expire(redis_key, REDIS_SHARELINK_EXPIRES_IN_SECS)
  end

end