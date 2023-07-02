# create an interface for objects that would need to be passed around
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
   # return time of object creation
  def getCreated
    return @created
  end

  # return rank of type requested
  # currently 3 supported are World, Realm, App
  #
  # @params type [String] type of rank to get
  # @return rank [Int,nil] rank if found or nil
  def getRank(type)
    return @ranks[type] if @rank_types.include? type
    return nil
  end

  # return rating instance variable
  def getRating
    return @rating
  end

  def getRunStatus
    return @runs_set
  end

  def getRankStatus
    return @ranks_set
  end

  # return the value of runs object
  #
  # @params dung_name [String, nil] Name of Dungeon to get
  # @params aff_name [String, nil] Name of Affix to get
  # @retuns runs [Hash] hash of runs for dungeon which match criteria, all if no param is provided
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
  # @params type [String] Supported types are - World, Realm, App
  # @retuns nil [nil] None
  def setRank(type, value)
    @ranks[type] = value
  end

  # update dungeon_list: {dungeon_name => {affix => [ level, rating ]}}
  def setRuns(hash)
    hash.each do | key, val |
      val.each do | aff, data |
        @runs[key][aff] = data
      end
    end
  end

  def setRating(rating)
    @rating = rating
    return
  end

  # after all runs have been provided
  # calculate the runs
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
  # template for dungeon_list: {dungeon_name => [ level, rating ]}
  def emptyRuns()
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

  # template for ranks: { rank_type => value }
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

  def getChar(name, realm, region="us")
    # check if this object is in pool
    obj = fetchObj(name, realm)
    if !obj
      return addObj(name, realm, region)
    end
    return obj
  end

  private
  # add object to the pool
  # object keys in pool are created using name-realm string
  def addObj(name, realm, region)
    pool_obj_name = name + "-" + realm
    obj = MythicChar.new(name, realm, region)
    makeSpace
    @pool[pool_obj_name] = obj
    return obj
  end

  # returns an object currently in the pool
  #
  # @params name [String] name of character
  # @params realm [String] name of realm
  # @returns obj [CharObject, nil] Character object or nil
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
  def makeSpace
    if @pool.length < @limit
      return
    end

    # delete the first one.
    # could make this smarter
    key = @pool.keys
    @pool.delete(key[0])
    return
  end

end

