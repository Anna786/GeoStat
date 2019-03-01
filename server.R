shinyServer(function(input, output) {
  
library(DT)  

  # To Do
  # Fehlermeldung bei falschen Datenformat
  # Kein Uploadlimit A
  # Slider M
  # nach Datum sortieren A
  # Statistik gedoens M
  # Map A
  # Schriftliches Teil
  
  
  
  
  
    
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
  
# Daten einlesen als reaktives Element
# wenn der Nutzer noch kein Element eingelesen hat, wird NULL ausgegeben
# Die xml oder gpx- Datei wird eingelesen, zu einer Liste konvertiert und bereinigt
# die oben definierte Funktion Geo.extract zieht fuer jeden Geocache die Daten aus der Datei
# Zeilen- und Spaltennamen werden vergeben
  
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
        return(dset)
      }
    })
  })

  # reactive data table shown in "Data Overview"
  output$dataUI <- DT::renderDataTable({
    dset()
  })
  
  # Feedback zum Upload-Button
  observeEvent(input$refresh, {
    showNotification("Daten hochgeladen", type = "error", duration = 10)
  })
  

  
  output$value <- renderPrint({ input$radio })  #Server-Code "Länderauswahl"
  
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
  
   output$range <- renderPrint({ input$slider2 })  #Server-Code "Date-Slider"
  
  
  output$value <- renderPrint({ input$select })   #Server-Code "Geschlecht"
  output$value <- renderPrint({ input$select })   #Server-Code "Alter"
  })
