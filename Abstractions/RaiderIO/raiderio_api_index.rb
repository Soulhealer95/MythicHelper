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


# Use string.gsub to replace {} variables
module RaiderIO_Links
  # Index of all links for raiderIO
  RAPI = {
    # Primary Link
    :api_url              => "https://raider.io",
    # Character Link
    :char_info            => "/api/v1/characters/profile?region={region}&realm={realm}&name={name}&fields={fields}",
    # General M+
    :periods              => "/api/v1/periods",
    :mythic_static        => "/api/v1/mythic-plus/static-data?expansion_id={expansionID}",
    :affixes              => "/api/v1/mythic-plus/affixes?region={region}&locale={locale}",
    # Specific M+
    :run_details          => "/api/v1/mythic-plus/run-details?season={seasonSlug}&id={runID}",
    :season_runs          => "/api/v1/mythic-plus/runs?season={season}&region={region}&dungeon={dungeons}&page={page}",
  }
  # Allowed Fields for Character
  RFLDS = {
    :all                  => "mythic_plus_scores_by_season:current,mythic_plus_ranks,mythic_plus_best_runs,mythic_plus_alternate_runs",
    :scores               => "mythic_plus_scores_by_season:{season}",
    :ranks                => "mythic_plus_ranks",
    :best_runs            => "mythic_plus_best_runs",
    :alt_runs             => "mythic_plus_alternate_runs"
  }
end
