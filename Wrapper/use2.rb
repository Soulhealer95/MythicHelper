require_relative "MythicAPI"

name = "ixys"
realm = "sargeras"

mythic = MythicAPI.new
t1 = Time.now
puts mythic.MythicRating(name, realm)
t2 = Time.now
puts mythic.MythicRating(name, realm)
t3 = Time.now
puts mythic.MythicRating(name, realm)
t4 = Time.now
puts mythic.MythicRating(name, realm)
t5 = Time.now

ts = {}
ts[0] = (t2 - t1)
ts[1] = (t3 - t2)
ts[2] = (t4 - t3)
ts[3] = (t5 - t4)
for i in ts
  puts i
end

#$char.setRuns({"The Underrot" => {"Fortified" => [10, 200]}})
#puts $char.getRuns


=begin
def test_api(api, *params)
  puts "Testing #{api}: " 
  if !params.empty?
    obj = $init.method(api)[*params]
  else
    obj = $init.method(api).()
  end
  if obj && obj != []
    puts "PASS"
    return obj
  else
    puts "FAIL"
  end
  return
end
test_api(:getCharacter, name, realm)
test_api(:getPeriod)
puts test_api(:getAffix)
test_api(:getStatic)


def currentDungeons(raider_data)
  out = []
  for i in raider_data["dungeons"]
    out.push(i["name"])
  end
  return out
end
def currentAffixes(raider_data)
  for i in raider_data["affix_details"]
    return i["name"]
  end
end

t_string = "2023-07-04T15:00:00.000Z"
end_t = Time.parse(t_string)
my_t = Time.now
puts my_t <=> end_t



=end
