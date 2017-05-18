require "sinatra"
require_relative "lib/meat"

class SinatraApp < Sinatra::Base

  CHAR_LIMIT = 10_000

  get "/" do
    erb :index
  end

  post "/process" do
    s = StoryMaker.new(text: params[:text].to_s[0..CHAR_LIMIT], save_to_file: false)
    @html = s.compile!
  end
end