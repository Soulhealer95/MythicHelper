require 'uri'
require 'net/http'
require 'json'
require 'httpparty'

$debug = nil

# TO simplify everything, I created a request class to perform all API calls
# these can be extended to work with various APIs
class Request
  def initialize(name, realm)
    @name = name
    @realm = realm
  end

  # Given a URL, make a GET call to retrieve the data
  # returns JSON object
  private
  def getData(url)
    uri = URI(url)
    res = Net::HTTP.get_response(uri)
    return ParseData(res)

  end
  # Given a URL and list of 'x' => 'y' fields, make a POST call to retrieve the data
  # returns JSON object
  def postData(url, params)
    uri = URI(url)
    res = Net::HTTP.post_form(uri, params)
    return ParseData(res)
  end

  def ParseData(response)
    if response.is_a?(Net::HTTPSuccess)
      out = JSON.parse(response.body)
      return out
    end
    puts "Couldn't get Data!" + response.body
    return
  end

  def get_with_token(url, token, header={}, params= {})
    def_header = {'Authorization'=> "Bearer #{token}"}
    def_query = {:namespace => "static-us", :region => 'us'}

    headers = def_header.merge(header)
    query = def_query.merge(params)

    if $debug
      resp = HTTParty.get(url, query: query, headers: headers, debug_output: $stdout)
    else
      resp = HTTParty.get(url, query: query, headers: headers)
    end
    return resp
  end

end