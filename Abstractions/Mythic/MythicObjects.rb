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
require 'time'

# This info shouldn't change very often
# TODO - Add code to auto-update this every 4 months
module MythicInfo
  # Seasonal things
  SeasonInfo  = {
    :season_id       => "season-df-2",
    :season_dungeons => [
                          "Brackenhide Hollow",
                          "Halls of Infusion",
                          "Neltharus",
                          "The Underrot",
                          "Freehold",
                          "Neltharion's Lair",
                          "The Vortex Pinnacle",
                          "Uldaman: Legacy of Tyr"
                        ],
    :primary_affixes => ["Fortified", "Tyrannical"]
  }
end

# Mythic Character Object
class MythicChar
  include MythicInfo

  def initialize(name, realm, region="us")
    @name = name
    @realm = realm
    @region = region

    # static data
    @rank_types = [ "world" , "realm", "app" ]
    @curr_dungeons = SeasonInfo[:season_dungeons]
    @curr_affixes = SeasonInfo[:primary_affixes]

    # template instantiate
    @runs = emptyRuns()
    @ranks = emptyRanks()
    @runs_set = nil
    @ranks_set = nil
    @rating = nil

    # Track when instance was created
    @created = Time.now
  end

  # getters

  # Get the time of object creation
  def getCreated
    return @created
  end

  # Get the rank of type requested
  # @note currently 3 supported are World, Realm, App
  #
  # @param type [String] type of rank to get
  # @return [Int,nil] rank if found or nil
  def getRank(type)
    return @ranks[type] if @rank_types.include? type
    return nil
  end

  # Get the rating instance variable
  #
  # @return [Int,nil] rating of player if found or nil
  def getRating
    return @rating
  end

  # Tracks if Runs have been set 
  #
  # @return [Bool, nil] value of instance variable runs_set
  def getRunStatus
    return @runs_set
  end


  # Tracks if Ranks have been set 
  # @note - Not currently used just check the ranks directly instead
  #
  # @return [Bool, nil] value of instance variable ranks_set
  def getRankStatus
    return @ranks_set
  end

  # return the value of runs object
  #
  # @param dung_name [String, nil] Name of Dungeon to get
  # @param aff_name [String, nil] Name of Affix to get
  # @return [Hash] hash of runs for dungeon which match criteria, all if no param is provided
  def getRuns(dung_name=nil, aff_name=nil)
    if dung_name || aff_name
      out = nil
      if dung_name && aff_name
        out = @runs[dung_name][aff_name] if (@curr_dungeons.include?(dung_name) && @curr_affixes.include?(aff_name))
      elsif !aff_name
        out = @runs[dung_name] if @curr_dungeons.include? dung_name
      else 
        if @curr_affixes.include?(aff_name)
          out = {}
          for d in @curr_dungeons
            out[d] = @runs[d][aff_name]
          end
        end
      end
      return out
    end
    return @runs
  end

  # update the value of ranks
  #
  # @param type [String] Supported types are - World, Realm, App
  # @return [nil] None
  def setRank(type, value)
    @ranks[type] = value
  end

  # Update the runs object
  # 
  # @param hash [Hash] hash of format "dungeon_name => (affix => [ level, rating ])"
  # @return [nil] None
  def setRuns(hash)
    hash.each do | key, val |
      val.each do | aff, data |
        @runs[key][aff] = data
      end
    end
  end

  # update the value of rating
  #
  # @param rating [Int] a rating value to set
  # @return [nil] None
  def setRating(rating)
    @rating = rating
  end

  # Calculates rating from scores
  # @note higher_affix * 1.5 + lower_affix * 0.5 = rating
  # @note expected to be called manually after runs are set
  def CalculateRuns
    aff = @curr_affixes
    prim = aff[0]
    sec = aff[1]
    score_index = 1
    higher_factor = 1.5
    lower_factor = 0.5
    
    @runs.each do | key, val|
      pval = val[prim][score_index]  
      sval = val[sec][score_index]
      x = (pval - sval)
      if ( x >= 0 )
        @runs[key][prim][score_index] = pval * higher_factor
        @runs[key][sec][score_index] = sval * lower_factor
      else
        @runs[key][prim][score_index] = pval * lower_factor
        @runs[key][sec][score_index] = sval * higher_factor
      end
    end
    @runs_set = true
  end

  private

  # Initialize runs object
  # @note template for dungeon_list: {dungeon_name => [ level, rating ]}
  #
  # @return [RunObj] a zeroed out Runs Object
  def emptyRuns
    runs = {}
    for dungeon_name in @curr_dungeons
      for aff in @curr_affixes
        if runs[dungeon_name]
          runs[dungeon_name] = runs[dungeon_name].merge({ aff => [0,0] })
        else
          runs[dungeon_name] = {aff => [0,0]}
        end
      end
    end
    return runs
  end

  # Initialize ranks object
  # @note template for ranks: '{ rank_type => value }'
  #
  # @return [Hash] Hash of template
  def emptyRanks
    ranks = {}
    for type in @rank_types
      ranks[type] = nil
    end
    return ranks
  end
end



# Template to be used to access, add Character Objects
# Object Pool Pattern
# Have an object pool of characters as a in-memory cache
# expires in 15 minutes. 
# limit to 10 
class CharCache

  def initialize
    # hash of objects 'name-realm' => [ Charobject ]
    @pool = {}
    @limit = 10 # for now
    @max_life = 900 # seconds = 15 minutes
  end

  # Create or fetch a character from the pool
  #
  # @param name [String] name of character
  # @param realm [String] name of realm
  # @param region [String] region of character
  # @return [CharObject] MythicChar object with template
  def getChar(name, realm, region="us")
    # check if this object is in pool
    obj = fetchObj(name, realm)
    if !obj
      return addObj(name, realm, region)
    end
    return obj
  end

  private
  # Add object to the pool
  # @note object keys in pool are created using name-realm string
  # (see #getChar)
  def addObj(name, realm, region)
    pool_obj_name = name + "-" + realm
    obj = MythicChar.new(name, realm, region)
    makeSpace
    @pool[pool_obj_name] = obj
    return obj
  end

  # returns an object currently in the pool
  #
  # @param  name   [String] name of character
  # @param  realm  [String] name of realm
  # @return [CharObject, nil] Character object or nil
  # (see #getChar)
  def fetchObj(name, realm)
    pool_obj_name = name + "-" + realm

    # object must exist and not be stale
    obj = @pool[pool_obj_name]
    if obj && ((Time.now - obj.getCreated) > @max_life)
      obj = nil
    end
    return obj
  end

  # Make space in the pool
  # @note the current criteria is based on capacity and duration
  def makeSpace
    if @pool.length < @limit
      return
    end

    # delete the first one.
    key = @pool.keys
    @pool.delete(key[0])
    return
  end

end

