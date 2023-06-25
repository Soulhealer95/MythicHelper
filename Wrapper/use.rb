require_relative "RaiderAPI"
require_relative "Blizzard"
require_relative "DBAPI"


realm = "Sargeras"
username= "ixys"
=begin
raid = RaiderAPI.new(username, realm)
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

db = DBAPI.new("sql9.freesqldatabase.com", "3306", "sql9628659", "diZSARZDK5")

puts db