
# Packages ----------------------------------------------------------------

library(shiny)
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

child_care_facilities <- read_csv("data/child-care-facilities-geocoded.csv") %>% 
  st_as_sf(coords = c("lon", "lat"),
           crs = 3857)




diversity_index <- read_csv("data/diversity-index.csv") %>% 
  clean_names() %>% 
  mutate(diversity = divindx_cy * 500) %>% 
  mutate(geoid = as.character(geoid10)) %>% 
  right_join(oregon_census_tracts) %>% 
  st_as_sf(crs = 3857) 


# UI ----------------------------------------------------------------------

ui <- fluidPage(
  titlePanel("Oregon Early Childhood Needs Assessment"),
  sidebarLayout(
    sidebarPanel(
      # sliderInput("priceInput", "Price", 0, 100, c(25, 40), pre = "$"),
      # radioButtons("typeInput", "Product type",
      #              choices = c("BEER", "REFRESHMENT", "SPIRITS", "WINE"),
      #              selected = "WINE"),
      selectInput(inputId = "qris_input", 
                  label = "QRIS Rating",
                  choices = c("1", "2", "3", "4", "5", "Missing"))
    ),
    mainPanel(
      mapdeckOutput(outputId = "map")
    )
  )
)


# Server ------------------------------------------------------------------

set_token(Sys.getenv("MAPBOX_PUBLIC_TOKEN"))

server <- function(input, output) {
  
  child_care_facilities_filtered <- reactive({
    child_care_facilities %>%
      filter(city == input$qris_input)
  })
  
  output$map <- renderMapdeck(
    mapdeck(style = mapdeck_style("light"),
            pitch = 0 ) %>%
      add_sf(data = child_care_facilities_filtered,
             radius = 2500,
             tooltip = "facility_name",
             fill_colour = oregon_orange,
             auto_highlight = TRUE,
             focus_layer = TRUE)
  )
}



shinyApp(ui = ui, server = server)