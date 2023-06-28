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


require_relative "Request"

class RaiderAPI < Request

  def initialize(name, realm)
    super
    @supported_region = "us"
    @current_season = "9"
    @current_dungeons = []

    # character specific
    @base_uri = "https://raider.io/api/v1/characters/profile?region=" + \
                 @supported_region + "&realm=" + @realm + "&name=" + @name
    @params_url = @base_uri + "&fields="

    # mythic specific
    @mythic_url = "https://raider.io/api/v1/mythic-plus/"
    @mythic_static = @mythic_url + "static-data?expansion_id="

  end

  def MythicCurrAffixes
    url = @mythic_url + "affixes?region=" + @supported_region + "&locale=en"
    out = []
    data = getData(url)
    for item in data["affix_details"]
      out.push(item["name"])
    end
    return out
  end

  def MythicRating
    data = FieldData("mythic_plus_scores_by_season:current")
    ratings = data[0]["scores"]
    main_rating = ratings["all"]
    return main_rating
  end
  
  def MythicRuns
    runs = AllRuns()
    return runs
    out = {}
    return out if !runs
  end

  private
  # given a hash {"Fortified" => x1, "Tyrannical" => x2}
  # replace with rating using following method by Blizzard
  # max_val * 1.5 + min_val * 0.5
  # return hash with rating 
  def calculate_rating(data)
    fort = "Fortified"
    tyr = "Tyrannical"
    data[tyr] = [0,0] if !data[tyr]
    data[fort] = [0,0] if !data[fort]
    out = { fort => [0, 0], tyr => [0, 0] } 
    if data[fort][0] > data[tyr][0]
      out[fort] = [ data[fort][0] * 1.5, data[fort][1] ]
      out[tyr]  = [ data[tyr][0] * 0.5, data[tyr][1] ]
    else
      out[tyr] =  [ data[tyr][0] * 1.5, data[tyr][1] ]
      out[fort]  = [ data[fort][0] * 0.5, data[fort][1] ]
    end
    out[fort][0] = out[fort][0].round(1)
    out[tyr][0] = out[tyr][0].round(1)
    return out
  end

  def BestRun
    data = FieldData("mythic_plus_best_runs")
    return OrganizeDungeons(data) 
  end

  # Best run but in alternate ones
  def AltRun
    data = FieldData("mythic_plus_alternate_runs")
    return OrganizeDungeons(data) 
  end

  # Combined Runs for Current Dungeons
  def AllRuns
    best = BestRun()
    alt = AltRun()
    return nil if !best && !alt
    return best if !alt
    return SortRuns(best, alt)
  end

  # Following make API Calls to get data
  def FieldData(field)
    url = @params_url + field
    data = getData(url)
    return nil if !data

    # In case there are some  special characters in the params
    format_field = (field.split(":")[0])
    return data[format_field]
  end

  def Current_Dungeons
    if @current_dungeons.empty? 
      url = @mythic_static + @current_season
      data = getData(url)["seasons"][0]["dungeons"]
      for i in data
        @current_dungeons.push(i["name"])
      end
    end
    return @current_dungeons
  end

  def SortRuns(best, alt)
    dungeons = Current_Dungeons()
    input = nil
    out = {}

    for dung in dungeons
      if alt[dung] != nil
        input = best[dung].merge(alt[dung]) 
      elsif best[dung] != nil
        input = best[dung]
      else
        input = nil
      end
      out[dung] = input

      #convert score to rating
      out[dung] = calculate_rating(out[dung]) if input
    end

    return out
  end

  #  just return {dungeon name: {affix : [score, level]}}
  def OrganizeDungeons(data)
    return nil if !data || data.empty?

    output = {}
    for dungeons in data
      output[dungeons["dungeon"]] = { dungeons["affixes"][0]["name"] =>  [ dungeons["score"], dungeons["mythic_level"] ]  }
    end
    return output
  end


end

