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


require_relative 'RaiderAPI_UI'

# Indexed API URLs and Params
require_relative 'raiderio_api_index'
include RaiderIO_Links


# Implementation for M+ RaiderIO API
class RaiderIO_API < RaiderAPI_UI

  # Initializes most of the defaults for M+
  #
  # @param [nil] None
  # @return [nil] None
  def initialize
    @region = "us" 
    @locale = "en_US"
    @expansion = 9 # This would have to be updated
    @mythic_fields = RFLDS[:all]
    @site_url = RAPI[:api_url]
    super
  end

  # Gets all data pertaining to a character 
  #
  # @param name [String] the name of character
  # @param realm [String] the realm of character
  # @param region [String] the region of realm 
  # @param fields [String] comma seperated fields to request
  # @return data [JSON, nil] the JSON formatted data from GET request or nil
  def getCharacterData(name, realm, region=@region, fields=@mythic_fields)
    # replacement map
    map = { "{name}" => name, "{realm}" => realm, 
            "{region}" => region, "{fields}" => fields }
    # form URL
    char_url = @site_url + RAPI[:char_info]
    map.each do | key, val|
      char_url = char_url.gsub(key, val)
    end

    # Get Data
    return getData(char_url)
  end

  # Gets all the periods including current period
  #
  # @param nil [nil] None 
  # @return data [JSON, nil] the JSON formatted data from GET request or nil
  def getPeriod
    per_url = @site_url + RAPI[:periods]
    return getData(per_url)
  end

  # Gets all data pertaining to affixes in current season
  #
  # @param region [String] the region of realm 
  # @param locale [String] locale for data. "en_US" is default
  # @return data [JSON, nil] the JSON formatted data from GET request or nil
  def getAffix(region=@region, locale=@locale)
    map = { "{region}" => region, "{locale}" => locale }
    aff_url = @site_url + RAPI[:affixes]
    map.each do | key, val |
      aff_url = aff_url.gsub(key, val)
    end
    return getData(aff_url)
  end

  # Gets all static data pertaining to current season: slugs, dungeons etc.
  #
  # @param expansion_id [Int] the expansion id, current is set in initialize
  # @return data [JSON, nil] the JSON formatted data from GET request or nil
  def getStatic(expansion_id=@expansion)
    static_url = @site_url + RAPI[:mythic_static]
    static_url = static_url.gsub("{expansionID}", expansion_id.to_s) 
    return getData(static_url)
  end

end
