# Implementation of MythicAPI Interface 

require_relative "MythicAPI_UI"
require_relative "RaiderAPI"
require_relative "MythicDB"
require_relative "MythicObjects"

# require_relative "Blizzard.rb" -- Not used atm

class MythicAPI < MythicAPI_UI

  def initialize
    super
    # init a DB connection as
    # it should be up for any use
    @db = MythicDB.new

    ## init a character pool
    @char_pool = CharCache.new

    # init APIs
    @raid = RaiderIO_API.new
    #@bilz = nil - Not Used ATM

    # These should be lazily instantiated
    @name = nil
    @realm = nil
    @region = nil
  end

  # Override Functions with Implementations

  # region is not used for now as only US is supported
  # so we're making it optional
  def MythicRating(name, realm, region="us")
    char = MythicInit(name, realm)
    rating = char.getRating

    # get data remotely and parse
    if !rating
      data = @raid.getCharacterData(name, realm, region)
      rating = data["mythic_plus_scores_by_season"][0]["scores"]["all"]
      char.setRating(rating)
    end

    return DataError(name, realm) if !rating
    return rating
  end

  def MythicRuns(name, realm, region=nil)
    MythicInit(name, realm)
    return DataError(name, realm)
  end

  # lets do a pseudo chain-of responsibilty pattern here
  # call handlers for each type of rank:
  # - World Rank (RaiderIO)
  # - Server Rank (RaiderIO)
  # - App Rank (DB) 
  # that way if we add more types of ranks like guild
  # we can add handlers in the future
  def MythicRank(type, name, realm, region=nil)
    MythicInit(name, realm)
    return DataError(name, realm)
  end

  # Facade interface - Additional Options
  def WorldRank(name, realm, region=nil)
    return MythicRank("World", name, realm)
  end

  def ServerRank(name, realm, region=nil)
    return MythicRank("Server", name, realm) 
  end

  def AppRank(name, realm, region=nil)
    return MythicRank("App", name, realm)
  end

  # any future public additions here

  private
  # Formats the error as discord bot would expect it
  #
  # @params name [String] name of character
  # @params realm [String] realm of character
  def DataError(name, realm)
    return "No Data Found For Player #{name}-#{realm}"
  end

  # returns a character object from the pool
  # (see #CharCache)
  def MythicInit(name, realm, region="us")
    return @char_pool.getChar(name, realm, region)
  end

  def MythicRank_World(rank)
    #stub
    if rank.include?("World")
      return "World Stub"
    end
    return MythicRank_Server(rank)
  end

  def MythicRank_Server(rank)
    #stub
    if rank.include?("Server")
      return "Server Stub"
    end
    return MythicRank_App(rank)
  end

  # expects instance vars: @name, @realm 
  # to be set - this is on the caller
  def MythicRank_App(rank)
    if rank.include?("App")
      out = @db.get_app_rank(@name, @realm)
      return nil if !out
      return out
    end
    # Keep adding more types of ranks
    # exit with error
    return nil
  end

end
