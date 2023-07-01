require 'time'
require_relative 'RaiderAPI'

# Templates a MythicInfo Object 
module MythicInfo
  # Seasonal things
  SeasonInfo  = {
    :season_id       => "season-df-2",
    :season_dungeons => [
                          "Brackenhide Hollow",
                          "Halls of Infusion",
                          "Neltharus",
                          "The Underrot",
                          "Freehold",
                          "Neltharian's Lair",
                          "The Vortex Pinnacle",
                          "Uldaman: Legacy of Tyr"
                        ],
    :primary_affixes => ["Fortified", "Tyrannical"]
  }

  # Weekly things
  PeriodInfo  = {
    :period_num => 913,
    :primary_affix => "Fortified",
    :period_end => "2023-07-04T15:00:00.000Z"
  }
end

=begin
Auto-Update Code for the future
# Manages the mythicInfo object
class Mythic_Mediator

  def initialize
    @cache_filename  = "mythic_cache.rb"
    @cache_file = File.open(@cache_filename, "rw")

    @season_info = nil
    @period_info = nil
    init_objects
  end

  def GetSeasonInfo
    return @season_info
  end

  def GetPeriodInfo
    return @period_info
  end
  
  private
  def init_objects

  end
  def set_seasonal_info(dung, aff)
    SeasonInfo[:season_dungeons] = dung
    SeasonInfo[:season_primary_affixes] = aff
  end

  def set_period_info(num, affix, end_t)
    PeriodInfo[:period_num] = num
    PeriodInfo[:period_affix] = affix
    PeriodInfo[:period_end] = end_t
  end

  # Checks if the data in this file is stale
  #
  # @params nil [nil] None
  # @returns bool [Boolean] Whether data is stale
  def stale_data
    t_string = PeriodInfo[:period_end]
    end_t = Time.parse(t_string)
    my_t = Time.now

    # using this compares across timezones
    return true if (puts my_t <=> end_t) <= 0
    return false
  end
end

=end
