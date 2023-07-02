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

require_relative 'MythicAPI'
require 'discordrb'

# Discord Bot using Mythic API
class MythicBot
  def initialize()
    confobj = GetConfig.new(self)
    config = confobj.getconf
    @token = config["token"]
    @bot = Discordrb::Commands::CommandBot.new token: @token, prefix: '!'

    #init mythic commands
    @mythic_api = MythicAPI.new
    setupCommands()

    # run bots
    @bot.run
  end
  
  # set up various commands using discordrb wrapper
  # Supported commands:
  #   - rating    - M+ Helper
  #   - runs      - M+ Runs
  #   - nextbest  - Best Dungeon to run next (Suggestion)
  #   - apprank   - Rank among app users
  #   - rank      - Overall world rank
  def setupCommands
    # M+ Rating
    @bot.command(:rating,  min_args: 2, max_args: 2, description: 'Get your Mythic+ Rating.', usage: 'rating [charactername] [realm]') do |_event, username, realm|
      rating = @mythic_api.MythicRating(username, realm)
      return rating
    end

    # Best Runs
    @bot.command(:runs,  min_args: 2, max_args: 2, description: 'Get your M+ Runs', usage: 'runs [charactername] [realm]') do |_event, username, realm|
      runs = @mythic_api.MythicRuns(username, realm)
      return PrettyPrintRuns(runs)
    end

    # Next Best
    @bot.command(:nextbest,  min_args: 2, max_args: 2, description: 'Best Dungeon to Run Next', usage: 'nextbest [charactername] [realm]') do |_event, username, realm|
      runs = @mythic_api.MythicRuns(username, realm)
      return NextBest(runs)
    end

    # App Rank
    @bot.command(:apprank,  min_args: 2, max_args: 2, description: 'Ranking among Bot Users', usage: 'apprank [charactername] [realm]') do |_event, username, realm|
      return @mythic_api.MythicRank("app", username, realm)
    end

    # World Rank
    @bot.command(:rank,  min_args: 2, max_args: 2, description: 'World Ranking', usage: 'rank [charactername] [realm]') do |_event, username, realm|
      return @mythic_api.MythicRank("world", username, realm)
    end

  end

  private
  # Parse data and get next best dungeon
  #
  # @parse data [MythicRuns] Runs data from Mythic Character Object
  # @return out [String] Dungeon - Level 
  def NextBest(data)
    min = [ 999, ""]
    affix = @mythic_api.instance_variable_get(:@weekly_affix)
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
      out = out + (data[min[1]][affix][0] + 1).to_s
    end
    return out
  end

  # Print Runs data 
  #
  # @parse data [MythicRuns] Runs data from Mythic Character Object
  # @return out [String] Dungeon and affix data printed
  def PrettyPrintRuns(data)
    return "No Data Found!" if !data || data == []
    str = ""
    data.each do |key, val|
      str = str +  "#{key}:\nFortified (#{'%02d' % val["Fortified"][1]}) "
      str = str + "#{'%06.2f' % val["Fortified"][0]}   | |    Tyrannical (#{'%02d' % val["Tyrannical"][1]}) #{'%06.2f' % val["Tyrannical"][0]}\n"
    end
    return str
  end

end

# Start the Bot instance
MythicBot.new
