## Developing Data Products - Shiny App
## ui.R

## This function describes the app in the sidebar. A reference to the USGS webpage is provided
## so that the user can see where the earthquake data is coming from. The sidebar also has a
## slider bar where the user can input lower and upper bounds on the earthquake magnitudes to
## visualize from the past week. A text input is provided so that the user can type in a
## location, and the app computes the distance to the closest earthquake that occured in the
## past week. A helpful reference for the ggmap package is cited too.

## In the main panel, the results of the app are visualized, including a text summary and map.

library(shiny)
library(ggplot2)

shinyUI(pageWithSidebar(
    headerPanel("Earthquake Map"),
    sidebarPanel(
        p("This app allows you to see earthquake data from the past week in North America. ",
          "Data is loaded from ",
          a(href="http://earthquake.usgs.gov/",
            "USGS"),
          " for the past week. "),
        p("You can adjust the threshold for what magnitude earthquakes to plot using this slider bar:"),
        sliderInput("magSlider", label = h3("Magnitudes to Plot"), min = 0, 
                    max = 10, value = c(1, 5)),
        p("Find the earthquake that occurred closest to you by entering your location:"),
        textInput("loc","Location: ","Ithaca, NY"),
        p("When building this app, I found the ",
          a(href="https://www.nceas.ucsb.edu/~frazier/RSpatialGuides/ggmap/ggmapCheatsheet.pdf",
            "ggmap quickstart cheat-sheet"),
          "by Melanie Frazier to be very useful. Thanks Melanie!"),
        width=4
    ),
    mainPanel(
        textOutput('text1'),
        plotOutput('mapQuakes')
    )
))