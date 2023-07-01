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


# One stop shop for all data and profile url segments

# Use string.gsub to replace {} variables
module Blizzard_Links
  BAPI = {
    # OAUTH Links
    :api_url => "https://us.api.blizzard.com",
    :auth_url => "https://oauth.battle.net",
    # Realm Links
    :realm_index => "/data/wow/realm/index",
    :realm_info  => "/data/wow/realm/{realm_slug}",
    :connected_index => "/data/wow/connected-realm/",
    :keystone_lead =>  "/data/wow/connected-realm/{realm_id}/mythic-leaderboard/",
    # Profile Data Links
    :char_profile => "/profile/wow/character/{realm_slug}/{characterName}",
    :mythic_profile => "/profile/wow/character/{realm_slug}/{characterName}/mythic-keystone-profile",
    # Game Data Links
    :affix_index => "/data/wow/keystone-affix/index",
    :affix_info => "/data/wow/keystone-affix/{keystoneAffixId}",
    :affix_media => "/data/wow/media/keystone-affix/{keystoneAffixId}",
    :dungeon_index => "/data/wow/mythic-keystone/dungeon/index",
    :dungeon_info => "/data/wow/mythic-keystone/dungeon/{dungeonId}",
    :keystone_index => "/data/wow/mythic-keystone/index",
    :period_index => "/data/wow/mythic-keystone/period/index",
    :period_info => "/data/wow/mythic-keystone/period/{periodId}",
    :season_index => "/data/wow/mythic-keystone/season/index",
    :season_info => "/data/wow/mythic-keystone/season/{seasonId}"
  }
end
