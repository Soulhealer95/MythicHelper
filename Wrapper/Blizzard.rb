require 'oauth2'

require_relative "Request"
require_relative 'blizzard_api_index'
require_relative 'parser'
include Blizzard_Links

class BlizzardAPI < Request

  def initialize(name, realm)
    configobj = GetConfig.new(self)
    config = configobj.getconf
    super # @name, @realm, get_with_token
    @key = config["key"]
    @secret = config["secret"]
    @callback_url = "http://127.0.0.1:3000"
    @token = nil
    @realm_id = nil
    @realm_slug = nil
    @client = nil

    init_connection()

  end

  # setters
  def init_connection
    init_client()
    init_token()
    init_realm()
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

  def init_realm
    if @realm_id || @realm_slug
      return
    end

    init_token()
    out = get_with_token(BAPI[:api_url] + BAPI[:realm_index],
                         @token.token,
                         {},
                         {"namespace": 'dynamic-us' })
    obj = JSON.parse(out.body)
    for i in  obj["realms"]
      if i["name"]["en_US"] == @realm
        @realm_id = i["id"]
        @realm_slug = i["slug"]
      end
    end
  end


  # getters
  def getRealmID
    init_realm if !@realm_id
    return @realm_id
  end
  def getRealmSlug
    init_realm if !@realm_slug
    return @realm_slug
  end

  def getMythicLeaderboard()
    id = 206 # Nelth lair
    period = 912
    # keystone_id has a variable passed in URL which has to be subbed with original
    leaderboard_url = BAPI[:keystone_lead].gsub '{realm_id}', @realm_id.to_s
    leaderboard_url = leaderboard_url + id.to_s + "/period/" + period.to_s
    # puts leaderboard_url
    out = get_with_token(BAPI[:api_url] + leaderboard_url,
                         @token.token,
                         {},
                         {"namespace": 'dynamic-us' })
    return out
  end

  def follow_link(url)
    out = get_with_token(url,
                         @token.token,
                         {},
                         {})
    return out
  end

  def getProfile(username)
    profile_link = BAPI[:char_profile].gsub "{realm_slug}", @realm_slug
    profile_link = profile_link.gsub "{characterName}", username
    out = get_with_token(BAPI[:api_url] + profile_link,
                         @token.token,
                         {},
                         {"namespace": 'profile-us' })
    return out
  end

  def getRealmInfo
    realm_link = BAPI[:realm_info].gsub "{realm_slug}", @realm_slug
    out = get_with_token(BAPI[:api_url] + realm_link,
                         @token.token,
                         {},
                         {"namespace": 'dynamic-us' })
    return out
  end
  def getMythicProfile(username)
    profile_link = BAPI[:mythic_profile].gsub "{realm_slug}", @realm_slug
    profile_link = profile_link.gsub "{characterName}", username
    out = get_with_token(BAPI[:api_url] + profile_link,
                         @token.token,
                         {},
                         {"namespace": 'profile-us' })
    return out

  end

end
