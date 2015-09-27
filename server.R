## Developing Data Products - Shiny App
## server.R

## This function uses the ggmap package to get a map of North America. It also reads a csv
## from USGS on earthquake magnitudes and locations that have occurred over the past week.
## This function filters that data set to keep only the earthquakes that fall within the
## bounding box of the map. The user of this app inputs a range of earthquake magnitudes
## between 0 and 10 using a slider bar. The shiny server then subsets the USGS data to plot
## only earthquakes whose magnitudes fall within that range. From that data subset,
## the geosphere package is used to calculate the distances between a user-input location
## and all the earthquakes. The output of the server is a brief summary of the earthquake data,
## the location and distance of the nearest earthquake, and a plot of the earthquakes.


## Load and attach the required add-on packages
library(dplyr)
library(geosphere)
library(ggmap)
library(ggplot2)
library(shiny)

## Read the most up-to-date earthquake data for the week from USGS
quakes <- tbl_df(read.csv("http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_week.csv"))

## Get a map of North America centered on the US from google.
mymap <- get_map(location = "United States", zoom = 3, source = "google",
                 maptype = "terrain", crop = FALSE)

## Get the bounding box attribute from the map.
bb <- attr(mymap, "bb")

## Filter the data set for earthquakes that fall within the bounding box
quakes <- filter(quakes, latitude > bb$ll.lat, longitude > bb$ll.lon,
                 latitude < bb$ur.lat, longitude < bb$ur.lon)

shinyServer(
    function(input, output) {
        ## Filter the data set for earthquakes whose magnitudes fall within the user-input bounds
        myquakes <- reactive(filter(quakes, mag >= input$magSlider[1], mag <= input$magSlider[2]))
        
        ## Count the number of earthquakes in the filtered data set
        numQuakes <- reactive(nrow(myquakes()))
        
        ## Get the geocode (latitude and longitude) for the user-input location
        userLoc <- reactive(geocode(location = input$loc, source = "google"))
        
        ## Use the distm function from the geosphere package to find the distances between
        ## the user-input location and all the earthquakes in the filtered data set
        distances <- reactive(distm(userLoc(), cbind(myquakes()$longitude, myquakes()$latitude)))
        
        ## Determine which earthquake was the closest, and get its distance and location.
        closest_idx <- reactive(which.min(distances()))
        closest_dist <- reactive(round(distances()[closest_idx()]/1000, digits = 1))
        closest_mag <- reactive(round(myquakes()$mag[closest_idx()], digits = 1))
        closest_lat <- reactive(round(myquakes()$latitude[closest_idx()], digits = 1))
        closest_lon <- reactive(round(myquakes()$longitude[closest_idx()], digits = 1))
        
        ## Make ggplot geom_point objects to overlay
        ## earthquakes and the user-input location on the map
        quake_points <- reactive(geom_point(aes(x = longitude, y = latitude,
                                                size = sign(mag)*(mag+.5)^2),
                                            data = myquakes(), alpha = 0.5))
        loc_points <- reactive(geom_point(aes(x = lon, y = lat),
                                          data = data.frame(userLoc()), 
                                          size=5, color="red", shape = 7))

        ## Render the text output that summarizes the calculations
        output$text1 <- renderText({ 
            paste("In the last week, there have been ", numQuakes(),
                  " earthquakes between magnitude ", input$magSlider[1],
                  " and magnitude ", input$magSlider[2],
                  ". The closest earthquake to ", input$loc,
                  " in this range of magnitudes was ", closest_dist(),
                  "km away, a magnitude ", closest_mag(),
                  " quake centered at Latitude ", closest_lat(),
                  ", Longitude ", closest_lon(), ".", sep = "")
        })
        
        ## Render the plot output that visualizes the earthquakes
        output$mapQuakes <- renderPlot({
            p <- ggmap(mymap) + quake_points() + loc_points() + 
                scale_size_area(breaks = ((input$magSlider[1]:input$magSlider[2]) + 0.5)^2,
                                labels = input$magSlider[1]:input$magSlider[2],
                                name = "Magnitude")
            print(p)
        },height=700)
    }
)