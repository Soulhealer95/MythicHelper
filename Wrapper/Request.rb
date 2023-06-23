require 'uri'
require 'net/http'
require 'json'


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
    if res.is_a?(Net::HTTPSuccess)
      out = JSON.parse(res.body)
      return out
    end
    puts "Couldn't get Data!"
    return
  end

end