
# Packages ----------------------------------------------------------------

library(tidyverse)
library(tigris)
library(janitor)
library(sf)
library(mapdeck)
library(shinyWidgets)



# Get Data ----------------------------------------------------------------

community_attributes_vector <- read_csv("data-clean/community-attributes.csv") %>% 
  distinct(measure) %>% 
  pull(measure)


# UI ----------------------------------------------------------------------

ui <- fillPage(
  includeCSS("style.css"),
  mapdeckOutput(outputId = "map",
                height = "100%"),
  titlePanel("Oregon Early Childhood Needs Assessment"),
  absolutePanel(id = "controls", 
                class = "panel panel-default", 
                fixed = TRUE,
                draggable = TRUE, 
                top = 50, 
                left = 50, 
                right = 10, 
                bottom = "auto",
                width = 450, 
                height = "auto",
                # h1("Oregon Early Childhood Needs Assessment"),
                # icon("calendar"),
                h3("Child Care Facilities"),
                sliderTextInput(
                  # post = "children",
                  inputId = "capacity",
                  label = "Capacity", 
                  choices = seq(1, 100, by = 1),
                  select = c(1, 100),
                  width = "90%"
                ),
                awesomeCheckboxGroup(inputId = "regulation_status",
                                     label = "Regulation Status", 
                                     inline = TRUE,
                                     choices = c("Registered", "Certified", "Exempt", "Recorded"),
                                     selected = c("Registered", "Certified", "Exempt", "Recorded")),
                awesomeCheckboxGroup(inputId = "qris_input",
                                     label = "QRIS Rating",
                                     inline = TRUE,
                                     choices = c("1", "2", "3", "4", "5", "No Rating"),
                                     selected = c("1", "2", "3", "4", "5", "No Rating")),
                awesomeCheckboxGroup(inputId = "other",
                                     label = "Other",
                                     inline = TRUE,
                                     choices = c("Accepts DHS", 
                                                 "Head Start", 
                                                 "Relief Nursery"),
                                     selected = c("Accepts DHS", 
                                                  "Head Start", 
                                                  "Relief Nursery")),
               
                h3("Kindergarten Assessment"),
                awesomeRadio(
                  inputId = "kindergarten_assessment",
                  label = NULL, 
                  inline = TRUE,
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
                ),
                h3("Early Learning Hubs"),
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
                ),
                h3("Community Attributes"),
                # p("To see data about communities, select one of the options below."),
                pickerInput(
                  inputId = "community_attribute",
                  width = "90%",
                  label = NULL, 
                  choices = community_attributes_vector,
                  selected = "Diversity Index"
                )
  )
)

