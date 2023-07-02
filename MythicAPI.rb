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


require_relative "Abstractions/RaiderIO/RaiderAPI"
require_relative "Abstractions/Mythic/MythicAPI_UI"
require_relative "Abstractions/Mythic/MythicDB"
require_relative "Abstractions/Mythic/MythicObjects"
# require_relative "Blizzard.rb" -- Not used atm

# Implementation of MythicAPI Interface 
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

  # Get a Character's M+ Rating
  #
  # @param  name    [String] name of character
  # @param  realm   [String] name of realm
  # @param  region  [String] name of region, default to 'us'
  # @return [Int] Rank of the Character
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

  # Get runs for a character
  #
  # @param   name    [String] name of character
  # @param   realm   [String] name of realm
  # @param   region  [String] name of region, default to 'us'
  # @return  [CharRuns] Character runs object
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

  # Gets a rank for a character
  # @note a chain-of responsibilty pattern here
  # calls handlers for each type of rank:
  # - world Rank (RaiderIO)
  # - realm Rank (RaiderIO)
  # - app Rank (DB) 
  # that way if we add more types of ranks like guild
  # we can add handlers in the future
  #
  # @param  type    [String] type of rank requested
  # @param  name    [String] name of character
  # @param  realm   [String] name of realm
  # @param  region  [String] name of region, default to 'us'
  # @return [Int] Rank of the Character
  def MythicRank(type, name, realm, region="us")
    char = MythicInit(name, realm)
    out = MythicRank_RaiderIO(char, type)

    return DataError(name, realm) if !out
    return out
  end
  # any future public additions here

  private
  # Formats the error as discord bot would expect it
  #
  # @param  name  [String] name of character
  # @param  realm [String] realm of character
  def DataError(name, realm)
    return "No Data Found For Player #{name}-#{realm}"
  end

  # Init M+ information
  # set weekly_affix if not set
  #
  # @param  name    [String] name of character
  # @param  realm   [String] name of realm for character
  # @param  region  [String] name of region, default to 'us'
  # @return [CharObject] a character object from the pool
  def MythicInit(name, realm, region="us")
    # TODO - make this update every week
    if !@weekly_affix 
      @weekly_affix = @raid.getAffix["affix_details"][0]["name"]
    end
    return @char_pool.getChar(name, realm, region)
  end

  # Handlers for Rank chain of responsibilty pattern
  # (see #MythicRank)
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

  # Handlers for Rank chain of responsibilty pattern
  # (see #MythicRank)
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
