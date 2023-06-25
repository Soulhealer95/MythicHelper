require_relative 'DBAPI'

# Adapt DBAPI to get useful M+ information
class MythicDB < DBAPI
=begin
  @instance = new

  private_class_method :new

  def self.instance
    @instance
  end
=end

  def initialize(host, port, user, pass)
    super
    @leaderboard = nil
    @fields = {"rank" => nil,
               "name" => nil,
               "realm" => nil,
               "rating" => nil
              }
  end

end

