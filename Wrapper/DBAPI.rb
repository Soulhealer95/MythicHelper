# Just a wrapper to provide functionality to connect to a db
# and perform simple reads and writes 
# data query outputs should use JSON format

# Adaptor for ruby-mysql client 
# at https://gitlab.com/tmtms/ruby-mysql 

require 'mysql'

# Generic DB Wrapper to be used as base 
class DBAPI

  # sets up a connection to a database upon initialization
  def initialize(host, port, user, pass)
    @hostname = host
    @port = port
    @user = user
    @pass = pass
    @client = nil
    connect()
  end

  # method query_raw
  # @description
  #   execute a raw MySQL SELECT statement
  #   The underlying wrapper provides this functionality to I facilitated it 
  #   see - https://gitlab.com/tmtms/ruby-mysql
  # @params
  #   stmt                  string   statement to execute
  #
  # @returns
  #   Result-set Object
  #

  # execute a raw sql query  (select)
  def query_raw(query)
    puts "Debug: " + query 
    res = @client.query(query)
    return res.entries
  end
  
  # method stmt_raw
  # @description
  #   execute a raw MySQL statement
  #   all other functions just form the statements and hand to this function
  # @params
  #   stmt                  string   statement to execute
  #   values                array    the underlying wrapper allows for in-string 
  #                                  replacement on '?' char along with values 
  #                                  to replace it with.
  #                                  this is here to provide that functionality 
  #                                  (untested)
  # @returns
  #   Statement-Result Object
  #
  def stmt_raw(stmt, values={})
