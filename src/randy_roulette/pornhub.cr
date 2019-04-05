require "crystagiri"

module PornHub
  URL = "https://www.pornhub.com"
  CATEGORY_URL = "https://www.pornhub.com/categories"

  MAX_PER_PAGE_0 = 32
  MAX_PER_PAGE = 44

  def self.get_categories 
    doc = Crystagiri::HTML.from_url CATEGORY_URL
    categories = {} of String => String

    doc.where_class("js-mxp") do |category_html|
      categories[category_html.content.split("\n")[0]] = category_html.node["href"]
    end
    categories
  end

  def self.get_max_videos(category_url)
    max = 0
    doc = Crystagiri::HTML.from_url(URL + category_url)
    doc.where_class("showingCounter") {|t| max = t.content.split("of ")[1].to_i }
    max
  end

  def self.get_video(category_url, video_number)
    page_number = 0
    video_number_on_page = 0

    # page 0 on every category only has 32 entries instead of 44 on every other page
    if video_number < MAX_PER_PAGE_0
      video_number_on_page = video_number
      page_number = 0
    else
      page_number = (video_number-MAX_PER_PAGE_0) / MAX_PER_PAGE
      video_number_on_page = (video_number-MAX_PER_PAGE_0) % MAX_PER_PAGE
    end
    
    page_url = URL + category_url + (page_number == 0 ? "" : "&page=#{page_number}")

    doc = Crystagiri::HTML.from_url(page_url)
    videos_html = doc.at_id("videoCategory")
    videos = [] of String
    if videos_html
      video_search = Crystagiri::HTML.new(videos_html.node.to_s)
      video_search.where_class("title") do |t|
        videos << t.node.children[1]["href"]
      end
    end
    videos[video_number_on_page]
  end
end