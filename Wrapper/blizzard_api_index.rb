# One stop shop for all data and profile url segments

# Use string.gsub to replace {} variables
module Blizzard_Links
  BAPI = {
    :api_url => "https://us.api.blizzard.com",
    :auth_url => "https://oauth.battle.net",
    :realm_index => "/data/wow/realm/index",
    :realm_info  => "/data/wow/realm/{realm_slug}",
    :connected_index => "/data/wow/connected-realm/",
    :keystone_lead =>  "/data/wow/connected-realm/{realm_id}/mythic-leaderboard/",
    :char_profile => "/profile/wow/character/{realm_slug}/{characterName}",
    :mythic_profile => "/profile/wow/character/{realm_slug}/{characterName}/mythic-keystone-profile"
  }
end
