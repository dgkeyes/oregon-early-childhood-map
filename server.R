
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
  
  # school_district_boundaries_reactive() <- reactive({
  #   if (input$district_boundaries == TRUE) {
  #     school_district_boundaries
  #   }
  #   if (input$district_boundaries == FALSE) {
  #     school_district_boundaries %>% 
  #       slice(1)
  #   }
  # })
  
  icons <- awesomeIcons(
    icon = 'graduation-cap',
    iconColor = "white",
    library = 'fa',
    markerColor = "green"
  )
  
  
  
  output$map <- renderLeaflet(
    
    # pal <- colorNumeric(
    #   palette = "Blues",
    #   domain = community_attributes_filtered()$value
    # )
    
    leaflet() %>% 
      addProviderTiles(providers$CartoDB.Positron) %>% 
      setView(lng = -122.75, lat = 44.055043, zoom = 6) %>%
      addAwesomeMarkers(data = child_care_facilities_filtered(),
                        clusterOptions = markerClusterOptions(),
                        icon = icons,
                        popup = ~popup_content) %>% 
      # addPolygons(data = school_district_boundaries_reactive(),
      #             fillColor = "orange") %>% 
      addPolygons(data = community_attributes_filtered(),
                  weight = 0,
                  color = "transparent",
                  opacity = 1,
                  label = ~plot_label,
                  highlightOptions = highlightOptions(color = "white", 
                                                      weight = 2,
                                                      bringToFront = TRUE),
                  fillColor = ~colorNumeric("Blues", value)(value)) 
      # addLegend("bottomright", 
      #           pal = pal, 
      #           values = ~value,
      #           # title = "Est. GDP (2010)",
      #           # labFormat = labelFormat(prefix = "$"),
      #           opacity = 1
      # )
    
    
    
  )
  
}


