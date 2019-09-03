
# Packages ----------------------------------------------------------------

library(tidyverse)
library(tigris)
library(janitor)
library(sf)
library(mapdeck)
library(shinyWidgets)
library(bsplus)



# Get Data ----------------------------------------------------------------

source("R/load-data.R")


# UI ----------------------------------------------------------------------

includeCSS("style.css")
# includeCSS("tailwind.css")

navbarPage("Oregon Early Childhood Needs Assessment", id = "nav",
           
           tabPanel("Interactive Map",
                    
                    includeCSS("style.css"),
                    
                    div(class = "outer",
                        
                        mapdeckOutput(outputId = "map",
                                      height = "100%"),
                        # absolutePanel(id = "legend",
                        #               class = "panel panel-default",
                        #               fixed = TRUE,
                        #               draggable = FALSE,
                        #               top = 10,
                        #               left = 450,
                        #               right = 10,
                        #               bottom = "auto",
                        #               width = 475,
                        #               height = "auto",
                        #               h1("Test")),
                                      
                        absolutePanel(id = "controls",
                                      class = "panel panel-default",
                                      fixed = TRUE,
                                      draggable = TRUE,
                                      top = 100,
                                      left = 50,
                                      right = 10,
                                      bottom = "auto",
                                      width = 475,
                                      height = "auto",
                                      # h1("Oregon Early Childhood Needs Assessment"),
                                      # p("Lorem ipsum dolor amet shabby chic iceland squid, biodiesel scenester intelligentsia mixtape live-edge brooklyn chartreuse. Adaptogen poutine aesthetic slow-carb single-origin coffee la croix vexillologist."),
                                      bs_accordion(id = "dk_accordion") %>%
                                        bs_set_opts(panel_type = "primary", use_heading_link = TRUE) %>%
                                        bs_append("Legend", content = 
                                                    p("Test")) %>% 
                                        bs_append(title = "Early Learning Programs", content =
                                                    list(
                                                      sliderTextInput(
                                                        # post = "children",
                                                        inputId = "capacity",
                                                        label = "Capacity",
                                                        choices = seq(min(child_care_facilities$capacity, na.rm = TRUE),
                                                                      max(child_care_facilities$capacity, na.rm = TRUE),
                                                                      by = 1),
                                                        select = c(min(child_care_facilities$capacity, na.rm = TRUE),
                                                                   max(child_care_facilities$capacity, na.rm = TRUE)),
                                                        width = "70%"
                                                      ),
                                                      pickerInput(inputId = "regulation_status",
                                                                  label = "Regulation Status",
                                                                  choices = c("Registered", "Certified", "Exempt", "Recorded"),
                                                                  selected = c("Registered", "Certified", "Exempt", "Recorded"),
                                                                  multiple = TRUE,
                                                                  options = list(
                                                                    `actions-box` = TRUE,
                                                                    title = "Please select an option ...")),
                                                      awesomeCheckboxGroup(inputId = "facility_location",
                                                                           label = "Facility Location",
                                                                           inline = TRUE,
                                                                           choices = c("Home-Based", "Center-Based"),
                                                                           selected = c("Home-Based", "Center-Based")),
                                                      awesomeCheckboxGroup(inputId = "qris_input",
                                                                           label = "Spark Rating",
                                                                           inline = TRUE,
                                                                           choices = c("C2Q", "3", "4", "5", "No Rating"),
                                                                           selected = c("C2Q", "3", "4", "5", "No Rating")),
                                                      awesomeCheckboxGroup(inputId = "other",
                                                                           label = "Also Show",
                                                                           # inline = TRUE,
                                                                           choices = c("Accepts DHS",
                                                                                       "Head Start",
                                                                                       "Relief Nursery"),
                                                                           selected = c("Accepts DHS",
                                                                                        "Head Start",
                                                                                        "Relief Nursery"))
                                                    )) %>%
                                        bs_append(title = "Systems",
                                                  content =  list(
                                                    p("Early Learning Hubs"),
                                                    prettySwitch(
                                                      inputId = "hub_location",
                                                      label = "Show Locations",
                                                      value = FALSE,
                                                      status = "primary"
                                                    ),
                                                    prettySwitch(
                                                      inputId = "hub_areas",
                                                      label = "Show Areas Served",
                                                      value = FALSE,
                                                      status = "primary"
                                                    ))) %>% 
                                        bs_append(title = "Schools", content = list(
                                          p("Oregon Kindergarten Readiness Assessment Results"),
                                          awesomeRadio(
                                            inputId = "kindergarten_assessment",
                                            label = NULL,
                                            # inline = TRUE,
                                            choices = c("Early Math",
                                                        "Early Reading",
                                                        "Approaches to Learning"),
                                            selected = "Early Math"
                                          ),
                                          prettySwitch(
                                            inputId = "district_boundaries",
                                            label = "Show School District Boundaries",
                                            value = FALSE,
                                            status = "primary"
                                          )
                                          
                                        )) %>%
                                      bs_append(title = "Communities",
                                                content =  pickerInput(
                                                  inputId = "community_attribute",
                                                  # options = list(title = "Race/Ethnicity: White"),
                                                  choices = list(
                                                    `Race/Ethnicity` = community_attributes_race_ethnicity,
                                                    `Language` = community_attributes_language,
                                                    `Other Measures` = community_attributes_non_race_ethnicity
                                                  )))
                              
                                      
                                      
                                      
                        )
                        
                        
                    )),
           
           tabPanel("Data Explorer")
)



