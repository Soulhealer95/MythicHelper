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


require 'oauth2'
require_relative "BlizzardAPI_UI"
require_relative '../General/config_parser'
require_relative 'blizzard_api_index'
require_relative '../General/Request'

include Blizzard_Links


# Implementation of BlizzardAPI
class BlizzardAPI < BlizzardAPI_UI
  def initialize
    @request = Request.new()

    # Oauth Config
    configobj = GetConfig.new(self)
    config = configobj.getconf
    @key = config["key"]
    @secret = config["secret"]
    @callback_url = "http://127.0.0.1:3000"
    @token = nil
    @client = nil

    # start connection
    init_connection
  end

  #public methods
  # Game Data APIs
  # Affixes
  # returns id for each affix as a hash
  def AffixIndex
    url = BAPI[:affix_index] 
    params = {"namespace" => "static-us"}

    res = oauth_call(url,params)
    return nil if !res

    # if everything went ok, 
    # return array of affixes
    out = {}
    for aff in res["affixes"]
      out[aff["name"]] = aff["id"]
    end
    return out
  end

  def AffixInfo(id)
    url = BAPI[:affix_info].gsub "{keystoneAffixId}", id.to_s
    params = {"namespace" => "static-us"}

    return oauth_call(url,params)
  end

  def AffixMedia(id)
    # affix info gets all data, including media
    # so we'll piggy back on that
    res = AffixInfo(id)
    if res
      media_url = res["media"]["key"]["href"]
      data = oauth_follow(media_url)
      return data["assets"] if !data
      return nil
    end
  end

  # Dungeons
  def DungeonIndex
    url = BAPI[:dungeon_index] 
    res = oauth_call(url)
    return nil if !res
    # if everything went ok, 
    # return array of affixes
    out = {}
    for dun in res["dungeons"]
      out[dun["name"]] = dun["id"]
    end
    return out
  end

  def DungeonInfo(id)
    url = BAPI[:dungeon_info].gsub "{dungeonId}", id.to_s
    return oauth_call(url)
  end

  # returns an index of all periods along with current period
  def KeystonePeriodIndex
    url = BAPI[:period_index] 
    res = oauth_call(url)
    return res if !res
    out = {}
    out["current"] = res["current_period"]["id"]
    out["all"] = res
    return out
  end

  def KeystonePeriodInfo(id)
    url = BAPI[:period_info].gsub "{periodId}", id.to_s
    return oauth_call(url)
  end

  # returns an index of all seasons along with current season
  def KeystoneSeasonIndex
    url = BAPI[:season_index] 
    res = oauth_call(url)
    return res if !res
    out = {}
    out["current"] = res["current_season"]["id"]
    out["all"] = res["seasons"]
    return out
  end

  def KeystoneSeasonInfo(id)
    url = BAPI[:season_info].gsub "{seasonId}", id.to_s
    return oauth_call(url)
  end

  # Additional APIs
  #
  # Provides a list of all dungeons in current season
  # Note: Very Slow - Best to Cache
  def CurrentDungeons
    dungeons = DungeonIndex()
    out = []
    dungeons.each do |key, val|
      out.push(key) if DungeonInfo(val)["is_tracked"]
    end
    return out
  end

  # More APIs Here
  # Profile APIs are being provided by RaiderIO
  # but could be added here as well
  #

  private
  # setters
  def init_connection
    init_client()
    init_token()
  end

  def init_client
    @client = OAuth2::Client.new(@key, @secret, {
      :site                 =>  BAPI[:auth_url],
      :scheme               =>  :header,
      :http_method          =>  :post,
      :token_url            =>  "/token",
      :authorize_url       =>  "/authorize",
      debug_output: true,
      :body_hash_enabled    =>  false

    })
  end

  def init_token
    @token = @client.client_credentials.get_token(redirect_uri: @callback_url) if !@token
  end

  # Override headers and params as needed or just pass data_url
  def oauth_call(data_url, params={}, headers={})
    default_params={"namespace" => 'dynamic-us', ":region" => "us", "locale" => "en_US"}
    use_params = default_params.merge(params)
    init_token
    url = BAPI[:api_url] + data_url
    out = @request.get_with_token(url,@token.token,use_params,headers)
    return nil if out["code"]
    return out
  end

  def oauth_follow(url)
    init_token
    out = @request.get_with_token(url,@token.token)
    return nil if out["code"]
    return out
  end

end
