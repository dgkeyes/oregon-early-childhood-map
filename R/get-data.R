
# Packages ----------------------------------------------------------------

library(tidyverse)
library(here)
library(sf)
library(ggmap)
library(janitor)
library(tidycensus)
library(scales)
library(tigris)


# Geodata -----------------------------------------------------------------

options(tigris_class = "sf")

oregon_counties <- counties(state = "Oregon",
                            cb = TRUE) %>% 
  clean_names()

st_write(oregon_counties, "data-clean/oregon-counties.shp")

oregon_census_tracts <- tracts(state = "Oregon",
                               cb = TRUE) %>% 
  clean_names()

st_write(oregon_census_tracts, "data-clean/oregon-census-tracts.shp")



# School District Boundaries ----------------------------------------------

school_district_boundaries_unified <- school_districts(state = "Oregon",
                                                       year = 2018,
                                                       type = "unified") %>% 
  clean_names() %>% 
  select(name)

school_district_boundaries_elementary <- school_districts(state = "Oregon",
                                                          year = 2018,
                                                          type = "elementary") %>% 
  clean_names() %>% 
  select(name)


school_district_boundaries_secondary <- school_districts(state = "Oregon",
                                                         year = 2018,
                                                         type = "secondary") %>% 
  clean_names() %>% 
  select(name)

school_district_boundaries <- rbind(school_district_boundaries_elementary,
                                    school_district_boundaries_secondary,
                                    school_district_boundaries_unified)

st_write(school_district_boundaries, "data-clean/school-district-boundaries.shp")


# Child Care Facilities ---------------------------------------------------

# child_care_facilities <- read_csv(here("data-raw", "child-care-facilities.csv"),
#                                   na = ".") %>%
#   clean_names() %>%
#   mutate(location = str_glue("{address} {city}, {state} {zip_code}")) %>%
#   replace_na(list(facility_name = "Name not public")) %>%
#   mutate_geocode(location) %>%
#   view()
# 
# beepr::beep()
# 
# 
# write_csv(child_care_facilities, here("data-clean", "child-care-facilities-geocoded.csv"))



# Schools -----------------------------------------------------------------


# Community Attributes ----------------------------------------------------


v17 <- load_variables(2017, "acs5", cache = TRUE)

median_income <- get_acs(geography = "tract",
                         year = 2017,
                         survey = "acs5",
                         state = "OR",
                         variables = (median_income = "B19013_001")) %>% 
  clean_names() %>% 
  mutate(plot_label = dollar(estimate)) %>% 
  mutate(measure = "Median Income") 

median_age <- get_acs(geography = "tract",
                         year = 2017,
                         survey = "acs5",
                         state = "OR",
                         variables = "B01002_001") %>% 
  clean_names() %>% 
  mutate(plot_label = as.character(estimate)) %>% 
  mutate(measure = "Median Age")






# diversity_index <- read_csv("data-raw/diversity-index.csv") %>% 
#   clean_names() %>% 
#   mutate(tract_id = as.character(geoid10)) %>% 
#   select(tract_id, county, divindx_cy) %>% 
#   rename("value" = "divindx_cy") %>%
#   mutate(measure = "Diversity Index")
# 
# 
# median_household_income <- read_csv("data-raw/median-household-income.csv") %>% 
#   clean_names() %>% 
#   mutate(tract_id = as.character(geoid10)) %>% 
#   select(tract_id, county, w_ch18) %>% 
#   rename("value" = "w_ch18") %>%
#   mutate(measure = "Median Household Income") 
# 
# population_under_18 <- read_csv("data-raw/population-under-18.csv") %>% 
#   clean_names() %>% 
#   mutate(tract_id = as.character(geoid10)) %>% 
#   select(tract_id, county, pop18under_pct) %>% 
#   rename("value" = "pop18under_pct") %>%
#   mutate(measure = "Population Under 18") 

# oregon_census_tracts <- tracts(state = "Oregon",
#                                cb = TRUE) %>% 
#   clean_names()

community_attributes <- bind_rows(median_income,
                                  median_age) %>% 
  mutate(plot_label = glue("{measure}: {plot_label}"))

write_csv(community_attributes, "data-clean/community-attributes.csv")

# community_attributes_geodata <- left_join(oregon_census_tracts,
#                                           community_attributes, 
#                                           by = "geoid") %>% 
#   rename("tract_id" = "geoid",
#          "value" = "estimate")

# write_sf(community_attributes_geodata, "data-clean/community-attributes.shp")

# community_attributes_wide <- diversity_index %>% 
#   left_join(median_household_income, by = "tract_id") %>% 
#   left_join(population_under_18, by = "tract_id") %>% 
#   select(tract_id, county, divindx_cy, w_ch18, pop18under_pct) %>% 
#   set_names(c("tract_id", "county", "Diversity Index", "Median Household Income", "Population Under 18"))

# write_csv(community_attributes_wide, "data-clean/community-attributes-wide.csv")


