class ApiController < ApplicationController

  require 'nokogiri'
  require 'open-uri'

  BASE_URL_FIRST = 'http://www.coffeereview.com/page/'
  BASE_URL_SECOND = '/?post_type=review&s='

  def parse_params

    @search_term = params['term']
    search_by_term

    json_result = search_by_term

    render :json => json_result, :status => :ok

  end

  def search_by_term
    @page_count = 1
    @json_return = {}

    @page = Nokogiri::HTML(open(BASE_URL_FIRST + @page_count.to_s + BASE_URL_SECOND + @search_term))

    #No reviews were found => return empty

    if @page.at('h3:contains("No reviews were found")')
      return {}.to_json
    end


    while true

      @page.css("div.review").each { |review|
        @bean = {}

        @bean[:rating] = review.css("div.review-rating").text.to_i
        @bean[:roaster] = review.css("h3").css("a").text
        
        @json_return[review.css("h2").css("a").text] = @bean
      }

      begin
        @page_count = @page_count + 1
        @page = Nokogiri::HTML(open(BASE_URL_FIRST + @page_count.to_s + BASE_URL_SECOND + @search_term))
      rescue OpenURI::HTTPError => e
        if e.message == '404 Not Found'
          break
        else
          raise e
        end
      end

    end


    return @json_return.to_json

  end

end