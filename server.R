
# Packages ----------------------------------------------------------------

library(tidyverse)
library(tigris)
library(janitor)
library(sf)
library(mapdeck)
library(leaflet)
library(tmap)


# Colors ------------------------------------------------------------------

# Taken from https://oregonearlylearning.com/

oregon_green <- "#007065"
oregon_red <- "#DF3416"
oregon_orange <- "#f78300"


# Get data -------------------------------------------------------------

options(tigris_class = "sf")

oregon_counties <- counties(state = "Oregon",
                            cb = TRUE) %>% 
  clean_names()

oregon_census_tracts <- tracts(state = "Oregon",
                               cb = TRUE) %>% 
  clean_names()

community_attributes <- read_csv("data-clean/community-attributes.csv") %>% 
  mutate(tract_id = as.character(tract_id)) %>% 
  right_join(oregon_census_tracts, by = c("tract_id" = "geoid")) %>% 
  st_as_sf(crs = 3857)

child_care_facilities <- read_csv("data-clean/child-care-facilities-geocoded.csv") %>% 
  st_as_sf(coords = c("lon", "lat"),
           crs = 3857)


# Server ------------------------------------------------------------------

set_token(Sys.getenv("MAPBOX_PUBLIC_TOKEN"))



server <- function(input, output) {
  
  child_care_facilities_filtered <- reactive({
    child_care_facilities %>%
      filter(qris_stars == input$qris_input)
  })
  
  
  community_attributes_filtered <- reactive({
    community_attributes %>%
      filter(measure == input$community_attribute)
  })
  
  
  # output$map <- renderLeaflet(
  #   leaflet() %>%
  #     addProviderTiles(providers$CartoDB.Positron) %>%
  #     addMarkers(data = child_care_facilities_filtered()) %>% 
  #     addPolygons(data = community_attributes_filtered,
  #                 fillOpacity = .75,
  #                 fillColor = ~pal(value))
  # )
  
  output$map <- renderLeaflet(
    dk_map <- tm_basemap(leaflet::providers$Stamen.TerrainBackground) +
      tm_shape(community_attributes) +
      tm_polygons()
    
    tmap_leaflet(dk_map)
  )
  
}


