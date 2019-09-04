
# Packages ----------------------------------------------------------------

library(tidyverse)
library(tigris)
library(janitor)
library(sf)
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
      filter(capacity >= input$capacity[1] & capacity <= input$capacity[2]) %>% 
      filter(facility_location %in% input$facility_location)
  })
  
  community_attributes_filtered <- reactive({
    community_attributes %>%
      filter(measure == input$community_attribute)
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
  
  icons <- awesomeIcons(
    icon = 'child',
    iconColor = "white",
    library = 'fa',
    markerColor = "green"
  )
  
  
  child_care_icons <- icons(
    iconUrl = case_when(
      child_care_facilities$facility_location == "Home-Based" ~ "assets/child-care-home.png",
      child_care_facilities$facility_location == "Center-Based" ~ "assets/child-care-center.png"
    ),
    iconWidth = 35,
    iconHeight = 46
  )
  
  
  output$map <- renderLeaflet(
    
    
    
    
    leaflet() %>% 
      addProviderTiles(providers$CartoDB.Positron) %>% 
      setView(lng = -122.75, lat = 44.055043, zoom = 6) %>%
      addMarkers(data = child_care_facilities_filtered(),
                 clusterOptions = markerClusterOptions(showCoverageOnHover = FALSE,
                                                       iconCreateFunction =
                                                         JS("
                                          function(cluster) {
                                             return new L.DivIcon({
                                               html: '<div style=\"background-color:#9e9e9e\"><span>' + cluster.getChildCount() + '</div><span>',
                                               className: 'marker-cluster'
                                             });
                                           }")),
                 group = "Child Care Facilities",
                 icon = child_care_icons,
                 popup = ~popup_content) %>% 
      # addPolygons(data = school_district_boundaries_reactive(),
      #             fillColor = "orange") %>%
      # addPolygons(data = early_learning_hubs_regions) %>% 
      # addMarkers(data = early_learning_hubs_locations) %>% 
      addPolygons(data = community_attributes_filtered(),
                  group = "Community Attributes",
                  weight = 0,
                  color = "transparent",
                  # opacity = 1,
                  fillOpacity = .5,
                  label = ~plot_label,
                  highlightOptions = highlightOptions(color = "white", 
                                                      weight = 2,
                                                      bringToFront = TRUE),
                  fillColor = ~colorNumeric("Blues", value,
                                            na.color = "#eeeeee")(value)) 
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


