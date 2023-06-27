require_relative "RaiderAPI"
require_relative "Blizzard"
require_relative "mythicdb"
require_relative "DBAPI"


realm = "Sargeras"
username= "Brewaholic"
raid = RaiderAPI.new(username, realm)
out = raid.AllRuns


#puts data["keystone_affixes"]
#File.write("log.txt", out)
=begin
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
