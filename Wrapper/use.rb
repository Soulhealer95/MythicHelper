require_relative "RaiderAPI.rb"


realm = "Sargeras"
username= "Crendore"

raid = RaiderAPI.new(username, realm)

puts raid.MythicRating

puts raid.AllRuns