require_relative "RaiderAPI"
require_relative "mythicdb"
require_relative "DBAPI"
require 'discordrb'


class MythicBot
  def initialize(token)
    @token = token
    @bot = Discordrb::Commands::CommandBot.new token: @token, prefix: '!'
    @db = mythicdb.new
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
    str = ""
    data.each do |key, val|
      str = str +  "#{key}:\nFortified (#{'%02d' % val["Fortified"][1]}) #{'%06.2f' % val["Fortified"][0]}   | |    Tyrannical (#{'%02d' % val["Tyrannical"][1]}) #{'%06.2f' % val["Tyrannical"][0]}\n"
    end
    return str
  end

end


token = 'MTExMzYyOTY0NjA5ODAxNDMxOQ.GkhUBS.gmLHkY8rcXpansiDY5R468o99s36BNmekjDVJo'
MythicBot.new(token)


=begin
realm = "Sargeras"
#username= "Brewaholic"
username= "ixys"
realm = "Frostmourne"
username = "Zyyna"

raid = RaiderAPI.new(username, realm)
#puts PrettyPrintRuns(raid.MythicRuns)
#data = raid.MythicRuns
puts NextBest(raid)



#puts data["keystone_affixes"]
#File.write("log.txt", out)
bliz = BlizzardAPI.new(username, realm)

puts "Summary for " + username
puts "M+ Rating:" + raid.MythicRating.to_s
puts "Dungeons Run..."
for dung in raid.AllRuns
  puts dung
end
puts "Realm: " + realm + " ID: " + bliz.getRealmID.to_s

out = bliz.getRealmInfo()
elem =  JSON.parse(out.body)

puts elem
=end

#db = MythicDB.new
#puts db.get_app_rank("shiv", realm)
#stmt = "CREATE TABLE mythic_rank (rank int,name varchar(255), realm varchar(255), rating int)"
#out = db.create_table("mythic", ["rank%v", "rating%i"])
#out = db.insert_table_c("mythic_rank", {"rank" => "103", "name" => username, "realm" => realm, "rating" => "666"})
#out = db.insert_table_v("mythic_rank", ["103", username, realm, "666"])
#out = db.update_table_by_field("mythic_rank", {"name" => username}, {"rating" => 154, "rank" => 1000, "realm" => "'Sargeras'"})
#out = db.delete_field("mythic_rank", {"name" => username})
#out = db.get_field("mythic_rank", ["rating"], {"name" => "'#{username}'"})
#db.insert_table_c("mythic_rank", {"rank" => "103", "name" => "'" + username + "'", "realm" => "'" + realm +"'", "rating" => "666"})
#out = db.get_field("mythic_rank", nil, {"name" => "'ixys'", "realm" => "'Sargeras'"})
#out = db.get_field("mythic_rank", nil, {"name" => "'ixys'"})
#puts out
