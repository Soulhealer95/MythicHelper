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

require_relative "RaiderAPI"
require_relative "MythicDB"
require_relative "parser"
require 'discordrb'


class MythicBot
  def initialize()
    confobj = GetConfig.new(self)
    config = confobj.getconf
    @token = config["token"]
    @bot = Discordrb::Commands::CommandBot.new token: @token, prefix: '!'
    @db = MythicDB.new
    setupCommands()
    @bot.run
  end
  def setupCommands
    # M+ Rating
    @bot.command(:rating,  min_args: 2, max_args: 2, description: 'Get your Mythic+ Rating.', usage: 'rating [charactername] [realm]') do |_event, username, realm|
      rating = UpdateRating(username, realm)
      return "No Rating Found" if !rating
      return rating
    end

    # Best Runs
    @bot.command(:runs,  min_args: 2, max_args: 2, description: 'Get your M+ Runs', usage: 'runs [charactername] [realm]') do |_event, username, realm|
      raid = RaiderAPI.new(username, realm)
      return PrettyPrintRuns(raid.MythicRuns)
    end

    # Next Best
    @bot.command(:nextbest,  min_args: 2, max_args: 2, description: 'Best Dungeon to Run Next', usage: 'nextbest [charactername] [realm]') do |_event, username, realm|
      raid = RaiderAPI.new(username, realm)
      return NextBest(raid)
    end

    # App Rating
    @bot.command(:apprank,  min_args: 2, max_args: 2, description: 'Server Ranking among Bot Users', usage: 'apprank [charactername] [realm]') do |_event, username, realm|
      if UpdateRating(username, realm)
        rank = @db.get_app_rank(username, realm)
      else
        rank = "No Rating Found"
      end
      return rank
    end


  end

  private
  def UpdateRating(username, realm)
      raid = RaiderAPI.new(username,realm)
      rating = raid.MythicRating
      if rating
        @db.add_rating(username, realm, rating)
        return rating
      end
      return nil
  end
  def NextBest(raid)
    min = [999, ""]

    affix = (raid.MythicCurrAffixes)[0].to_s
    data = raid.MythicRuns

    data.each do |key, val|
      if val[affix][0] == 0
        min[0] = "Any level"
        min[1] = key
        break
      end

      if val[affix][0] < min[0]
        min[0] = val[affix][0]
        min[1] = key
      end

    end
    out = min[1] + " - "
    if min[0] == "Any level"
      out = out + min[0] 
    else
      out = out + (data[min[1]][affix][1] + 1).to_s
    end
    return out
  end

  def PrettyPrintRuns(data)
    return "No Data Found!" if !data || data == []
    str = ""
    data.each do |key, val|
      str = str +  "#{key}:\nFortified (#{'%02d' % val["Fortified"][1]}) #{'%06.2f' % val["Fortified"][0]}   | |    Tyrannical (#{'%02d' % val["Tyrannical"][1]}) #{'%06.2f' % val["Tyrannical"][0]}\n"
    end
    return str
  end

end

MythicBot.new
