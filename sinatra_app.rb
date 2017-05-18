require "sinatra"
require_relative "lib/meat"

class SinatraApp < Sinatra::Base
  get "/" do
    erb :index
  end

  post "/process" do
    s = StoryMaker.new(text: params[:text], save_to_file: false)
    @html = s.compile!
  end
end