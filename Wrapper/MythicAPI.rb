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
    @weekly_affix = nil
    #@bilz = nil - Not Used ATM

    # These should be lazily instantiated
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

      # update local object and database
      char.setRating(rating)
      @db.add_rating(name, realm, rating)
    end

    return DataError(name, realm) if !rating
    return rating
  end

  def MythicRuns(name, realm, region="us")
    char = MythicInit(name, realm)
    if char.getRunStatus
      return char.getRuns
    end

    # parse Mythic Runs
    best = {}
    alt = {}
    data = @raid.getCharacterData(name, realm, region)
    for i in data["mythic_plus_best_runs"]
      best[i["dungeon"]] = {i["affixes"][0]["name"] =>  [i["mythic_level"], i["score"]]}
    end
    for i in data["mythic_plus_alternate_runs"]
      alt[i["dungeon"]] = {i["affixes"][0]["name"] =>  [i["mythic_level"], i["score"]]}
    end

    # update in memory structures
    char.setRuns(best)
    char.setRuns(alt)
    char.CalculateRuns
    return char.getRuns
    
    return DataError(name, realm)
  end

  # lets do a pseudo chain-of responsibilty pattern here
  # call handlers for each type of rank:
  # - world Rank (RaiderIO)
  # - realm Rank (RaiderIO)
  # - app Rank (DB) 
  # that way if we add more types of ranks like guild
  # we can add handlers in the future
  def MythicRank(type, name, realm, region="us")
    char = MythicInit(name, realm)
    out = MythicRank_RaiderIO(char, type)

    return DataError(name, realm) if !out
    return out
  end

  # Facade interface - Additional Options
  def WorldRank(name, realm, region=nil)
    return MythicRank("world", name, realm)
  end

  def ServerRank(name, realm, region=nil)
    return MythicRank("realm", name, realm) 
  end

  def AppRank(name, realm, region=nil)
    return MythicRank("app", name, realm)
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
    # TODO - make this update every week
    if !@weekly_affix 
      @weekly_affix = @raid.getAffix["affix_details"][0]["name"]
    end
    return @char_pool.getChar(name, realm, region)
  end

  def MythicRank_RaiderIO(char, type)
    if type.include?("world") || type.include?("realm")
      if !char.getRank(type)
        name = char.instance_variable_get(:@name)
        realm = char.instance_variable_get(:@realm)
        # get data
        data = @raid.getCharacterData(name, realm)
        ranks = data["mythic_plus_ranks"]["overall"]

        # update internals
        char.setRank("world", ranks["world"])
        char.setRank("realm", ranks["realm"])
      end
      return char.getRank(type)
    end
    return MythicRank_App(char, type)
  end

  # to be set - this is on the caller
  def MythicRank_App(char, type)
    if type.include?("app")
      if !char.getRank(type)
        name = char.instance_variable_get(:@name)
        realm = char.instance_variable_get(:@realm)
        rank = @db.get_app_rank(name, realm)
        
        # update internals
        char.setRank("app", rank)
      end
      return char.getRank(type)
    end
    # Keep adding more types of ranks

    # exit with error
    return nil
  end

end
