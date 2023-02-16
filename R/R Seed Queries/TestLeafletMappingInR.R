library(leaflet)
library(RColorBrewer)
library(dplyr)
library(geosphere)
require("colorRamps")


lat_ca <- 39.164141
lon_ca <- -121.640625
lat_me <- 45.213004
lon_me <- -68.906250
lat_tx <- 29.954935
lon_tx <- -98.701172

california <- cbind( lon_ca, lat_ca)
mexico <- cbind( lon_me, lat_me)
texas <- cbind( lon_tx, lat_tx)

cal_to_mex <- cbind( california, mexico)
cal_to_texas <- cbind( california, texas)
texas_to_mexico <- cbind( texas, mexico)

dataset<- data.frame( lon1 = numeric(), lat1 = numeric(), lon2 = numeric(), lat2 = numeric() )

dataset <- as.data.frame( rbind( cal_to_mex, cal_to_texas, texas_to_mexico)[,] )

names(dataset) <- c("Lon1", "Lat1", "Lon2", "Lat2")

NumberOfSegments = 50

flows <- gcIntermediate( cbind(dataset$Lon1, dataset$Lat1), cbind(dataset$Lon2, dataset$Lat2)
                        ,n = NumberOfSegments
                        ,addStartEnd = TRUE
                        #,sp = TRUE
                        )

inter <- gcIntermediate( cbind(dataset$Lon1, dataset$Lat1), cbind(dataset$Lon2, dataset$Lat2)
                         ,n = NumberOfSegments
                         ,addStartEnd = TRUE
                         ,sp = TRUE
)


length(flows)

LatLongData<- data.frame( )
Lat <- data.frame( )
Long <- data.frame( )
RowNumber <- data.frame( )
id <- data.frame()


for (j in 1:length(flows) ) {
    Lat = union_all( Lat, as.data.frame(flows[[j]][,1] ) )
    Long = union_all( Long, as.data.frame(flows[[j]][,2] ) )
    RowNumber = union_all(RowNumber, as.data.frame(rep(j,NumberOfSegments + 2 ) ) )
    id = union_all( id, as.data.frame(1:( NumberOfSegments + 2 ) ) )
}


LatLongData <- cbind( Lat, Long, RowNumber, id )


hover <- paste0("I will have data relevant to my lines in here")

ColorPallete <- colorFactor( blue2red( n = (NumberOfSegments + 2 ) ) , LatLongData$`1:(NumberOfSegments + 2)` )


leaflet() %>%
  addProviderTiles('CartoDB.Positron') %>%
  addPolylines(data = inter
               #,weight = ~counts
               ,popup = hover
               ,opacity = 0
               #,group = ~origins
               #,color = ~pal(origins)
               #,options = popupOptions( keepInView = FALSE, closeButton = TRUE)
  ) %>%
 # addLayersControl(overlayGroups = unique(flows$origins)
 #                  ,options = layersControlOptions( collapsed = FALSE )
 #                  )
  addCircleMarkers(data = LatLongData
                   ,lng = ~`flows[[j]][, 1]`
                   ,lat = ~`flows[[j]][, 2]`
                   ,radius = 3
                   ,opacity = 0.2 
                   #,popup = hover  )
                   ,fill = FALSE
                   ,color = ~ColorPallete( LatLongData$`1:(NumberOfSegments + 2)` ) 
                   #,FillColor = ~ColorPallete( LatLongData$`1:(NumberOfSegments + 2)`)
                   )