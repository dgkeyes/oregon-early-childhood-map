
# Packages ----------------------------------------------------------------

library(tidyverse)
library(tigris)
library(janitor)
library(sf)
library(mapdeck)


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

school_district_boundaries <- st_read("data-clean/school-district-boundaries.shp") %>% 
  st_as_sf(crs = 3857)

community_attributes <- read_csv("data-clean/community-attributes.csv") %>% 
  mutate(tract_id = as.character(tract_id)) %>% 
  right_join(oregon_census_tracts, by = c("tract_id" = "geoid")) %>% 
  st_as_sf(crs = 3857)

child_care_facilities <- read_csv("data-clean/child-care-facilities-geocoded.csv") %>% 
  st_as_sf(coords = c("lon", "lat"),
           crs = 3857)


# Server ------------------------------------------------------------------

mapbox_token <- Sys.getenv("MAPBOX_PUBLIC_TOKEN")

set_token(mapbox_token)



server <- function(input, output) {
  
  child_care_facilities_filtered <- reactive({
    child_care_facilities %>%
      filter(qris_stars == input$qris_input)
  })
  
  community_attributes_filtered <- reactive({
    community_attributes %>%
      filter(measure == input$community_attribute)
  })
  
  output$map <- renderMapdeck(
    mapdeck(style = mapdeck_style("light"),
            token = mapbox_token,
            pitch = 15) %>%
      add_sf(data = community_attributes_filtered(),
             auto_highlight = TRUE,
             fill_colour = "value",
             fill_opacity = 150,
             tooltip = "value",
             legend = TRUE,
             legend_options = list(title = community_attributes_filtered()$measure),
             na_colour = "#eeeeee",
             focus_layer = TRUE) %>% 
      add_sf(data = child_care_facilities_filtered(),
             radius = 2500,
             tooltip = "facility_name",
             fill_colour = oregon_orange,
             auto_highlight = TRUE,
             focus_layer = TRUE) %>%
      # add_sf(data = school_district_boundaries,
      #        fill_opacity = 100,
      #        auto_highlight = TRUE,
      #        highlight_colour = "#ffffff99",
      #        stroke_colour = "#000000",
      #        stroke_width = 100) %>%
      mapdeck_view(zoom = 6,
                   location = c(-122.75, 44.055043))
    
  )
  
}


