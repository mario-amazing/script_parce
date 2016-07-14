require 'curb'
require 'nokogiri'
require 'csv'

module GoodsPrice
  class ParserUrl
    SITE_URL_FORMAT = 'http://www.viovet.co.uk/%s'
    HTTP = "http:"

    def initialize(args)
      @path = args[:category_path]
      @file_name = args[:file_name]
    end

    def find_goods
      content = Curl::Easy.new(format(SITE_URL_FORMAT, @path))
      content.follow_location = true
      content.perform
      html= Nokogiri::HTML(content.body_str)
      good_name = html.xpath(".//*[@id='product_family_heading']").text
      goods = []
      html.xpath(".//*[@id='product_listing']/li/div[1]/div").to_a.each_with_index do |elem, i|
        full_name = "#{good_name} #{elem.text.strip}"
        cost = html.xpath(".//*[@id='product_listing']/li/div[2]/div[2]/span/span").to_a[i].text
        image = HTTP + html.xpath(".//*[@id='product_listing']/li/div[1]/ul/li[1]/a")[i].attr("href")
        delivery = html.xpath(".//*[@id='product_listing']/li/div[1]/strong").to_a[i].text.strip
        good_code = html.xpath(".//*[@id='product_listing']/li/div[1]/ul/li[2]/a/strong").to_a[i].text
        goods << { full_name: full_name, cost: cost, image: image, delivery: delivery,
                   good_code: good_code}
      end
      goods
    end

    def to_csv
      goods = find_goods
      all_keys = %w{full_name cost image delivery good_code}
      CSV.open("#{@file_name}.csv", "wb") do |csv|
        goods.each_with_index do |good, i|
          csv << ["#{i+1})"]
          all_keys.each do |key|
            csv << ["#{key} : #{good[:"#{key}"]}"]
          end
        end
      end
    end
  end
end


