# Implementation of MythicAPI Interface 

require_relative "MythicAPI_UI"
require_relative "RaiderAPI"
require_relative "MythicDB"
# require_relative "Blizzard.rb" -- Not used atm

class MythicAPI < MythicAPI_UI

  def initialize
    super
    # init a DB connection as
    # it should be up for any use
    @db = MythicDB.new

    # These should be lazily instantiated
    @raid = nil
    @bilz = nil
    @name = nil
    @realm = nil
    @region = nil
  end

  # Override Functions with Implementations

  # region is not used for now as only US is supported
  # so we're making it optional
  def MythicRating(name, realm, region=nil)
    MythicInit(name, realm)
    rating = @raid.MythicRating
    # Update Rating in DB whenever anyone uses it
    # To build our DB
    if rating
      @db.add_rating(name, realm, rating)
      return rating
    end
    return DataError(name, realm)
  end

  def MythicRuns(name, realm, region=nil)
    MythicInit(name, realm)
    runs = @raid.MythicRuns
    if runs
      # pretty print runs here perhaps
      # or keep this API as raw as possible and 
      # let client handle the pretty print

      return runs
    end
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
    # these will be needed by any number of handlers 
    # in the same instance so lets instantiate them
    # so we dont have to keep passing them
    @name = name
    @realm = realm
    rank = type
    next_rank = MythicRank_World(rank)
    return next_rank if next_rank
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
  def DataError(name, realm)
    return "No Data Found For Player #{name}-#{realm}"
  end
  def MythicInit(name, realm, region=nil)

    # TODO - do any sanity checks here
    @raid = RaiderAPI.new(name, realm)

    # TODO - do any sanity checks here
    # PS This isn't used atm but
    # might be required in the future, uncomment below at that time
    # @bliz = BlizzardAPI.new(name, realm)
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
