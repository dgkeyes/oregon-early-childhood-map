
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


# COMMUNITY ATTRIBUTES ----------------------------------------------------

dk_set_community_attribute_names <- function(.data) {
  .data %>% 
    set_names(c("measure", "tract_id", "value", "label")) 
}


# Get all vars

v17 <- load_variables(2017, "acs5", cache = TRUE)


# Median Household Income with Children Under Age 18 ----------------------

# DK: Don't think this is possible. Did median income instead.

v17 %>% 
  filter(str_detect(concept, "MEDIAN INCOME")) %>% 
  distinct(concept)

median_income <- get_acs(geography = "tract",
                         year = 2017,
                         survey = "acs5",
                         state = "OR",
                         variables = (median_income = "B19013_001")) %>% 
  clean_names() %>% 
  mutate(plot_label = dollar(estimate)) %>% 
  mutate(measure = "Median Income") %>% 
  select(measure, geoid, estimate, plot_label) %>% 
  dk_set_community_attribute_names() %>% 
  view()


# Population Under Age 18 -------------------------------------------------

v17 %>% 
  filter(str_detect(name, "B06001")) %>% 
  distinct(name) %>% 
  pull(name)

population_under_18 <- get_acs(geography = "tract",
                               year = 2017,
                               survey = "acs5",
                               state = "OR",
                               summary_var = "B06001_001",
                               variables = c("Under 5" = "B06001_002",
                                             "5 to 17" = "B06001_003")) %>% 
  clean_names() %>% 
  group_by(geoid) %>% 
  summarize(under_18_pop = sum(estimate),
            total_pop = sum(summary_est)) %>% 
  mutate(under_18_pop_pct = under_18_pop / total_pop) %>% 
  mutate(plot_label = percent(under_18_pop_pct, 0.1)) %>% 
  mutate(measure = "Population Under Age 18") %>% 
  select(measure, geoid, under_18_pop_pct, plot_label) %>%
  dk_set_community_attribute_names() %>% 
  view()
  

# Median Age --------------------------------------------------------------

median_age <- get_acs(geography = "tract",
                      year = 2017,
                      survey = "acs5",
                      state = "OR",
                      variables = "B01002_001") %>%
  clean_names() %>%
  mutate(plot_label = number(estimate, 0.1)) %>%
  mutate(measure = "Median Age") %>%
  select(measure, geoid, estimate, plot_label) %>%
  dk_set_community_attribute_names()


# Medical Assistance Program Recipients -----------------------------------

# DK: Not sure if this exists in census data


# Children in Paid Foster Care --------------------------------------------


# DK: Not sure how to do this

v17 %>% 
  filter(str_detect(label, "Foster")) %>% 
  DT::datatable()


# Snap Recipients ---------------------------------------------------------

v17 %>% 
  filter(str_detect(name, "B09010")) %>% 
  DT::datatable()

# DK: Variable is RECEIPT OF SUPPLEMENTAL SECURITY INCOME (SSI), CASH PUBLIC ASSISTANCE INCOME, OR FOOD STAMPS/SNAP IN THE PAST 12 MONTHS BY HOUSEHOLD TYPE FOR CHILDREN UNDER 18 YEARS IN HOUSEHOLDS

snap_recipients <- get_acs(geography = "tract",
                           year = 2017,
                           survey = "acs5",
                           state = "OR",
                           summary_var = "B09010_001",
                           variables = "B09010_002") %>%
  clean_names() %>%
  mutate(tanf_pct = estimate / summary_est) %>% 
  mutate(plot_label = percent(tanf_pct, 0.1)) %>% 
  mutate(measure = "TANF Households") %>% 
  select(measure, geoid, tanf_pct, plot_label) %>%
  dk_set_community_attribute_names() %>% 
  view()


# Race/Ethnicity ----------------------------------------------------------

race_ethnicity <- get_acs(geography = "tract",
                          year = 2017,
                          survey = "acs5",
                          state = "OR",
                          variables = c(White = "B01001A_003",
                                        White = "B01001A_018",
                                        `African American` = "B01001B_003",
                                        `African American` = "B01001B_018",
                                        `American Indian and Alaska Native` = "B01001C_003",
                                        `American Indian and Alaska Native` = "B01001C_018",
                                        Asian = "B01001D_003",
                                        Asian = "B01001D_018",
                                        `Native Hawaiian and Other Pacific Islander` = "B01001E_003",
                                        `Native Hawaiian and Other Pacific Islander` = "B01001E_018",
                                        `Other Race` = "B01001F_003",
                                        `Other Race` = "B01001F_018",
                                        `Two or More Races` = "B01001G_003",
                                        `Two or More Races` = "B01001G_018",
                                        `Hispanic or Latino` = "B01001I_003",
                                        `Hispanic or Latino` = "B01001I_018")) %>% 
  clean_names() %>% 
  mutate(measure = str_glue("Race/Ethnicity: {variable}")) %>% 
  rename("tract_id" = "geoid",
         "value" = "estimate") %>% 
  mutate(label = value) %>% 
  select(measure, tract_id, value, label) %>% 
  mutate(measure = as.character(measure)) %>% 
  mutate(label = as.character(label))


# Create and write community_attributes data frame ------------------------

community_attributes <- bind_rows(median_income,
                                  population_under_18,
                                  snap_recipients,
                                  median_age,
                                  race_ethnicity) %>% 
  mutate(measure_sentence_case = str_to_sentence(measure)) %>% 
  mutate(plot_label = str_glue("{measure_sentence_case} in this census tract: {label}"))


write_csv(community_attributes, "data-clean/community-attributes.csv")




