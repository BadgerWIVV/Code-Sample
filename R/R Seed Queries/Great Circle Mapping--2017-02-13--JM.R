#Example comes from: https://flowingdata.com/2011/05/11/how-to-map-connections-with-great-circles/

#Step 1: Load packages
require("maps")
require("geosphere")


#Step 2: Draw Base maps
  #map("state")
  #map("world")

#Step 3: Limiting boundaries
  xlim <- c(-171.738281, -56.601563)
  ylim <- c(12.039321, 71.856229)
  map("world", col = "#f2f2f2", fill = TRUE, bg = "white", lwd = 0.05, xlim = xlim, ylim = ylim)

#Step 4: Draw connecting lines
  lat_ca <- 39.164141
  lon_ca <- -121.640625
  lat_me <- 45.213004
  lon_me <- -68.906250
  inter <- gcIntermediate(c(lon_ca, lat_ca), c(lon_me, lat_me), n = 50, addStartEnd = TRUE)
  #lines(inter)
  #points(inter, col = cm.colors( n = 52 ) ) 
  #segments(x0 = inter[1,1], y0 = inter[1,2], x1 = inter[2,1], y1 = inter[2,2], col = "blue")
  #lines(inter, col = rainbow(n = 50, s = 1, v = 1, start = 0/6, end = 2/6, alpha = 1))

  lat_tx <- 29.954935
  lon_tx <- -98.701172
  inter2 <- gcIntermediate(c(lon_ca, lat_ca), c(lon_tx, lat_tx), n = 50, addStartEnd = TRUE)
  #lines(inter2, col = "red")
  #lines(inter2, col = rainbow(n = 50, s = 1, v = 1, start = 0/6, end = 2/6, alpha = 1))
  #lines(inter2, col = cm.colors(n = 50))
  #lines(inter2, col = heat.colors(n = 50))

#Step 5: Load flight data
  airports <- read.csv("http://datasets.flowingdata.com/tuts/maparcs/airports.csv", header=TRUE) 
  flights <- read.csv("http://datasets.flowingdata.com/tuts/maparcs/flights.csv", header=TRUE, as.is=TRUE)
  
#Step 6: Draw multiple connections
  map("world", col="#f2f2f2", fill = TRUE, bg = "white", lwd = 0.05, xlim = xlim, ylim = ylim)
  
  fsub <- flights[flights$airline == "AA",]
  for (j in 1:length(fsub$airline)) {
    air1 <- airports[airports$iata == fsub[j,]$airport1,]
    air2 <- airports[airports$iata == fsub[j,]$airport2,]
    
    inter <- gcIntermediate(c(air1[1,]$long, air1[1,]$lat), c(air2[1,]$long, air2[1,]$lat), n = 100, addStartEnd=TRUE)
    
    lines(inter, col = "black", lwd = 0.8)
  }
  
#Step 7: Color for clarity
  pal <- colorRampPalette(c("#f2f2f2", "black"))
  colors <- pal(100)
  
  map("world", col="#f2f2f2", fill=TRUE, bg="white", lwd=0.05, xlim=xlim, ylim=ylim)
  
  fsub <- flights[flights$airline == "AA",]
  maxcnt <- max(fsub$cnt)
  for (j in 1:length(fsub$airline)) {
    air1 <- airports[airports$iata == fsub[j,]$airport1,]
    air2 <- airports[airports$iata == fsub[j,]$airport2,]
    
    inter <- gcIntermediate(c(air1[1,]$long, air1[1,]$lat), c(air2[1,]$long, air2[1,]$lat), n=100, addStartEnd=TRUE)
    colindex <- round( (fsub[j,]$cnt / maxcnt) * length(colors) )
    
    lines(inter, col=colors[colindex], lwd=0.8)
  }
  
  pal <- colorRampPalette(c("#f2f2f2", "black"))
  pal <- colorRampPalette(c("#f2f2f2", "red"))
  colors <- pal(100)
  
  map("world", col="#f2f2f2", fill=TRUE, bg="white", lwd=0.05, xlim=xlim, ylim=ylim)
  
  fsub <- flights[flights$airline == "AA",]
  fsub <- fsub[order(fsub$cnt),]
  maxcnt <- max(fsub$cnt)
  for (j in 1:length(fsub$airline)) {
    air1 <- airports[airports$iata == fsub[j,]$airport1,]
    air2 <- airports[airports$iata == fsub[j,]$airport2,]
    
    inter <- gcIntermediate(c(air1[1,]$long, air1[1,]$lat), c(air2[1,]$long, air2[1,]$lat), n=100, addStartEnd=TRUE)
    colindex <- round( (fsub[j,]$cnt / maxcnt) * length(colors) )
    
    lines(inter, col=colors[colindex], lwd=0.8)
  }
  
