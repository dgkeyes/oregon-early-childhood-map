
# Packages ----------------------------------------------------------------

library(tidyverse)
library(tigris)
library(janitor)
library(sf)
library(mapdeck)
library(shinyjs)
library(leaflet)


# Colors ------------------------------------------------------------------

# Taken from https://oregonearlylearning.com/

oregon_green <- "#007065"
oregon_red <- "#DF3416"
oregon_orange <- "#f78300"
oregon_blue <- "#337ab7"


# Get data -------------------------------------------------------------

source("R/load-data.R")

# Server ------------------------------------------------------------------

mapbox_token <- Sys.getenv("MAPBOX_PUBLIC_TOKEN")

set_token(mapbox_token)

server <- function(input, output) {
  
  child_care_facilities_filtered <- reactive({
    child_care_facilities %>%
      filter(qris_stars %in% input$qris_input) %>%
      filter(regulation_status %in% input$regulation_status) %>%
      filter(capacity >= input$capacity[1] & capacity <= input$capacity[2])
  })
  
  community_attributes_filtered <- reactive({
    community_attributes %>%
      filter(measure == input$community_attribute)
  })
  
  school_district_boundaries_filtered <- reactive({
    if (input$district_boundaries == TRUE) {
      school_district_boundaries
    }
    if (input$district_boundaries == FALSE) {
      school_district_boundaries %>% 
        slice(1)
    }
  })
  
  
  output$map <- renderMapdeck(
    mapdeck(style = mapdeck_style("light"),
            token = "pk.eyJ1IjoiZGdrZXllcyIsImEiOiJ2WGFJQ2U0In0.ftoZlfudaEIJL7OEf-Mw3Q",
            pitch = 15) %>%
      add_sf(data = community_attributes_filtered(),
             fill_colour = "value",
             fill_opacity = 200,
             # auto_highlight = TRUE,
             # highlight_colour = "#ffffff00",
             tooltip = "value",
             legend = TRUE,
             palette = "blues",
             legend_options = list(title = community_attributes_filtered()$measure),
             na_colour = "#eeeeee") %>%
      add_scatterplot(data = child_care_facilities_filtered(),
                      radius_min_pixels = 5,
                      radius_max_pixels = 10,
                      tooltip = "location",
                      fill_colour = oregon_orange,
                      fill_opacity = 100) %>%
      # add_sf(data = school_district_boundaries_filtered(),
      #        fill_opacity = 100,
      #        auto_highlight = TRUE,
      #        highlight_colour = "#ffffff99",
      #        stroke_colour = "#000000",
      #        stroke_width = 100) %>%
      mapdeck_view(zoom = 6,
                   location = c(-122.75, 44.055043))
    
  )
  
}


