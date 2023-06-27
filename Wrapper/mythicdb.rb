require_relative 'DBAPI'

# Adapt DBAPI to get useful M+ information
class MythicDB < DBAPI
=begin
  prep to turn this into a singleton class object
  @instance = new

  private_class_method :new

  def self.instance
    @instance
  end
=end

  # set up database config here
  def initialize
    super("sql9.freesqldatabase.com", "3306", "sql9628659", "diZSARZDK5")

    # table name and fields
    @leaderboard = "mythictable"
    @fields = {
               "name" => nil,
               "realm" => nil,
               "rating" => nil
              }
  end

  def format_s(str)
    return "'#{str}'"
  end
  
  # look up a name in the table created
  def lookup_name(name, realm)
    out =  get_field(@leaderboard, nil, {"name" => "'#{name}'", 
                                         "realm" => "'#{realm}'"} )
    return JSON.generate(out)
  end

  # get rating of a player from db
  def get_rating(name, realm)
    out = lookup_name(name, realm)
    rating = nil
    rating = out if !out.empty?
    return rating
  end

  # add rating to player in db
  def add_rating(name, realm, rating)
    namef = format_s(name)
    realmf = format_s(realm)
    # check if the name exists - formats the names
    if get_rating(name, realm) 
      insert_table_c(@leaderboard, {"name" => namef, "realm" => realmf, "rating" => rating.to_s})
    else
      update_table_by_field(@leaderboard, {"name" => namef}, {"rating" => rating})
    end
  end

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
                                "#{keys[2]}%i"], "PRIMARY KEY(rating)")
  end


end

