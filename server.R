
# Packages ----------------------------------------------------------------

library(tidyverse)
library(tigris)
library(janitor)
library(sf)
library(shinyjs)
library(leaflet)
library(mapdeck)
library(scales)


# Colors ------------------------------------------------------------------

# Taken from https://oregonearlylearning.com/

ode_green <- "#408740"
ode_red <- "#DF3416"
ode_magenta <- "#9f2065"
ode_orange <- "#e26b2a"
ode_blue <- "#1b75bc"


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
      filter(capacity >= input$capacity[1] & capacity <= input$capacity[2]) %>% 
      filter(facility_location %in% input$facility_location)
  })
  
  community_attributes_filtered <- reactive({
    community_attributes %>%
      filter(measure == input$community_attribute)
  })
  
  schools_filtered <- reactive({
    schools
  })
  
  school_district_boundaries_reactive <- reactive({
    school_district_boundaries
  })
  
  # school_district_boundaries_reactive <- reactive({
  #   if (input$district_boundaries == TRUE) {
  #     school_district_boundaries
  #   }
  #   else (input$district_boundaries == FALSE) {
  #     school_district_boundaries %>%
  #       slice(1)
  #   }
  # })
  
  
  
  
  output$map <- renderMapdeck({
    mapdeck(style = mapdeck_style("light"),
            token = mapbox_token,
            pitch = 5,
            zoom = 6,
            location = c(-122.75, 44.055043)) 
  })
  
  observeEvent({input$community_attribute},{
    
    mapdeck_update(map_id = "map") %>% 
      add_sf(data = community_attributes_filtered(),
             fill_colour = "value",
             fill_opacity = 75,
             auto_highlight = FALSE,
             highlight_colour = "#ffffff99",
             tooltip = "plot_label",
             legend = TRUE,
             palette = "blues",
             update_view = FALSE,
             # legend_format = list( fill_colour = percent_format ),
             legend_options = list(title = community_attributes_filtered()$measure,
                                   digits = 1),
             na_colour = "#fafafa") %>% 
      add_scatterplot(data = schools_filtered(),
                      fill_colour = paste0(ode_magenta, "99"),
                      radius_max_pixels = 5,
                      radius_min_pixels = 250,
                      radius = 250,
                      tooltip = "popup_content",
                      layer_id = "schools") %>% 
      add_scatterplot(data = child_care_facilities_filtered(),
                      radius_max_pixels = 5,
                      radius_min_pixels = 25,
                      radius = 250,
                      tooltip = "popup_content",
                      fill_colour = "facility_location",
                      palette = "cividis",
                      auto_highlight = TRUE,
                      update_view = FALSE,
                      layer_id = "child_care_facilities_layer") 
      # add_sf(data = school_district_boundaries_reactive(),
      #        fill_opacity = 1,
      #        fill_colour = "transparent",
      #        auto_highlight = TRUE,
      #        highlight_colour = "#9f206525",
      #        stroke_colour = ode_magenta,
      #        stroke_width = 75,
      #        tooltip = "name",
      #        update_view = FALSE,
      #        layer_id = "school_districts") 
 
      
    
  })
  
  
  
  
}