#Step 8: Map every carrier
  
  #Unique carriers
  carriers <- unique(flights$airline)
  
  #Color
  pal <- colorRampPalette(c("#333333", "white", "#1292db"))
  colors <- pal(100)
  
  #Choose carrier
  i = 1
  
  #Graph
    map("world", col="#191919", fill=TRUE, bg="#000000", lwd=0.05, xlim=xlim, ylim=ylim)
    fsub <- flights[flights$airline == carriers[i],]
    fsub <- fsub[order(fsub$cnt),]
    maxcnt <- max(fsub$cnt)
    for (j in 1:length(fsub$airline)) {
      air1 <- airports[airports$iata == fsub[j,]$airport1,]
      air2 <- airports[airports$iata == fsub[j,]$airport2,]
      
      inter <- gcIntermediate(c(air1[1,]$long, air1[1,]$lat), c(air2[1,]$long, air2[1,]$lat), n=100, addStartEnd=TRUE)
      colindex <- round( (fsub[j,]$cnt / maxcnt) * length(colors) )
      
      lines(inter, col=colors[colindex], lwd=0.6)
    }
    


  #Creates a pdf for each flight carriers paths
    #for (i in 1:length(carriers)) {
    #  
    #  pdf(paste("carrier", carriers[i], ".pdf", sep=""), width=11, height=7)
    #  map("world", col="#191919", fill=TRUE, bg="#000000", lwd=0.05, xlim=xlim, ylim=ylim)
    #  fsub <- flights[flights$airline == carriers[i],]
    #  fsub <- fsub[order(fsub$cnt),]
    #  maxcnt <- max(fsub$cnt)
    #  for (j in 1:length(fsub$airline)) {
    #    air1 <- airports[airports$iata == fsub[j,]$airport1,]
    #    air2 <- airports[airports$iata == fsub[j,]$airport2,]
    #    
    #    inter <- gcIntermediate(c(air1[1,]$long, air1[1,]$lat), c(air2[1,]$long, air2[1,]$lat), n=100, addStartEnd=TRUE)
    #    colindex <- round( (fsub[j,]$cnt / maxcnt) * length(colors) )
    #    
    #    lines(inter, col=colors[colindex], lwd=0.6)
    #  }
    #  
    #  dev.off()
    #}
    
##############################################################################################################    
##############################################################################################################
##############################################################################################################
    
#Plotly version from: https://plot.ly/r/lines-on-maps/
require("plotly")
library(plotly)
library(dplyr)

    # airport locations
    air <- read.csv('https://raw.githubusercontent.com/plotly/datasets/master/2011_february_us_airport_traffic.csv')
    # flights between airports
    flights <- read.csv('https://raw.githubusercontent.com/plotly/datasets/master/2011_february_aa_flight_paths.csv')
    
    flights$id <- seq_len(nrow(flights))
    
    # map projection
    geo <- list(
      scope = 'north america',
      projection = list(type = 'azimuthal equal area'),
      showland = TRUE,
      landcolor = toRGB("gray95"),
      countrycolor = toRGB("gray80")
    )
    
    p <- plot_geo(locationmode = 'USA-states', color = I("red") , height = 800 ) %>%
      add_markers(
        data = air, x = ~long, y = ~lat, text = ~airport,
        size = ~cnt, hoverinfo = "text", alpha = 0.5
      ) %>%
      add_segments(
        data = group_by(flights, id),
        x = ~start_lon, xend = ~end_lon,
        y = ~start_lat, yend = ~end_lat,
        alpha = 0.3, size = I(1), hoverinfo = "none"
      ) %>%
      layout(
        title = 'Feb. 2011 American Airline flight paths<br>(Hover for airport names)',
        geo = geo, showlegend = FALSE
      )
    
    p
    
    # Create a shareable link to your chart
    # Set up API credentials: https://plot.ly/r/getting-started
    #chart_link = plotly_POST(p, filename="map/flights")
    #chart_link


