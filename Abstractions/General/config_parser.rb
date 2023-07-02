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

require 'json'

# Use strategy pattern to find the proper config depending on resource selected
class GetConfig

  def initialize(caller_obj)
    #config
    @conf_dir   = "conf/"
    @conf_oauth = @conf_dir + ".oauthblizzard.conf"
    @conf_disc  = @conf_dir + ".discord.conf"
    @conf_db    = @conf_dir + ".db.conf"


    @type = caller_obj.class.name
    @file = ""

  end

  # get configuration using caller's class name
  # @return [Config] config for a particular type
  def getconf
    conf = nil
    if @type.include?("DB")
      conf = getDBConf()
    elsif @type.include?("Blizzard")
      conf = getBlizzConf()
    elsif @type.include?("Bot")
      conf = getDiscConf()
    else
      puts "Invalid config"
      return conf
    end
  end

  private
  # reads a config file to get the data
  def getfileData
    data = nil
    return data if @file == ""

    @fileobj = File.open(@file, "r")
    data = @fileobj.read()
    return JSON.parse(data)
  end

  # Get DB config
  def getDBConf
    @file = @conf_db
    return getfileData
  end

  # Get Discord Config
  def getDiscConf
    @file = @conf_disc
    return getfileData
  end

  # Get Blizzard OAuth Config
  def getBlizzConf
    @file = @conf_oauth
    return getfileData
  end
end

