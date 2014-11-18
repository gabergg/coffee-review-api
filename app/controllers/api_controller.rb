class ApiController < ApplicationController
  before_filter :parse_request

  def parse_request
    @json = JSON.parse(request.body.read)
  end

end