# Use strategy pattern to find the proper config depending on resource selected
#
require 'json'

class GetConfig
  def initialize(caller_obj)
    @type = caller_obj.class.name
    @file = ""

  end

  def getconf
    conf = nil
    if @type.include?("DB")
      conf = getDBConf()
    elsif @type.include?("Blizzard")
      @file = ".oauthblizzard.conf"
      conf = getBlizzConf()
    elsif @type.include?("Bot")
      conf = getDiscConf()
    else
      puts "Invalid config"
      return conf
    end
  end

  private
  def getfileData
    data = nil
    return data if @file == ""

    @fileobj = File.open(@file, "r")
    data = @fileobj.read()
    return JSON.parse(data)
  end

  def getDBConf
    @file = ".db.conf"
    return getfileData
  end

  def getDiscConf
    @file = ".discord.conf"
    return getfileData
  end

  def getBlizzConf
    @file = ".oauthblizzard.conf"
    return getfileData
  end
end

