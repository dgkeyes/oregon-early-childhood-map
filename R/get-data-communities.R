
# Packages ----------------------------------------------------------------

library(tidyverse)
library(here)
library(sf)
library(ggmap)
library(janitor)
library(tidycensus)
library(scales)
library(tigris)
library(fs)
library(readxl)


# # Geodata -----------------------------------------------------------------
# 
# options(tigris_class = "sf")
# 
# oregon_counties <- counties(state = "Oregon",
#                             cb = TRUE) %>% 
#   clean_names()
# 
# st_write(oregon_counties, "data-clean/oregon-counties.shp")
# 
# oregon_census_tracts <- tracts(state = "Oregon",
#                                cb = TRUE) %>% 
#   clean_names()
# 
# st_write(oregon_census_tracts, "data-clean/oregon-census-tracts.shp")






# COMMUNITY ATTRIBUTES ----------------------------------------------------



dk_set_community_attribute_names <- function(.data) {
  .data %>% 
    set_names(c("measure", "tract_id", "value", "label")) 
}

dk_remove_nan <- function(.data) {
  .data %>% 
    mutate(label = case_when(
      label == "NaN%" ~ "Data not available",
      TRUE ~ label
    ))
}



# Get all vars ------------------------------------------------------------



v17 <- load_variables(2017, "acs5", cache = TRUE)

dk_view_all_vars <- function() {
  v17 %>% 
    DT::datatable()
}


# Population by Census Tract ----------------------------------------------

population_by_census_tract <- get_acs(geography = "tract",
                                      year = 2017,
                                      survey = "acs5",
                                      state = "OR",
                                      variables = "B01003_001") %>% 
  clean_names() %>% 
  group_by(geoid) %>% 
  summarize(total = sum(estimate)) 


# Median Household Income with Children Under Age 18 ----------------------


v17 %>% 
  filter(str_detect(concept, "MEDIAN INCOME")) %>% 
  distinct(concept)

v17 %>% 
  filter(str_detect(name, "B19125")) %>% 
  DT::datatable()


median_income_children_under_18 <- get_acs(geography = "tract",
                                           year = 2017,
                                           survey = "acs5",
                                           state = "OR",
                                           variables = (median_income = "B19125_001")) %>% 
  clean_names() %>% 
  mutate(plot_label = dollar(estimate)) %>% 
  mutate(measure = "Median Income") %>% 
  select(measure, geoid, estimate, plot_label) %>% 
  dk_set_community_attribute_names() 


# Population Under Age 18 -------------------------------------------------

v17 %>% 
  filter(str_detect(name, "B06001")) %>% 
  distinct(name) %>% 
  pull(name)

v17 %>% 
  filter(str_detect(name, "B06001")) %>% 
  DT::datatable()

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
  dk_remove_nan()


# Median Age --------------------------------------------------------------

# median_age <- get_acs(geography = "tract",
#                       year = 2017,
#                       survey = "acs5",
#                       state = "OR",
#                       variables = "B01002_001") %>%
#   clean_names() %>%
#   mutate(plot_label = number(estimate, 0.1)) %>%
#   mutate(measure = "Median Age") %>%
#   select(measure, geoid, estimate, plot_label) %>%
#   dk_set_community_attribute_names() %>% 
#   dk_remove_nan()


# Medical Assistance Program Recipients: Medicaid -------------------------

medicaid_recipients <- get_acs(geography = "tract",
                               year = 2017,
                               survey = "acs5",
                               state = "OR",
                               variables = c(yes = "C27007_004",
                                             yes = "C27007_017",
                                             no = "C27007_005",
                                             no = "C27007_018")) %>%
  clean_names() %>%
  group_by(geoid, variable) %>% 
  summarize(medicaid_population = sum(estimate)) %>% 
  ungroup() %>% 
  group_by(geoid) %>%
  mutate(pct = prop.table(medicaid_population)) %>% 
  ungroup() %>% 
  filter(variable == "yes") %>% 
  mutate(plot_label = percent(pct, 0.1)) %>% 
  select(geoid, medicaid_population, pct, plot_label) %>% 
  mutate(measure = "Medicaid Recipients") %>% 
  select(measure, geoid, pct, plot_label) %>% 
  dk_set_community_attribute_names() %>% 
  dk_remove_nan()

# Medical Assistance Program Recipients: Medicare -------------------------

medicare_recipients <- get_acs(geography = "tract",
                               year = 2017,
                               survey = "acs5",
                               state = "OR",
                               variables = c(yes = "C27006_004",
                                             yes = "C27006_017",
                                             no = "C27006_005",
                                             no = "C27006_018")) %>%
  clean_names() %>%
  group_by(geoid, variable) %>% 
  summarize(medicare_population = sum(estimate)) %>% 
  ungroup() %>% 
  group_by(geoid) %>%
  mutate(pct = prop.table(medicare_population)) %>% 
  ungroup() %>% 
  filter(variable == "yes") %>% 
  mutate(plot_label = percent(pct, 0.1)) %>% 
  select(geoid, medicare_population, pct, plot_label) %>% 
  mutate(measure = "Medicare Recipients") %>% 
  select(measure, geoid, pct, plot_label) %>% 
  dk_set_community_attribute_names() %>% 
  dk_remove_nan()

# Children in Paid Foster Care --------------------------------------------



v17 %>% 
  filter(str_detect(name, "B09018")) %>% 
  DT::datatable()


