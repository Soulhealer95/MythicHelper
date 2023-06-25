# Just a wrapper to provide functionality to connect to a db
# and perform simple reads and writes using JSON format
# Adaptor from Ruby to MySQL
require 'mysql'
class DBAPI
  def initialize(host, port, user, pass)
    @hostname = host
    @port = port
    @user = user
    @pass = pass
    @client = nil
    connect()
  end

  def connect
    if !@client
      connect_string = "mysql://" + @user + ":" + @pass + "@" + @hostname + ":" + @port +"/" + @user + "?charset=utf8mb4"
      @client = Mysql.connect(connect_string)
    end
  end

  def query_raw(query)
    res = @client.query(query)
    return res
  end
end