  ##############################################################
  
  # Seminar: Building Online Apps with R , Universitaet Konstanz
  
  # von: Maren Roeckle & Anna Knoop
  
  ##############################################################
  
  ## global.R ##
  
  library(shiny)
  library(shinydashboard)
  library(graphics)
  library(leaflet)
  library(tidyverse)
  library(xml2)
  library(DT)
  library(plotly)
  library(data.table)
  
  # Mittelpunkt fuer Kartenansichten festlegen
  
  midpoints <- data.frame(id= c("Welt", "Afrika", "Asien", "Europa", "Nordamerika", 
                                "Südamerika"),
                          lon= c(34.566667, 17.05291, 94.443611, 25.316667, 
                                 -99.996111, -56.100278),
                          lat= c(40.866667, 2.07035, 51.725, 54.9, 48.367222, 
                                 -15.598889),
                          ZL= c(1, 2, 1, 3, 3, 3)
  )
  
  # Icons definieren
  
  icons <- awesomeIcons(
    icon = 'leaf',
    iconColor = 'white',
    library = 'ion',
    markerColor = 'darkgreen'
  )
