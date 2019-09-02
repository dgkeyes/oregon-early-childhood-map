
# Packages ----------------------------------------------------------------

library(tidyverse)
library(tigris)
library(ggmap)

# Get Data ----------------------------------------------------------------

# https://oregonearlylearning.com/administration/early-learning-hubs/

early_learning_hubs <- tribble(
  ~hub_name, ~address, ~region, ~website,
  "Blue Mountain Early Learning Hub", "2001 SW Nye Ave Pendleton, OR 97801", "Morrow, Umatilla, Union", "https://bluemountainearlylearninghub.org/",
  "Clackamas Early Learning Hub", "150 Beavercreek Road, Oregon City, OR 97045", "Clackamas", "https://earlylearninghubofclackamascounty.org/",
  "Early Learning Hub of Central Oregon", "2804 SW 6th St Redmond OR 97756", "Crook, Deschutes, Jefferson", "https://earlylearninghubco.org",
  "Early Learning Hub of Linn, Benton, and Lincoln Counties", "6500 Pacific Blvd. SW Albany, OR  97321", "Benton, Lincoln, Linn",  "https://lblearlylearninghub.org",
  "Early Learning Multnomah", "619 SW 11th Ave. Portland, OR 97205", "Multnomah", "http://www.earlylearningmultnomah.org",
  "Early Learning Washington County", "20665 SW Blanton Street Aloha, OR 97078", "Washington", "https://www.co.washington.or.us/HHS/ChildrenYouthFamilies/",
  "Eastern Oregon Community Based Services Hub", "363 A St W, Vale, OR 97918", "Baker, Malheur, Wallowa", "https://www.malesd.k12.or.us/eastern-oregon-hub",
  "Four Rivers Early Learning Hub", "400 East Scenic Drive, The Dalles, OR 97058", "Gilliam, Hood River, Sherman, Wasco, Wheeler", "https://4relh.org/",
  "Frontier Early Learning Hub", "25 Fairview Hts, Burns OR 97720", "Harney", "https://harneyesd.sharpschool.com/e_c_c/harney_grant_frontier_hub",
  "Lane Early Learning Alliance", "3171 Gateway Loop, Springfield, OR 97477", "Lane", "https://earlylearningalliance.org",
  "Marion and Polk Early Learning Hub", "2995 Ryan Drive SE, Salem, Oregon 97301", "Marion, Polk", "https://parentinghub.org",
  "Northwest Early Learning Hub", "5825 NE Ray Circle Hillsboro, Oregon", "Clatsop, Columbia, Tillamook", "http://nwelhub.org/",
  "South Coast Regional Early Learning Hub", "1855 Thomas Avenue Coos Bay, OR 97420", "Coos, Curry", "https://www.screlhub.com/",
  "South-Central Oregon Early Learning Hub", "1409 NE Diamond Lake Blvd, Roseburg, OR 97470", "Douglas, Klamath, Lake", "https://douglasesd.k12.or.us/early-learning-hub/home",
  "Southern Oregon Early Learning Services", "101 North Grape Street, Medford OR 97501", "Jackson, Josephine", "https://www3.soesd.k12.or.us/southernoregonlearninghub/",
  "Yamhill Early Learning Hub", "807 NE Third Street McMinnville, OR 97128", "Yamhill", "https://yamhillcco.org/early-learning-hub/"
)

early_learning_hubs_locations <- early_learning_hubs %>%
  mutate_geocode(address)

write_csv(early_learning_hubs_locations, "data-clean/early-learning-hubs-locations.csv")

early_learning_hubs_regions <- early_learning_hubs %>% 
  separate_rows(region, sep = ",") %>% 
  mutate(region = str_trim(region))

write_csv(early_learning_hubs_regions, "data-clean/early-learning-hubs-regions.csv")






