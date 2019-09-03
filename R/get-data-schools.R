
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
library(nominatim)


# School Enrollment -------------------------------------------------------


# download.file("https://www.oregon.gov/ode/reports-and-data/students/Documents/fallmembershipreport_20182019.xlsx",
#               destfile = "data-raw/school-enrollment-1819.xlsx")

school_enrollment <- read_excel("data-raw/school-enrollment-1819.xlsx",
                                sheet = "School (18-19)",
                                na = "-") %>% 
  clean_names() 

# Schools -----------------------------------------------------------------

# download.file("https://www.ode.state.or.us/ftp/incoming/inst_db_extract_XL8.zip",
#               destfile = "data-raw/oregon-schools-1819.zip") 
# 
# unzip("data-raw/oregon-schools-1819.zip",
#       exdir = "data-raw")
# 
# file_move("data-raw/Inst_Db_Extract_xl8.xls",
#           "data-raw/oregon-schools-1819.xls")
# 
# file_delete("data-raw/oregon-schools-1819.zip")

# oregon_schools <- read_excel("data-raw/oregon-schools-1819.xls") %>% 
#   clean_names() %>% 
#   mutate(iid = as.numeric(iid)) %>% 
#   inner_join(school_enrollment, by = c("iid" = "attending_school_institutional_id")) %>% 
#   distinct(iid, .keep_all = TRUE) %>% 
#   select(-c(x2018_19_kindergarten:x2018_19_grade_twelve)) %>% 
#   select(-c(directory_name:geo_areatype)) %>% 
#   select(-contains("mail")) %>% 
#   select(-contains("phone")) %>% 
#   select(-street_str_addr2) %>% 
#   select(-director_name) %>% 
#   mutate(address = paste(street_str_addr1,
#                          street_city,
#                          street_state,
#                          street_zip)) %>%
#   mutate_geocode(address) 
#
# write_csv(oregon_schools, 
#           "data-clean/oregon-schools-geocoded.csv",
#           na = "")

# Kindergarten Readiness --------------------------------------------------

# Download Files

# download.file("https://www.oregon.gov/ode/educator-resources/assessment/Documents/KA_Media_1819.xlsx",
#               destfile = "data-raw/kindergarten-readiness-1819.xlsx")

kindergarten_readiness <- read_excel("data-raw/kindergarten-readiness-1819.xlsx",
                                     skip = 6,
                                     na = "*") %>%
  slice(-(1:5)) %>%
  set_names(c("county",
              "district_id",
              "district_name",
              "institution_id",
              "institution_name",
              "institution_type",
              "student_group_type",
              "student_group",
              "approaches_to_learning_self_regulation_score",
              "approaches_to_learning_interpersonal_skills_score",
              "approaches_to_learning_total_score_score",
              "approaches_to_learning_n",
              "math_avg_number_correct_score",
              "math_n",
              "literacy_uppercase_letter_names_number_correct_score",
              "literacy_uppercase_letter_names_number_correct_n",
              "literacy_lowercase_letter_names_number_correct_score",
              "literacy_lowercase_letter_names_number_correct_n",
              "literacy_letter_sounds_number_correct_score",
              "literacy_letter_sounds_number_correct_n")) 

kindergarten_readiness_state_avgs <- kindergarten_readiness %>% 
  filter(institution_type == "State")
  

kindergarten_readiness_by_school <- kindergarten_readiness %>% 
  filter(student_group == "Total Population") %>% 
  filter(institution_type == "School")


  

# Load geocoded schools data

schools <- read_csv("data-clean/oregon-schools-geocoded.csv") %>% 
  left_join(kindergarten_readiness_by_school, by = c("iid" = "institution_id")) 


# Write to CSV

write_csv(schools,
          "data-clean/oregon-schools.csv",
          na = "")


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
