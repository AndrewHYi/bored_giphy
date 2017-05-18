require "yaml"
require "httparty"

class Giphy

  API_KEY = "***REMOVED***"
  BASE_URL = "http://api.giphy.com/v1/gifs"

  def self.search(*words)
    search_words = words.join("+")
    json = HTTParty.get("#{BASE_URL}/search?api_key=#{API_KEY}&q=#{search_words}").parsed_response
  end

  def self.rando(*words)
    self.search(*words).fetch("data", []).sample['images'].fetch('fixed_height', {}).fetch('url', '')
  rescue
    nil
  end

end


class StoryMaker
  HTML_REPLACE_TEXT_STRING = "<%= STORY_MAKER_REPLACE_ME %>"
  MAX_WORD_GROUP_SIZE = 4 # search at most 4 words in giphy
  attr_accessor :text

  def initialize(demo: false, filepath: nil)
    @text = if demo
      YAML.load_file("./examples.yml").fetch("examples").sample
    else
      File.open(filepath) { |f| f.read }
    end
  end

  def compile!
    template_html = File.open("./template.html", "r") { |f| f.read }
    story_contents_html = ""

    text_array = @text.split(" ")
    until text_array.length == 0 do
      word_groups = text_array.shift(rand(MAX_WORD_GROUP_SIZE) + 1)
      giphy_url = Giphy.rando(word_groups)

      story_contents_html << if should_gen_giphy && giphy_url
       %Q[
          <div class="giphy-box">
            <div class="giphy-title">#{word_groups.join(' ')}</div>
            <img src='#{giphy_url}' class='giphy' />
          </div>
        ]
      else # HTML
        "<span>#{word_groups.join(' ')}</span> "
      end
    end

    template_html.sub!(HTML_REPLACE_TEXT_STRING, story_contents_html)

    Dir.mkdir "compiled" rescue nil
    File.open("./compiled/index.html", "w") { |f| f.write template_html }
    `open ./compiled/index.html`
  end

  private
  def should_gen_giphy # chance we dont generate it and just gen html instead
    return rand(9) < 3 # 30% chance of true
  end

end
