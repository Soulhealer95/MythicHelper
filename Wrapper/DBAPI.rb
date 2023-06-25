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
    return res.entries
  end

  def stmt_raw(stmt, values={})
    prep = @client.prepare(stmt)
    out = prep.execute values
    return out 
  end

  # where params should be hash with fieldname % type objects
  def create_table(tabl_name, fieldnames)
    stmt = "CREATE TABLE #{tabl_name} ( "
    type = ""
    count = 0

    # parse the fields of expected format "name%type"
    # TODO - move this to another class
    for fields in fieldnames
      arr = fields.split('%',2)
      case arr[1]
      when "i"
        type = "int"
      when "v"
        type = "varchar(255)"
      else
        puts "Invalid type - #{arr[1]}"
        return
      end
      stmt = stmt + " " + arr[0] + " " + type + ","
    end
    # remove extra ',' and close
    stmt = stmt.chop + " )"

    # execute the statement
    return stmt_raw(stmt)
  end

  # expects an array of values as vals
  def insert_table_v(tabl_name, vals)
    stmt = "INSERT INTO #{tabl_name} VALUES ("
    for val in vals
      stmt = stmt + " " + val + ","
    end
    stmt = stmt.chop + " )"
    return stmt_raw(stmt)
  end

  # expects a hash {key => value}
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

  # given a (field name => value), update the col, vals
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

  # expects field_name => field_value hash
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


  # expects fields (array) to check in a table
  # for a condition (e.g name = anne)
  def get_field(tabl_name, fields=nil, conditions=nil)
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
        stmt = stmt + " " + key + " = " + val + ";" 
      end
    end
    return query_raw(stmt)
  end
end
