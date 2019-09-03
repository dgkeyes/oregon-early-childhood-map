
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

base_radius <- 50

server <- function(input, output) {
  

# Data --------------------------------------------------------------------
  
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

  
  
  
  

# Output Map --------------------------------------------------------------


  
  output$map <- renderMapdeck({
    mapdeck(style = mapdeck_style("light"),
            token = mapbox_token,
            pitch = 5,
            zoom = 6,
            location = c(-122.75, 44.055043)) 
  })
  

# Community Attributes ----------------------------------------------------

  
  icons <- awesomeIcons(
    icon = 'graduation-cap',
    iconColor = "white",
    library = 'fa',
    markerColor = "green"
  )
  
  observeEvent({input$community_attribute},{
    
    mapdeck_update(map_id = "map") %>% 
      add_sf(data = community_attributes_filtered(),
             fill_colour = "value",
             fill_opacity = 150,
             auto_highlight = FALSE,
             highlight_colour = "#ffffff99",
             tooltip = "plot_label",
             legend = TRUE,
             palette = "blues",
             update_view = FALSE,
             # legend_format = list( fill_colour = percent_format ),
             legend_options = list(title = community_attributes_filtered()$measure,
                                   digits = 1),
             na_colour = "#fafafa") 

    
  })
  

# District Boundaries -----------------------------------------------------

  
  
  observeEvent({input$district_boundaries},{
    
    if (input$district_boundaries == TRUE) {
      mapdeck_update(map_id = "map") %>% 
        add_sf(data = school_district_boundaries_reactive(),
               fill_opacity = 1,
               fill_colour = "transparent",
               auto_highlight = TRUE,
               highlight_colour = paste0(ode_green, "25"),
               stroke_colour = ode_green,
               stroke_width = 75,
               tooltip = "name",
               update_view = FALSE,
               layer_id = "school_districts")
    } else {
      mapdeck_update(map_id = "map") %>% 
        clear_path(layer_id = "school_districts")
    }
    
  })
  

# Early Learning Programs -------------------------------------------------

  
  
  observeEvent({c(input$capacity, input$regulation_status, input$facility_location, input$qris_input)},{
    
    mapdeck_update(map_id = "map") %>% 
      add_scatterplot(data = child_care_facilities_filtered(),
                      radius_max_pixels = base_radius / 10,
                      radius_min_pixels = base_radius / 30,
                      radius = base_radius,
                      tooltip = "popup_content",
                      # fill_colour = "facility_location",
                      fill_colour = ode_orange,
                      auto_highlight = TRUE,
                      update_view = FALSE,
                      layer_id = "child_care_facilities_layer") 
    
    
  })
  

# Schools -----------------------------------------------------------------

  
  
  observeEvent({input$show_schools},{
    
    if (input$show_schools == TRUE) {
      mapdeck_update(map_id = "map") %>% 
        add_scatterplot(data = schools_filtered(),
                        fill_colour = ode_green,
                        fill_opacity = 150,
                        radius_max_pixels = base_radius / 5,
                        radius = base_radius * 2,
                        tooltip = "popup_content",
                        update_view = FALSE,
                        layer_id = "schools_layer")
      
    } else{
      mapdeck_update(map_id = "map") %>% 
        clear_path(layer_id = "schools_layer")
    }
    
  })
  
}


