  ##############################################################
  
  # Seminar: Building Online Apps with R , Universitaet Konstanz
  
  # von: Maren Roeckle & Anna Knoop
  
  ##############################################################
  
  ## ui.R ##
  


  ##### Dashboard Header und Sidebar ####

  dashboardPage(skin = "green",
    dashboardHeader(title = "GeoStat"),
    dashboardSidebar(
      sidebarMenu(
        menuItem("Karte", tabName = "Karte", icon = icon("Karte")),
        menuItem("Datenüberblick", tabName = "Datenüberblick", icon = icon("Karte")),
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
                        placeholder = "Geodaten hochladen, max. 30 MB, .gpx oder .xml Format")
                        #actionButton("refresh", "Karte erstellen")
                        ),
                    box(radioButtons("radiomid", label = h3("Länderauswahl"),
                                      choices = list("Welt" = 1, "Afrika" = 2, 
                                                     "Asien" = 3, 
                                                     "Europa" = 4,
                                                     "Nordamerika" = 5,
                                                     "Südamerika" = 6), 
                                      selected = 1), width =6)
                  ),
                  box(textOutput("summary"), width = 12),
                  fluidRow(
                    box(leafletOutput("map"), width = 12)
                                  ),
                  
  ##### Slider UI #####                
          
                  
                fluidRow(
                  box(uiOutput("slider_datum"), width = 12 # fertigen Slider darstellen
                      
                      #actionButton("refresh", "auf Datensatz anwenden"),
                      #verbatimTextOutput("range")
                      #textOutput("SliderText"),
                      #textOutput("SliderText1")
                  )
                  )
                )),
  
  
  ##### Datenueberblick UI #####
  
        tabItem(
          tabName = "Datenüberblick",
          DT::dataTableOutput("dataUI")),
  
  ##### Statistiken UI ######
  
  
  tabItem(tabName = "Statistiken",
          h2("Statistiken"),
          fluidPage(
            fluidRow(
              box(plotlyOutput("scatterplot"),
                  verbatimTextOutput("hover"),
                  verbatimTextOutput("click")
              
              ),
              (box(tags$div(class="header", checked=NA,
                            list(
                              tags$p("Jeder Cache hat eine Wertung des Schwierigkeisgrads 
                                     und eine Geländewertung, anhand derer man sich bei der Auswahl 
                                     des zu suchenden Caches orientieren kann."),
                              tags$p("Diese sind wie folgt zu verstehen:"),
                              tags$p("Schwierigkeitsgrad"),
                              tags$p("Stufe 1: Offensichtliches Versteck, wird von erfahrenen Cachern fast sofort gefunden."),
                              tags$p("Stufe 5: Eine wirklich ernsthafte Herausforderung, spezielle Kenntnisse, Fähigkeiten und/oder 
                                     Ausrüstung werden benoetigt, um diesen Cache zu finden"),
                              tags$p("Geländewertung"),
                              tags$p("Stufe 1: Ebene, kurze Wege, behindertengerecht."),
                              tags$p("Stufe 5: lange Wanderung, es sind Spezial-Ausrüstungsgegenstände erforderlich, enge Höhlen, 
                                     Hochgebirge, Tauchcaches fallen in diese Kategorie.")
                              )
                            )))),
              
            fluidRow(
              box(
                plotlyOutput("barchart")
              ),
              (box(tags$div(class="header", checked=NA,
                            list(
                              tags$p("Zeigt die gefundenen Caches per Land")
                              )
                              )))
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
