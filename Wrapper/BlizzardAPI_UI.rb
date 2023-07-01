require_relative 'Request'

class BlizzardAPI_UI < Request
  def initialize
    # get request functions
    super
  end

  #public methods
  # Game Data APIs
  # Affixes
  def AffixIndex
  end

  def AffixInfo(id)
  end

  def AffixMedia(id)
  end

  # Dungeons
  def DungeonIndex
  end

  def DungeonInfo(id)
  end

  def KeystonePeriodIndex
  end

  def KeystonePeriodInfo(id)
  end

  def KeystoneSeasonIndex
  end

  def KeystoneSeasonInfo(id)
  end

  # Extra APIs (Not a direct blizzard link)
  def CurrentDungeons
  end

  # More APIs Here
end
