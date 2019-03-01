## ui.R ##

##install.packages("shiny")
##install.packages("plotGoogleMaps")
##install.packages("leaflet")

library(shiny)
library(shinydashboard)
library(graphics)
library(leaflet)

dashboardPage(
  dashboardHeader(title = "GeoStat"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Karte", tabName = "Karte", icon = icon("Karte")),
      menuItem("dataOvr", tabName = "dataOvr", icon = icon("Karte")),
      menuItem("Statistiken", tabName = "Statistiken", 
               icon = icon("Statistiken")),
      menuItem("Fragebogen", tabName = "Fragebogen", icon = icon("Fragebogen"))
    )
  ),
  dashboardBody(
    tabItems(
        tabItem(tabName = "Karte",
                fluidPage(
                  fluidRow(
                    box(fileInput("file", label = h3("Datensatz hochladen"),
                        multiple = FALSE, accept = c( ".gpx", ".xml")),
                        actionButton("refresh", "Load Data Set")),
                    box(radioButtons("radiomid", label = h3("Länderauswahl"),
                                      choices = list("Welt" = 1, "Afrika" = 2, 
                                                     "Asien" = 3, 
                                                     "Europa" = 4,
                                                     "Nordamerika" = 5,
                                                     "Südamerika" = 6), 
                                      selected = 1), width =6)
                  ),
                  fluidRow(
                    box(leafletOutput("map"), width = 12)
                  ),
                  fluidRow(
                    box(sliderInput("DatesMerge",
                                    "Dates:",
                                    min = as.Date("2008-01-01","%Y-%m-%d"),
                                    max = as.Date("2019-01-01","%Y-%m-%d"),
                                    value=as.Date("2016-12-01"),
                                    timeFormat="%d.%m.%Y",
                                    step = 7), width = 12)
                  )
                )),
        
        tabItem(
          tabName = "dataOvr",
          DT::dataTableOutput("dataUI")),
        
        tabItem(tabName = "Statistiken",
              h2("Statistiken")
                ),
        
        tabItem(tabName = "Fragebogen",
                h3("Fragebogen"),
                fluidRow(
                  box(selectInput("Geschlecht", label = h3("Mit welchem 
                                  Geschlecht identifizieren Sie sich?"), 
                                  choices = list("keine Angabe" = 1, 
                                                 "weiblich" = 2, "männlich" = 3,
                                                 "divers" = 4), 
                                  selected = 1), height = 145, width = 6),
                  box(selectInput("Alter", label = h3("Wie alt sind Sie?"), 
                                  choices = list("keine Angabe" = 1, "< 10 Jahre" = 2, 
                                                 "10-18 Jahre" = 3, "19-27 Jahre" = 4,
                                                 "28-36 Jahre" = 5, "37-45 Jahre" = 6,
                                                 "46-54 Jahre" = 7, "55-63 Jahre" = 8,
                                                 "64-72 Jahre" = 9, "> 73 Jahre" = 10), 
                                  selected = 1), height = 145, width = 6))
                  )
                ))
    )