require 'curb'
require 'nokogiri'
require 'csv'

module GoodsPrice
  class ParserUrl
    HTTP = "http:"

    def initialize(args)
      @path = args[:category_path]
      @file_name = args[:file_name]
    end

    def find_goods
      content = Curl::Easy.new(@path)
      content.follow_location = true
      content.perform
      html= Nokogiri::HTML(content.body_str)
      if html.xpath(".//*[@id='full_search_form']/div/div/div[2]/h2").text == "Refine By:"
        parse_catalog(html)
      else
        parse_good(html)
      end
    end

    def parse_catalog(html)
      goods = []
      html.xpath(".//*[@id='search_result_listings_with_footer_nav']/ul/li/div/div/div[1]/a[1]/h2").to_a.each_with_index do |good_name, y|
        html.xpath(".//*[@id='search_result_listings_with_footer_nav']/ul/li[#{y+1}]/div/div/div[2]/div/div/strong").to_a.each_with_index do |elem, i|
          full_name = "#{good_name.text.strip} #{elem.text.strip}"
          cost = html.xpath(".//*[@id='search_result_listings_with_footer_nav']/ul/li[#{y+1}]/div/div/div[2]/div/div[#{i+1}]/label/strong").text.gsub(/(\n|\t)/, '')
          image = HTTP + html.xpath(".//*[@id='search_result_listings_with_footer_nav']/ul/li[#{y+1}]/a/img").attr("src").text
          delivery = html.xpath(".//*[@id='search_result_listings_with_footer_nav']/ul/li[#{y+1}]/div/div/div[2]/div/div[#{i+1}]/span/strong").text.strip
          good_code = "nil"
          goods << { full_name: full_name, cost: cost, image: image, delivery: delivery,
                     good_code: good_code}
        end
      end
      goods
    end

    def parse_good(html)
      good_name = html.xpath(".//*[@id='product_family_heading']").text
      goods = []
      html.xpath(".//*[@id='product_listing']/li/div[1]/div[1]").to_a.each_with_index do |elem, i|
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


