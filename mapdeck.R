mapdeck( token = "pk.eyJ1IjoiZGdrZXllcyIsImEiOiJ2WGFJQ2U0In0.ftoZlfudaEIJL7OEf-Mw3Q", style = mapdeck_style("dark"), pitch = 45 ) %>%
  add_grid(
    data = df
    , lat = "lat"
    , lon = "lng"
    , cell_size = 5000
    , elevation_scale = 50
    , layer_id = "grid_layer"
  )
