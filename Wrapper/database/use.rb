require_relative "mythicdb"
require_relative "DBAPI"


# sample usage for database
realm = "Sargeras"
username= "ixys"
db = MythicDB.new
puts db.get_rating(username, realm)