#London to NYC Great Circle:
    
    library(plotly)
    
    p <- plot_geo(lat = c(40.7127, 51.5072), lon = c(-74.0059, 0.1275)) %>%
      add_lines(color = I("blue"), size = I(2)) %>%
      layout(
        title = 'London to NYC Great Circle',
        showlegend = FALSE,
        geo = list(
          resolution = 50,
          showland = TRUE,
          showlakes = TRUE,
          landcolor = toRGB("grey80"),
          countrycolor = toRGB("grey80"),
          lakecolor = toRGB("white"),
          projection = list(type = "equirectangular"),
          coastlinewidth = 2,
          lataxis = list(
            range = c(20, 60),
            showgrid = TRUE,
            tickmode = "linear",
            dtick = 10
          ),
          lonaxis = list(
            range = c(-100, 20),
            showgrid = TRUE,
            tickmode = "linear",
            dtick = 20
          )
        )
      )
    
  p
  

##############################################################################################################    
##############################################################################################################
##############################################################################################################

#Leaflet version from: http://personal.tcu.edu/kylewalker/interactive-flow-visualization-in-r.html
  
  #Step 0: Get some data
  
  library(dplyr)
  
  set.seed(1983)
  
  df <- data_frame(origins = sample(c('Portugal', 'Romania', 'Nigeria', 'Peru'), 
                                    size = 100, replace = TRUE), 
                   destinations = sample(c('Texas', 'New Jersey', 'Colorado', 'Minnesota'), 
                                         size = 100, replace = TRUE))
  
  df2 <- df %>%
    group_by(origins, destinations) %>%
    summarize(counts = n()) %>%
    ungroup() %>%
    arrange(desc(counts))
  
  #Step 1: prep data
  # devtools::install_github('ropenscilabs/rnaturalearth')
  library(rnaturalearth) 
  
  countries <- ne_countries()
  
  states <- ne_states(iso_a2 = 'US')  
  
  #Step 2: Create country info
  library(rgdal)
  
  countries$longitude <- coordinates(countries)[,1]
  
  countries$latitude <- coordinates(countries)[,2]
  
  countries_xy <- countries@data %>%
    select(admin, longitude, latitude)
  
  states_xy <- states@data %>%
    select(name, longitude, latitude)
  
  #Step 3: Merge data
  df3 <- df2 %>%
    left_join(countries_xy, by = c('origins' = 'admin')) %>%
    left_join(states_xy, by = c('destinations' = 'name'))
  
  df3$longitude.y <- as.numeric(as.character(df3$longitude.y))
  
  df3$latitude.y <- as.numeric(as.character(df3$latitude.y))
  
  head(df3)
  
  #Step 4: Find line segments
  
  library(geosphere)
  
  flows <- gcIntermediate(df3[,4:5], df3[,6:7], sp = TRUE, addStartEnd = TRUE)
  
  flows$counts <- df3$counts
  
  flows$origins <- df3$origins
  
  flows$destinations <- df3$destinations
  
  #Step 5: Create the map
  
  library(leaflet)
  library(RColorBrewer)
  
  hover <- paste0(flows$origins, " to ", 
                  flows$destinations, ': ', 
                  as.character(flows$counts))
  
  pal <- colorFactor(brewer.pal(4, 'Set2'), flows$origins)
  
  leaflet() %>%
    addProviderTiles('CartoDB.Positron') %>%
    addPolylines(data = flows, weight = ~counts, popup = hover, 
                 group = ~origins, color = ~pal(origins)
                 ,options = popupOptions( keepInView = FALSE, closeButton = TRUE)
                 ) %>%
    addLayersControl(overlayGroups = unique(flows$origins), 
                     options = layersControlOptions(collapsed = FALSE))
  