
# Packages ----------------------------------------------------------------

library(tidyverse)
library(tigris)
library(janitor)
library(sf)
library(mapdeck)
library(shinyWidgets)
library(shinyjs)
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
                        
                        leafletOutput(outputId = "map",
                                      height = "100%"),
                        
                        
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
                                      bs_accordion(id = "beatles") %>%
                                        bs_set_opts(panel_type = "primary", use_heading_link = TRUE) %>%
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
                                                        width = "90%"
                                                      ),
                                                      awesomeCheckboxGroup(inputId = "regulation_status",
                                                                           label = "Regulation Status",
                                                                           inline = TRUE,
                                                                           choices = c("Registered", "Certified", "Exempt", "Recorded"),
                                                                           selected = c("Registered", "Certified", "Exempt", "Recorded")),
                                                      awesomeCheckboxGroup(inputId = "qris_input",
                                                                           label = "Spark Rating",
                                                                           inline = TRUE,
                                                                           choices = c("C2Q", "3", "4", "5", "No Rating"),
                                                                           selected = c("C2Q", "3", "4", "5", "No Rating")),
                                                      awesomeCheckboxGroup(inputId = "other",
                                                                           label = "Other",
                                                                           inline = TRUE,
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
                                                  content =  awesomeRadio(
                                                    inputId = "community_attribute",
                                                    width = "90%",
                                                    label = NULL,
                                                    choices = community_attributes_vector
                                                  ))
                                      
                                      
                                      
                        )
                        
                        
                    )),
           
           tabPanel("Data Explorer")
)



