
# Packages ----------------------------------------------------------------

library(tidyverse)
library(tigris)
library(janitor)
library(sf)
library(mapdeck)
library(leaflet)



# Get Data ----------------------------------------------------------------

community_attributes_vector <- read_csv("data-clean/community-attributes.csv") %>% 
  distinct(measure) %>% 
  pull(measure)


# UI ----------------------------------------------------------------------

ui <- fluidPage(
  titlePanel("Oregon Early Childhood Needs Assessment"),
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "qris_input", 
                  label = "QRIS Rating",
                  choices = c("1", "2", "3", "4", "5", "Missing")),
      selectInput(inputId = "community_attribute", 
                  label = "Community Attribute",
                  choices = community_attributes_vector)
    ),
    mainPanel(
      leafletOutput(outputId = "map")
    )
  )
)

