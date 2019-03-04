## ui.R ##

##install.packages("shiny")
##install.packages("plotGoogleMaps")
##install.packages("leaflet")
##install.packages("DT")

library(shiny)
library(shinydashboard)
library(graphics)
library(leaflet)

  ##### Dashboard Header und Sidebar ####

dashboardPage(
  dashboardHeader(title = "GeoStat"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Karte", tabName = "Karte", icon = icon("Karte")),
      menuItem("Datenueberblick", tabName = "Datenueberblick", icon = icon("Karte")),
      menuItem("Statistiken", tabName = "Statistiken", 
               icon = icon("Statistiken")),
      menuItem("Fragebogen", tabName = "Fragebogen", icon = icon("Fragebogen"))
    )
  ),
  
  ##### Karte UI #####
  
  dashboardBody(
    tabItems(
        tabItem(tabName = "Karte",
                fluidPage(
                  fluidRow(
                    box(fileInput("file", label = h3("Datensatz hochladen"),
                        multiple = FALSE, accept = c( ".gpx", ".xml"), 
                        placeholder = "Geodaten hochladen, max. 30 MB, .gpx oder .xml Format"),
                        actionButton("refresh", "Karte erstellen")),
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
                  
  ##### Slider UI #####                
  
                  
  ### Neuer Teil ###
  # hab hier noch den Refresh-Button eingebaut
  # Überlegung meinerseits war, für bspw. für 'min' statt 'as.Date' direkt 'dset[1,5]'
  # anzugeben, damit der Slider auf den Datensatz (Zeile 1, Spalte 5, = date)
  # zugreift & das als Start-Datum einsetzt (gleiches für 'max' mit der letzten Zeile)
  # und als 'value' für beide Slider dann jeweils den Start- & Endpunkt benutzt
                  
                  
                  
                  
                  
                  fluidRow(
                    box(sliderInput("DatesMerge",
                                    "Dates:",
                                    min = as.Date("2000-01-01", "%Y-%m-%d"),
                                    max = as.Date("2019-01-01", "%Y-%m-%d"),
                                    value=as.Date(c("2005-01-01", "2015-01-01")),
                                    timeFormat="%d.%m.%Y",
                                    step = 7), width = 12,
                                    actionButton("refresh", "Reload Date Range")
                        )
                    # Begrenzung fuer Slider
                    # So kann man NORMALERWEISE auf den 1. und letzten Eintrag referenzieren
                    # geodf[1,"date"] # 1. Cache
                    # geodf[nrow(geodf),"date"] # letzter Cache
                    
                    
                  )
                )),
  
  ##### Datenueberblick UI #####
  
        tabItem(
          tabName = "Datenueberblick",
          DT::dataTableOutput("dataUI")),
  
  
  
  ##### Statistiken UI ######
  
        
  # zu den Statistiken hab ich leider noch fast nichts, weil die Referenzierung
  # irgendwie schwierig ist oder er den dset nicht erkennt...
  
  
  tabItem(tabName = "Statistiken",
          h2("Statistiken"),
          fluidPage(
            fluidRow(
              box(plotlyOutput("plot"),
                  verbatimTextOutput("hover"),
                  verbatimTextOutput("click")
              )
            )
          )
  ),
        
  
  ##### Fragebogen UI #####
  
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