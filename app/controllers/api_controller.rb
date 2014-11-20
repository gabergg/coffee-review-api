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

    @page = Nokogiri::HTML(open(BASE_URL_FIRST + @page_count.to_s + BASE_URL_SECOND + @search_term))

    #No reviews were found => return empty

    if @page.at('h3:contains("No reviews were found")')
      return {}.to_json
    end


    while true

      begin
        @page_count = @page_count + 1
        @page = Nokogiri::HTML(open(BASE_URL_FIRST + @page_count.to_s + BASE_URL_SECOND + @search_term)) do
          # handle doc
        end
      rescue OpenURI::HTTPError => e
        if e.message == '404 Not Found'
          break
        else
          raise e
        end
      end

    end


    return {:page_numbers => @page_count}.to_json
    
  end

end