#    puts "Debug: " + stmt
    prep = @client.prepare(stmt)
    out = prep.execute values
    return out 
  end

  # method create_table
  # @description
  #   creates a table in the database
  # @params
  #   tabl_name             string   name of table to create
  #   fieldnames            array    name of entries with type separated with %
  #                                  currently supported - 
  #                                  int(i)
  #                                  int AUTO_INCREMENT (ia)
  #                                  varchar(v)
  #   extra_opts            string   string with any additional options
  # @returns
  #   Statement-Result Object
  #
  # example usage:
  # create_table("mythic", ["rank%v", "rating%i"], "PRIMARY KEY(rank)")
  def create_table(tabl_name, fieldnames, extra_opts=nil)
    stmt = "CREATE TABLE #{tabl_name} ( "
    type = ""
    count = 0

    # parse the fields of expected format "name%type"
    # TODO - move this to another class/method
    for fields in fieldnames
      arr = fields.split('%',2)
      case arr[1]
      when "i"
        type = "int"
      when "ia"
        type = "int AUTO_INCREMENT"
      when "v"
        type = "varchar(255)"
      else
        puts "Invalid type - #{arr[1]}"
        return
      end
      stmt = stmt + " " + arr[0] + " " + type + ","
    end
    # remove extra ',' and close
    if extra_opts
      stmt = stmt + " " + extra_opts
    else
      stmt = stmt.chop
    end
    stmt = stmt + " )"

    # execute the statement
    return stmt_raw(stmt)
  end

  # method insert_table_v
  # @description
  #   inserts values into a table 
  # @params
  #   tabl_name             string   name of table to create
  #   vals                  array    array of values to add (expects all fields)
  # @returns
  #   Statement-Result Object
  #
  # example usage:
  # insert_table_v("mythic_rank", ["103", username, realm, "666"])
  def insert_table_v(tabl_name, vals)
    stmt = "INSERT INTO #{tabl_name} VALUES ("
    for val in vals
      stmt = stmt + " " + val + ","
    end
    stmt = stmt.chop + " )"
    return stmt_raw(stmt)
  end

  # method insert_table_c
  # @description
  #   inserts selected values into a table 
  # @params
  #   tabl_name             string   name of table to create
  #   vals                  hash     {"key" => "value"} to add to table
  # @returns
  #   Statement-Result Object
  #
  # example usage:
  # insert_table_c("mythic_rank", {"rank" => "103", "name" => username, 
  #                                  "realm" => realm, "rating" => "666"})
  def insert_table_c(tabl_name, vals)
   stmt = "INSERT INTO #{tabl_name} ( "

   # column names
   keys = vals.keys
   for val in keys
     stmt = stmt + " " + val + ","
   end
   stmt = stmt.chop + " )"

   # values
   stmt = stmt + " VALUES ( "
   vals.each do |key, val| 
    stmt = stmt + " " + val + ","
   end
   stmt = stmt.chop
   stmt = stmt + " )"
   return stmt_raw(stmt)
  end

  # method update table by field 
  # @description
  #   updates existing entry in a table 
  # @params
  #   tabl_name             string   name of table to create
  #   field_name            hash     name of the column => value to look for
  #   values                hash     values to update in the filtered row 
  #                                  {"key" => "value"}
  # @returns
  #   Statement-Result Object
  #
  # example usage:
  # update_table_by_field("mythic_rank", {"name" => username}, 
  #                         {"rating" => 154, "rank" => 1000, "realm" => "'Sargeras'"})
  def update_table_by_field(tabl_name, field_name, values)
    stmt = "UPDATE #{tabl_name} SET"
    values.each do |key, val|
      stmt = stmt + " " + key + " = " + val.to_s + ","
    end
    # this wont work if multiple conditions are supplied 
    # TODO - add AND/OR etc support
    stmt = stmt.chop + " WHERE "
    field_name.each do |key, val|
      stmt = stmt + key + "=" + val.to_s
    end
    stmt = stmt + ";"
    return stmt_raw(stmt)
  end

  # method delete_field
  # @description
  #   delete entry from table which matches field
  # @params
  #   tabl_name             string   name of table to create
  #   field_name            hash     name of the column => value to look for
  # @returns
  #   Statement-Result Object
  #
  # example usage:
  # delete_field("mythic_rank", {"name" => username})
  def delete_field(tabl_name, field)
    stmt = "DELETE FROM #{tabl_name} WHERE "
    # TODO - add AND/OR etc support
    field.each do |key, val|
      stmt = stmt + key + "=" + val.to_s
    end
    return stmt_raw(stmt)
  end

  def delete_table(tabl_name)
    stmt = "DROP TABLE #{tabl_name}"
    return stmt_raw(stmt)
  end


  # method data_field
  # @description
  #   get data for a field value
  # @params
  #   tabl_name             string   name of table to create
  #   fields                hash     name of the column => value to look for
  #                                  defaults to ALL (*)
  #   conditions            hash     keys=>values to filter on
  #   extra_opts            string   string with any additional options
  # @returns
  #  result-set from query
  #
  # example usage:
  # get_field("mythic_rank", ["rating"], {"name" => "'#{username}'"})
  def get_field(tabl_name, fields=nil, conditions=nil, extra_opts=nil)
    stmt = "SELECT "
    if !fields
      stmt = stmt +  " *  "
    else
     for elem in fields
       stmt = stmt + " " + elem + ","
     end
    end
    stmt = stmt.chop
    stmt = stmt + " FROM #{tabl_name}"
    if conditions != nil
      stmt = stmt + " WHERE "
      conditions.each do |key, val|
        stmt = stmt + " " + key + " = " + val 
        stmt = stmt + " AND " if key != conditions.keys.last
      end
    end
    if extra_opts != nil
      stmt = stmt + " " + extra_opts
    end
    stmt = stmt + ';'
    return query_raw(stmt)
  end

  private
  # method connect
  # @description
  #  performs connection to the database
  # @params
  #  None
  def connect
    if !@client
      connect_string = "mysql://" + @user + ":" + @pass + "@" + @hostname + ":" + @port +"/" + @user + "?charset=utf8mb4"
      @client = Mysql.connect(connect_string)
    end
  end


end
