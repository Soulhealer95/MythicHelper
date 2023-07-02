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


require_relative '../General/DB/DBAPI'
require_relative '../General/config_parser'

# Extend DBAPI to get useful M+ information
class MythicDB < DBAPI
  # set up database config here
  def initialize
    confinit = GetConfig.new(self)
    config = confinit.getconf
    super(config["hostname"], config["port"], config["username"], config["password"])

    # table name and fields
    @leaderboard = "mythictable_prod"
    @fields = {
               "name" => nil,
               "realm" => nil,
               "rating" => nil
              }
  end
 
  # look up a name in the table created
  def lookup_name(name, realm)
    out =  get_field(@leaderboard, nil, {"name" => "'#{name}'", 
                                         "realm" => "'#{realm}'"} )
    return nil if out.empty?
    return JSON.generate(out)
  end

  # get rating of a player from db
  def get_rating(name, realm)
    out = lookup_name(name, realm)
    return out
  end

  # add rating to player in db
  def add_rating(name, realm, rating)
    namef = format_s(name)
    realmf = format_s(realm)
    # check if the name exists - formats the names
    if !get_rating(name, realm) 
      insert_table_c(@leaderboard, {"name" => namef, "realm" => realmf, "rating" => rating.to_s})
    else
      update_table_by_field(@leaderboard, {"name" => namef}, {"rating" => rating})
    end
  end

  # get rank of a player from db
  def get_app_rank(name, realm)
    realmf = format_s(realm)
    # get everything
    out = get_field(@leaderboard, ["name"],{"realm" => realmf},"ORDER BY rating DESC")
    return (out.find_index([name]) + 1)
  end


  # creates a table in database.
  # should only be run once, during initial config
  # never let it be called from the outside
  private
  def init_board
    keys = @fields.keys
    create_table(@leaderboard, ["#{keys[0]}%v", "#{keys[1]}%v",
                                "#{keys[2]}%i"])
  end
  # format strings into something db would accept
  def format_s(str)
    return "'#{str}'"
  end
 
end

