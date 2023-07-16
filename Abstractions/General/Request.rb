# Copyright (c) 2023
#     Shivam S. All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
#  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY saxens12@mcmaster.ca “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
#  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
#  IN NO EVENT SHALL saxens12@mcmaster.ca BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
#  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



require 'uri'
require 'net/http'
require 'json'
require 'httpparty'

$debug = nil

# TO simplify everything, I created a request class to perform all API calls
# these can be extended to work with various APIs
class Request

  # Given a URL, make a GET call to retrieve the data
  # returns JSON object
  def get_data(url)
    uri = URI(url)
    res = Net::HTTP.get_response(uri)
    return parse_data(res)

  end
  # Given a URL and list of 'x' => 'y' fields, make a POST call to retrieve the data
  # returns JSON object
  def post_data(url, params)
    uri = URI(url)
    res = Net::HTTP.post_form(uri, params)
    return parse_data(res)
  end

  # Makes OAuth calls 
  def get_with_token(url, token, params={}, header={})
    def_header = {'Authorization'=> "Bearer #{token}"}
    def_query = {}

    headers = def_header.merge(header)
    query = def_query.merge(params)

    if $debug
      resp = HTTParty.get(url, query: query, headers: headers, debug_output: $stdout)
    else
      resp = HTTParty.get(url, query: query, headers: headers)
    end
    return resp
  end

  private
  def parse_data(response)
    if response.is_a?(Net::HTTPSuccess)
      out = JSON.parse(response.body)
      return out
    end
    # This should be error
    puts response.body if $debug
    return nil
  end

end
