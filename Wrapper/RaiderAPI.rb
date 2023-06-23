require_relative "Request"

class RaiderAPI < Request

  def initialize(name, realm)
    super
    @supported_region = "us"
    @current_season = "9"

    # character specific
    @base_uri = "https://raider.io/api/v1/characters/profile?region=" + \
                 @supported_region + "&realm=" + @realm + "&name=" + @name
    @params_url = @base_uri + "&fields="

    # mythic specific
    @mythic_url = "https://raider.io/api/v1/mythic-plus/"
    @mythic_static = @mythic_url + "static-data?expansion_id="

  end

  def FieldData(field)

    url = @params_url + field
    data = getData(url)
    @current_dungeons = []

    # In case there are some  special characters in the params
    format_field= (field.split(":")[0])
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

  #  just return {dungeon name: {affix : {level, score}}}
  def OrganizeDungeons(data)
    output = {}
    for dungeons in data
      output[dungeons["dungeon"]] = { dungeons["affixes"][0]["name"] =>  dungeons["score"]  }
    end
    return output
  end

  def MythicRating
    data = FieldData("mythic_plus_scores_by_season:current")
    ratings = data[0]["scores"]
    main_rating = ratings["all"]
    return main_rating
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
    dungeons = Current_Dungeons()
    out = {}
    for dung in dungeons
      out[dung] = best[dung].merge(alt[dung])
    end
    return out
  end

end

