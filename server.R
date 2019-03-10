
  ##############################################################
  
  # Seminar: Building Online Apps with R , Universitaet Konstanz
  
  # von: Maren Roeckle & Anna Knoop
  
  ##############################################################
  
  ##### server.R #####


  shinyServer(function(input, output, session) {
    options(shiny.maxRequestSize=30*1024^2) # Uploadlimit auf 30 mb erhoehen 
  

# Funktion zur Extrahierung von Geodaten  
# liest die Attribute eines Knotens aus und speichert diese einzeln
    
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
  # Zeilen- und Spaltennamen werden vergeben, zu Datatable konvertiert und aufsteigend 
  # nach Datum sortiert
  
  dset <- reactive({
    input$refresh
    validate(
      need(input$file != "", "Bitte wählen Sie eine Datei aus."))
    isolate({if(is.null(input$file)) {return (NULL)}
      else{
        geo <- read_xml(input$file$datapath) # Verweis auf Originaldatei
        geoli <- xml2::as_list(geo)
        geoclean <- geoli$gpx[-c(1:7)]
        dset <- as.data.table(do.call("rbind", lapply(geoclean, Geo.extract)),
                              stringsAsFactors = F)
        colnames(dset)<- c("id","name","Lon", "Lat", "time", "countr", "type", "ter", "dif")
        rownames(dset) <- (1 : c(nrow(dset)))
        dset <- separate(dset, time, into = c("date", "uhrzeit"), sep = "T",
                         remove = T, extra = "warn" ) 
        dset$date <- as.Date(dset$date)
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
  
  #####Landerauswahl#####
  output$value <- renderPrint({ input$radio })  #Server-Code "Länderauswahl"
  
  
  #####Map Server Code######
  # Anzeigen der Caches auf der Karte
  #Map-Ansicht je nach Auswahl der Länder
  # Der Datensatz wird als Subset aus dem gewaehlten Zeitbereich genereiert
  
  output$map <- renderLeaflet({
    map = leaflet() %>%
      addTiles() %>%
      setView(midpoints[input$radiomid,"lon"],     
              midpoints[input$radiomid,"lat"],
              midpoints[input$radiomid,"ZL"]) %>%
      addAwesomeMarkers(#data = dset(), 
               data = subset(dset(), dset()$date >= range_min()    
                        & dset()$date <= range_max()),
                 lng = ~as.numeric(Lon), lat= ~as.numeric(Lat), icon = icons,
                 popup = ~as.character(name), label = ~as.character(name)
      )
  })      
  
  # erstellt summary-Text
  
  output$summary <- renderText({paste("Der hochgeladene Datensatz enthält", nrow(dset()) ,
                                      "Caches, gefunden zwischen", slider_min(), "und", 
                                      slider_max(), "." )})
  
  ##### Date Slider#####
  
  output$range <- renderPrint({ input$DatesMerge })  
  
    # die vom User gewaehlten Grenzen des Sliders werden als Element abgespeichert 
  
  range_min <- reactive({as.character(input$DatesMerge[1])})
  range_max <- reactive({as.character(input$DatesMerge[2])})
 
  
  # Minimum und Maximum des Sliders wird berechnet
  slider_min <- reactive({
    input$refresh
    validate(
      need(input$file != "", "Bitte wählen Sie eine Datei aus."))
    isolate({if(is.null(input$file)) {return (as.Date(2000-01-01))}
      else{
        slider_min <- dset()[1,"date"]
        return(slider_min)
      }
    })
  })
  
  slider_max <- reactive({
    input$refresh
    validate(
      need(input$file != "", "Bitte wählen Sie eine Datei aus."))
    isolate({if(is.null(input$file)) {return (as.Date(2019-01-01))}
      else{
        slider_max <- dset()[nrow(dset()),"date"]
        return(slider_max)
      }
    })
  })
 
  # Definition des Sliders, die default-Werte der Range sind Minimum und Maximum des Sliders
   
   output$slider_datum <- renderUI({
    sliderInput("DatesMerge", 
                "Dates:", 
                min=as.Date(slider_min()), 
                max=as.Date(slider_max()), 
                value=as.Date(c(slider_min(), slider_max())),
                timeFormat="%F",
                step = 7
              )
   })
  
  
  
   output$barchart <- renderPlotly({
     validate(
       need(input$file != "", "Bitte wählen Sie eine Datei aus."))
     plot_ly(data = dset(), x = ~countr) %>%
              add_histogram()%>%
       layout(title = "Anzahl der Caches pro Land",
              xaxis = list(title = "Länder"),
              yaxis = list(title = "Anzahl"))
   })
   
   
   
   
   output$scatterplot <- renderPlotly({
     validate(
       need(input$file != "", "Bitte wählen Sie eine Datei aus."))
     plot_ly(data = dset(), x = ~dif,
             y = ~ter, marker = list(color = 'rgb(0,109,0)')) %>%
       layout(title = "Schwierigkeitsgrad und Geländewertung",
              xaxis = list(title = "Schwierigkeitsgrad"),
              yaxis = list(title = "Geländewertung"))
   })
 
   
  output$hover <- renderPrint({
    d <- event_data("plotly_hover")
  })
  
  output$click <- renderPrint({
    d <- event_data("plotly_click")
  })
  
  output$gender <- renderPrint({ input$Geschlecht })   #Server-Code "Geschlecht"
  
  output$age <- renderPrint({ input$Alter })   #Server-Code "Alter"
  
  })