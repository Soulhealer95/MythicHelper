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

  # Execute a raw MySQL SELECT statement
  # @note The underlying wrapper provides this functionality to I facilitated it 
  #   see - https://gitlab.com/tmtms/ruby-mysql
  # @param query [String] statement to execute
  # @return [ResultObj]  Result-set Object
  def query_raw(query)
    # Mostly for logging
    puts "Debug: " + query 
    res = @client.query(query)
    return res.entries
  end
  
  # Execute a raw MySQL statement
  # @note  all other functions just form the statements and hand to this function
  # @param stmt [String] statement to execute
  # @param values [Array] values the underlying gem allows for in-string 
  #                              replacement on '?' char along with values 
  #                              to replace it with.
  #                              this is here to provide that functionality 
  #                              (untested)
  # @return [ResultObj]  Statement-Result Object
  def stmt_raw(stmt, values={})
    # Mostly for logging
    puts "Debug: " + stmt
    prep = @client.prepare(stmt)
    out = prep.execute values
    return out 
  end

  # Creates a table in the database
  # @note example: create_table("mythic", ["rank%v", "rating%i"], "PRIMARY KEY(rank)")
  #
  # @param tabl_name  [String]  name of table to create
  # @param fieldnames [Array]   name of entries with type separated with %
  #                              currently supported - 
  #                                int(i)
  #                                int AUTO_INCREMENT (ia)
  #                                varchar(v)
  # @param extra_opts [String]  string with any additional options
  # @return [ResultObj]  Statement-Result Object
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

  # Inserts values into a table 
  #
  # @note example: insert_table_v("mythic_rank", ["103", username, realm, "666"])
  #
  # @param tabl_name  [String]  name of table
  # @param vals       [Array]   name of values to add
  # @return [ResultObj]  Statement-Result Object
  def insert_table_v(tabl_name, vals)
    stmt = "INSERT INTO #{tabl_name} VALUES ("
    for val in vals
      stmt = stmt + " " + val + ","
    end
    stmt = stmt.chop + " )"
    return stmt_raw(stmt)
  end

  # Inserts custom values into a table 
  #
  # @note example: insert_table_c("mythic_rank", <hash>)
  #
  # @param tabl_name  [String]  name of table
  # @param vals       [Hash]    key and value to add to table
  # @return [ResultObj]  Statement-Result Object
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

  # Updates existing entry in a table 
  #
  # @note example: update_table_by_field("mythic_rank", <hash>)
  #
  # @param tabl_name  [String]  name of table
  # @param field_name [Hash]    name of the column => value to look for
  # @param values     [Hash]    key and value to update
  # @return [ResultObj]  Statement-Result Object
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

  # Delete entry from table which matches field
  #
  # @note example: delete_field("mythic_rank", <hash>)
  #
  # @param tabl_name  [String]  name of table
  # @param field      [Hash]    name of the column => value to look for
  # @return [ResultObj]  Statement-Result Object
  def delete_field(tabl_name, field)
    stmt = "DELETE FROM #{tabl_name} WHERE "
    # TODO - add AND/OR etc support
    field.each do |key, val|
      stmt = stmt + key + "=" + val.to_s
    end
    return stmt_raw(stmt)
  end

  # Delete table
  #
  # @param tabl_name  [String]  name of table
  # @return [ResultObj]  Statement-Result Object
  def delete_table(tabl_name)
    stmt = "DROP TABLE #{tabl_name}"
    return stmt_raw(stmt)
  end


  # Get data for a field value
  #
  # @note example: get_field("mythic_rank", ["rating"], <hash>)
  #
  # @param tabl_name  [String]  name of table
  # @param fields     [Hash]    name of the column => value to look for
  # @param conditions [Hash]    name of the column => value to filter on
  # @param extra_opts [String]  any additional options
  # @return [ResultObj]  Statement-Result Object
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

  # Performs connection to the database
  def connect
    if !@client
      connect_string = "mysql://" + @user + ":" + @pass + "@" + @hostname + ":" + @port +"/" + @user + "?charset=utf8mb4"
      @client = Mysql.connect(connect_string)
    end
  end


end
