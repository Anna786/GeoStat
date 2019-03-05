##### server.R #####

shinyServer(function(input, output) {
  options(shiny.maxRequestSize=30*1024^2) # Uploadlimit auf 30 mb erhoehen 
  
library(DT)  

  ##### TO DO
  # Fehlermeldung bei falschen Datenformat A
  # Slider M
  # Statistik gedoens M
  # Schriftlicher Teil
  # Demo Daten: Den Krabben ganz nah entfernen A
  # netter Header ! A
  

    
# Funktion zur Extrahierung von Geodaten  
  Geo.extract<- function(listenelement){   
    id <- listenelement$name
    name <- listenelement$cache$name
    time <- listenelement$cache$logs$log$date # eigenes Funddatum
    type <- listenelement$cache$type # Art des Caches (Factor)
    countr <-listenelement$cache$country
    ter <- listenelement$cache$terrain # Gelaendewertung
    dif <- listenelement$cache$difficulty # Schwierigkeit des Verstecks
    att <- attributes(listenelement)
    lon <- att$lon  # Longitude
    lat <- att$lat  # Langitude
    res <- as.vector(unlist(c(id, name, as.numeric(lon), as.numeric(lat),
                              time, countr, type, ter, dif)))  # schreibt Vector
    res  # output
  }  
  ##### Daten einlesen ##### 
# Daten einlesen als reaktives Element
# wenn der Nutzer noch kein Element eingelesen hat, wird NULL ausgegeben
# Die xml oder gpx- Datei wird eingelesen, zu einer Liste konvertiert und bereinigt
# die oben definierte Funktion Geo.extract zieht fuer jeden Geocache die Daten aus der Datei
# Zeilen- und Spaltennamen werden vergeben, aufsteigend nach Datum sortiert
  dset <- reactive({
    input$refresh
    isolate({if(is.null(input$file)) {return (NULL)}
      else{
        geo <- read_xml(input$file$datapath) # Verweis auf Originaldatei
        geoli <- xml2::as_list(geo)
        geoclean <- geoli$gpx[-c(1:7)]
        dset <- as.data.frame(do.call("rbind", lapply(geoclean, Geo.extract)),
                              stringsAsFactors = F)
        colnames(dset)<- c("id","name","Lon", "Lat", "time", "countr", "type", "ter", "dif")
        rownames(dset) <- (1 : c(nrow(dset)))
        dset <- separate(dset, time, into = c("date", "uhrzeit"), sep = "T",
                         remove = T, extra = "warn" )
        dset <- arrange(dset,as.Date(dset$date, "%Y-%m-%d"))
        
        return(dset)
      }
    })
  })
 
  
  #####Rendertable#####
    # reactive data table shown in "Datenueberblick"
  output$dataUI <- DT::renderDataTable({
    dset()
  })
  
  # Feedback zum Upload-Button
  # observeEvent(input$refresh, {
  #   showNotification("Daten hochgeladen", type = "error", duration = 10)
  # })
  

  #####Landerauswahl#####
  output$value <- renderPrint({ input$radio })  #Server-Code "Länderauswahl"
  
  #####Map#####
  output$map <- renderLeaflet({
    map = leaflet() %>%
      addTiles() %>%
      setView(midpoints[input$radiomid,"lon"],     #Map-Ansicht je nach Auswahl der Länder
              midpoints[input$radiomid,"lat"],
              midpoints[input$radiomid,"ZL"]) %>%
      addMarkers(data = dset(), lng = ~as.numeric(Lon), lat= ~as.numeric(Lat),
                 popup = ~as.character(name), label = ~as.character(name)
      )
  })      #Server-Code "Map"
  
  #### Idee Referenzierung von der Map auf den Slider-Input ####
  
  # observer-Funktion für die Map, um auf die Daten des Sliders zugreifen
  # zu können. Hab gedacht man könnte bei 'data =' statt 'dset()' dann die 
  # entsprechende Referenz zum Date-Range des Sliders angeben 
  # (ich hab aber keine Ahnung, wie das geht).
  
  #  observe({
  #    leafletProxy("map", data = dset()) %>%
  #      clearTiles %>%
  #      addTiles() %>%
  #      addMarkers(data = dset(), lng = ~as.numeric(Lon), lat= ~as.numeric(Lat),
  #                 popup = ~as.character(name), label = ~as.character(name)
  #      )
  #  })
  
  #### Ende ####
  
  ##### Date Slider#####
  output$range <- renderPrint({ input$DatesMerge })  #Server-Code "Date-Slider"
 
  # Minimum und Maximum des Sliders wird berechnet
  slider_min <- reactive({
    input$refresh
    isolate({if(is.null(input$file)) {return (as.Date(2000-01-01))}
      else{
        slider_min <- dset()[1,"date"]
        return(slider_min)
      }
    })
  })
  
  slider_max <- reactive({
    input$refresh
    isolate({if(is.null(input$file)) {return (as.Date(2019-01-01))}
      else{
        slider_max <- dset()[nrow(dset()),"date"]
        return(slider_max)
      }
    })
  })
  
 output$slider_datum <- renderUI({
  sliderInput("DatesMerge", 
              "Dates:", 
              min=as.Date(slider_min()), 
              max=as.Date(slider_max()), 
              value=as.Date(c(slider_min(), slider_max())),
              timeFormat="%d.%m.%Y",
              step = 7
            )
 })
  
 
  
  ##### Scatterplot #####
  # Scatterplot für Terrain und Schwierigkeitsgrad; hab die Achsen leider nicht
  # umbenennen können
  # wenn man das 'as.numeric' weglässt und nur '~dif' und '~ter' schreibt, kommt
  # ein farbiger Plot raus, aber ich weiß nicht was er bedeutet :D
  
  output$plot <- renderPlotly({
    plot_ly(data = dset(), x = ~(dif),
            y = ~(ter))
  })
  
  output$hover <- renderPrint({
    d <- event_data("plotly_hover")
  })
  
  output$click <- renderPrint({
    d <- event_data("plotly_click")
  })
  
  output$value <- renderPrint({ input$select })   #Server-Code "Geschlecht"
  
  output$value <- renderPrint({ input$select })   #Server-Code "Alter"
})