foster_care <- get_acs(geography = "tract",
                       year = 2017,
                       survey = "acs5",
                       state = "OR",
                       variables = "B09018_008",
                       summary_var = "B09018_001") %>%
  clean_names() %>%
  mutate(value = estimate / summary_est) %>% 
  mutate(plot_label = percent(value, 0.1,
                              na.rm = TRUE)) %>% 
  mutate(measure = "Children in Paid Foster Care") %>%
  select(measure, geoid, value, plot_label) %>%
  dk_set_community_attribute_names() %>% 
  dk_remove_nan()


# Public Assistance ---------------------------------------------------------

v17 %>% 
  filter(str_detect(name, "B09010")) %>% 
  DT::datatable()

# DK: Variable is RECEIPT OF SUPPLEMENTAL SECURITY INCOME (SSI), CASH PUBLIC ASSISTANCE INCOME, OR FOOD STAMPS/SNAP IN THE PAST 12 MONTHS BY HOUSEHOLD TYPE FOR CHILDREN UNDER 18 YEARS IN HOUSEHOLDS

public_assistance <- get_acs(geography = "tract",
                             year = 2017,
                             survey = "acs5",
                             state = "OR",
                             summary_var = "B09010_001",
                             variables = "B09010_002") %>%
  clean_names() %>%
  mutate(tanf_pct = estimate / summary_est) %>% 
  mutate(plot_label = percent(tanf_pct, 0.1)) %>% 
  mutate(measure = "Public Assistance Recipients") %>% 
  select(measure, geoid, tanf_pct, plot_label) %>%
  dk_set_community_attribute_names() %>% 
  dk_remove_nan() 




# SNAP --------------------------------------------------------------------

snap <- get_acs(geography = "tract",
                year = 2017,
                survey = "acs5",
                state = "OR",
                summary_var = "B22002_001",
                variables = "B22002_003") %>%
  clean_names() %>% 
  mutate(snap_pct = estimate / summary_est) %>% 
  mutate(plot_label = percent(snap_pct, 0.1)) %>% 
  mutate(measure = "SNAP Recipients") %>% 
  select(measure, geoid, snap_pct, plot_label) %>%
  dk_set_community_attribute_names() %>% 
  dk_remove_nan() 


# Race/Ethnicity ----------------------------------------------------------

race_ethnicity <- get_acs(geography = "tract",
                          year = 2017,
                          survey = "acs5",
                          state = "OR",
                          summary_var = "B06001_002",
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
  mutate(pct = estimate / summary_est) %>% 
  mutate(measure = str_glue("Race/Ethnicity: {variable}")) %>% 
  # rename("tract_id" = "geoid",
  #        "value" = "estimate") %>% 
  mutate(label = percent(pct, 0.1)) %>% 
  select(measure, geoid, pct, label) %>% 
  dk_set_community_attribute_names() %>% 
  dk_remove_nan() %>% 
  mutate(measure = as.character(measure)) %>% 
  mutate(label = as.character(label))



# Poverty Status ----------------------------------------------------------

v17 %>% 
  # filter(str_detect(concept, "POVERTY STATUS IN THE PAST 12 MONTHS")) %>% 
  filter(str_detect(label, "poverty level")) %>% 
  DT::datatable()

poverty_status_under_5 <- get_acs(geography = "tract",
                                  year = 2017,
                                  survey = "acs5",
                                  state = "OR",
                                  variables = c(below = "B17001_002",
                                                below = "B17001_018",
                                                above = "B17001_033",
                                                above = "B17001_047")) %>%
  clean_names() %>%
  group_by(geoid, variable) %>% 
  summarize(poverty_status = sum(estimate)) %>% 
  ungroup() %>% 
  group_by(geoid) %>%
  mutate(pct = prop.table(poverty_status)) %>% 
  ungroup() %>% 
  mutate(plot_label = percent(pct, 0.1)) %>% 
  select(geoid, poverty_status, pct, plot_label) %>% 
  mutate(measure = "Medicare Recipients") %>% 
  select(measure, geoid, pct, plot_label) %>% 
  dk_set_community_attribute_names() %>% 
  dk_remove_nan()


# Home Language -----------------------------------------------------------

# For population 5-17

home_language <- get_acs(geography = "tract",
                         year = 2017,
                         survey = "acs5",
                         state = "OR",
                         summary_var = "B16007_002",
                         variables = c(English = "B16007_003",
                                       Spanish = "B16007_004",
                                       `Other Indo-European Languages` = "B16007_005",
                                       `Asian and Pacific Island Languages` = "B16007_006")) %>%
  clean_names() %>% 
  mutate(pct = estimate / summary_est) %>% 
  mutate(measure = str_glue("Percent of Children 5-17 Who Speak {variable} at Home")) %>% 
  mutate(label = percent(pct, 0.1)) %>% 
  select(measure, geoid, pct, label) %>% 
  dk_set_community_attribute_names() %>% 
  dk_remove_nan() 


# Parental Employment -------------------------------------------------------


  
# Create and write community_attributes data frame ------------------------

community_attributes <- bind_rows(median_income_children_under_18,
                                  population_under_18,
                                  public_assistance,
                                  medicaid_recipients,
                                  medicare_recipients,
                                  foster_care,
                                  snap,
                                  home_language,
                                  poverty_status_under_5,
                                  race_ethnicity) %>% 
  mutate(measure_sentence_case = str_to_sentence(measure)) %>% 
  mutate(plot_label = str_glue("{measure_sentence_case} in this census tract: {label}"))


write_csv(community_attributes, "data-clean/community-attributes.csv")




