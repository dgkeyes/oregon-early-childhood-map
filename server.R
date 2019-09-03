
# Packages ----------------------------------------------------------------

library(tidyverse)
library(tigris)
library(janitor)
library(sf)
library(shinyjs)
library(leaflet)


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
  
  # school_district_boundaries_reactive() <- reactive({
  #   school_district_boundaries
  # })
  
  # school_district_boundaries_reactive() <- reactive({
  #   if (input$district_boundaries == TRUE) {
  #     school_district_boundaries
  #   }
  #   if (input$district_boundaries == FALSE) {
  #     school_district_boundaries %>%
  #       slice(1)
  #   }
  # })
  
  
  
  child_care_facilities_pal <- colorFactor(
    palette = c(ode_orange, ode_green), 
    levels = c("Home-Based", "Center-Based")
  )
  
  
  output$map <- renderLeaflet(
    
    leaflet() %>% 
      addProviderTiles(providers$CartoDB.Positron) %>% 
      setView(lng = -122.75, lat = 44.055043, zoom = 6) %>%
      addPolygons(data = community_attributes_filtered(),
                  group = "Community Attributes",
                  weight = 0,
                  color = "transparent",
                  # opacity = 1,
                  fillOpacity = .5,
                  label = ~plot_label,
                  highlightOptions = highlightOptions(color = "white",
                                                      weight = 2,
                                                      bringToFront = FALSE),
                  fillColor = ~colorNumeric("Blues", value,
                                            na.color = "#eeeeee")(value)) %>% 
      addCircles(data = schools_filtered(),
                 color = ode_magenta,
                 opacity = 1,
                 fillOpacity = .7,
                 radius = 100) %>%
      addCircles(data = child_care_facilities_filtered(),
                 group = "Child Care Facilities",
                 color = ~child_care_facilities_pal(facility_location),
                 opacity = 1,
                 fillOpacity = .7,
                 radius = 100,
                 # icon = child_care_icons,
                 popup = ~popup_content) 
    # addPolygons(data = school_district_boundaries_reactive(),
    #             fillColor = "orange") 
    # addPolygons(data = early_learning_hubs_regions) %>% 
    # addMarkers(data = early_learning_hubs_locations) %>% 

    # addLayersControl(overlayGroups = c("Child Care Facilities",
    #                                    "Community Attributes") ,
    #                  position = "bottomright",
    #                  options = layersControlOptions(collapsed = FALSE))
    # addLegend("bottomright", 
    #           pal = pal, 
    #           values = ~value,
    #           # title = "Est. GDP (2010)",
    #           # labFormat = labelFormat(prefix = "$"),
    #           opacity = 1
    # )
    
    
    
  )
  
}


