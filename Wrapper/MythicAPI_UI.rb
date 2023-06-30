# One stop shop for all Mythic related Data
# Defines the interface to expect 
#

class MythicAPI_UI
  def initialize
    #stub
  end

  public
  def MythicRating(name, realm, region)
    #stub
  end

  def MythicRuns(name, realm, region)
    #stub
  end

  def MythicRank(type, name, realm, region)
    #stub
  end
  # any future public additions here

  private
  def MythicInit(name, realm, region)
    # stub to activate any external classes
    # probably don't want to expose this
  end
  # any future private additions here

end
