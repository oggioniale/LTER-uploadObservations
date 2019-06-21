#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
###
# Library
###
library(ggplot2)
library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(leaflet)
library(xslt)
library(xml2)
library(DT)
library(shinycssloaders)
library(crosstalk)
library(shinyjs)
library(shinyBS)
library(leaflet.extras)
library(mapview)
library(mapedit)
library(httr)
library(jsonlite)
library(XML)

###
# Function
###
templateID <- function(procedureID, lat, lon, observedProp) {
  ID <- paste0(
    procedureID,
    '/template/observedProperty/',
    observedProp,
    '/foi/SSF/SP/4326/',
    lat,
    '/',
    lon
  )
  return(ID)
}


###
# UI
###
ui <- fluidPage(
  useShinyjs(),
  # App title ----
  titlePanel("Fixed point observations - Uploading separated values file on GET-IT"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      width = 4,
      # Input: sos host selection
      div(HTML("<h4>Server endpoint</h4>")),
      selectInput(inputId = "sosHost",
                  label = "Select server where you want to upload observations", 
                  multiple = F,
                  choices = list(
                    "LTER-Eu CDN SOS (default)" = "http://cdn.lter-europe.net/observations/service",
                    "LTER-Italy SOS" = "http://getit.lteritalia.it/observations/service"
                  ),
                  selected = "http://getit.lteritalia.it/observations/service"
      ),
      
      # Input: procedure URL
      div(HTML("<hr><h4>Station</h4>")),
      # TODO: add the link to the SOS endpoint selected above. A shinyBS::bsModal appairs in order to visualize the sensors page.
      textInput('SensorMLURI', HTML('Enter unique ID of station (e.g. <a href=\"http://getit.lteritalia.it/sensors/sensor/ds/?format=text/html&sensor_id=http%3A//www.get-it.it/sensors/getit.lteritalia.it/procedure/CampbellScientificInc/noModelDeclared/noSerialNumberDeclared/20170914050327762_790362\">ENEA Santa Teresa meteorological station</a>)')),
      
      # Input: FOI POPUP
      # actionButton('foi', 'Click for provide station\'s position'),
      # shinyBS::bsModal(
      #   "modalnew",
      #   "Draw the marker for the station's position",
      #   "foi",
      #   size = "medium",
      #   # editModUI("editor"),
      #   leafletOutput("mymap"),
      #   textInput("lat", "Latitude (e.g. 45.9206)"),
      #   textInput("long", "Longitude (e.g. 8.6019)"),
      #   # selectInput(inputId = "srs",
      #   #             label = "Projection",
      #   #             multiple = F,
      #   #             choices = list(
      #   #               "WGS84"="http://www.opengis.net/def/crs/EPSG/0/4326",
      #   #               "..." = ""
      #   #             ),
      #   #             selected = "http://www.opengis.net/def/crs/EPSG/0/4326"
      #   # ),
      #   textInput("sampFeat", "Sampled feature")
      # ),
      div(HTML("<hr><h4>File</h4>")),
      # Input: Select a file ----
      fileInput("file1", "Choose CSV File",
                multiple = FALSE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")
                ),
      
      # Input: Checkbox if file has header ----
      checkboxInput("header", "Header", TRUE),
      
      # Input: Select separator ----
      radioButtons("sep", "Separator",
                   choices = c(Comma = ",",
                               Semicolon = ";",
                               Tab = "\t"),
                   selected = ","),
      
      # Input: Select quotes ----
      radioButtons("quote", "Quote",
                   choices = c(None = "",
                               "Double Quote" = '"',
                               "Single Quote" = "'"),
                   selected = '"'),
      
      # Input: Select number of rows to display ----
      radioButtons("disp", "Display",
                   choices = c(Head = "head",
                               All = "all"),
                   selected = "all"),
      HTML("<br>"),
      checkboxInput("finalCheck", 
                    HTML("<b>Check this box when all columns are matched</b>"), 
                    FALSE),
      actionButton("sendFile", "Upload observations", icon = icon("file-upload"))
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      fluidRow(
        column(6,
               div(HTML("<h4>Parameters observed by selected sensor</h4>")),
               DT::dataTableOutput("outputsValue")
        ),
        column(6,
               div(HTML("<h4>Colums headers (modify the saparator or the quote for display the name of the colums)</h4>")),
               uiOutput("selectionParams")
        )
      ),
      fluidRow(
        column(12,
          div(HTML("<hr><h4>Observations to be imported</h4>")),
          # Output: Data file ----
          DT::dataTableOutput("file1"),
          verbatimTextOutput("selectParamCSV")
        )
      )
    )
  )
)

# Define server logic to read selected file ----
server <- function(input, output, session) {
  
  # coordinatesFOI <- reactiveValues(lat = NULL, lon = NULL)
  # output$mymap <- renderLeaflet({
  #   #Get setView parameters
  #   new_zoom <- 2
  #   if(!is.null(input$map_zoom)) new_zoom <- input$map_zoom
  #   new_lat <- 0
  #   if(!is.null(input$map_center$lat)) new_lat <- input$map_center$lat
  #   new_lon <- 0
  #   if(!is.null(input$map_center$lng)) new_lon <- input$map_center$lng
  #   
  #   leaflet() %>% addTiles() %>%
  #     setView(new_lon, new_lat, zoom = new_zoom) %>%
  #     # setView(lng = 0, lat = 0, zoom = 1) %>%
  #     addSearchOSM() %>%
  #     addDrawToolbar(
  #       #targetGroup = "new_points",
  #       polylineOptions = FALSE,
  #       polygonOptions = FALSE,
  #       rectangleOptions = FALSE,
  #       circleOptions = FALSE,
  #       circleMarkerOptions = FALSE,
  #       #markerOptions = TRUE,
  #       editOptions = editToolbarOptions(
  #         selectedPathOptions = selectedPathOptions()
  #       )
  #     )
  # })
  # 
  # observeEvent(c(input$mymap_draw_edited_features, input$mymap_draw_new_feature), {
  #   if (!is.null(input$mymap_draw_edited_features)) {
  #     click_lon <- input$mymap_draw_edited_features$features[[1]]$geometry$coordinates[[1]]
  #     click_lat <- input$mymap_draw_edited_features$features[[1]]$geometry$coordinates[[2]]
  #     coordinatesFOI$lat <- c(click_lat)
  #     coordinatesFOI$lon <- c(click_lon)
  #     updateTextInput(session, "lat", value = click_lat)
  #     updateTextInput(session, "long", value = click_lon)
  #   }
  #   else
  #     click_lat <- input$mymap_draw_new_feature$geometry$coordinates[[2]]
  #   click_lon <- input$mymap_draw_new_feature$geometry$coordinates[[1]]
  #   coordinatesFOI$lat <- c(click_lat)
  #   coordinatesFOI$lon <- c(click_lon)
  #   updateTextInput(session, "lat", value = click_lat)
  #   updateTextInput(session, "long", value = click_lon)
  # })
  
  # xslObs.url <- "https://www.get-it.it/objects/sensors/xslt/sensor2outputs_4Shiny.xsl"
  xslObs.url <- "./sensor2outputs_4Shiny.xsl"
  style <- read_xml(xslObs.url, package = "xslt")
  outputsParams <- reactive({
    listOutputs <- read.csv(text = xml_xslt((
      read_xml(
        paste0('http://getit.lteritalia.it/observations/sos/kvp?service=SOS&version=2.0.0&request=DescribeSensor&procedure=',
               input$SensorMLURI,
               '&procedureDescriptionFormat=http://www.opengis.net/sensorml/2.0'),
        package = "xslt"
      )
    ), style), header = TRUE, sep = ';')
    
    listOutputs$name <- gsub('_', ' ', listOutputs$name)
    listOutputs <- as.data.frame(listOutputs)
  })
    
  output$outputsValue <- DT::renderDataTable({
    
    numbRow <- length(outputsParams())
    
    datatable(
      req(outputsParams()),
      selection = "none",
      colnames = c('Name'),
      extensions = "Scroller",
      style = "bootstrap",
      class = "compact",
      escape = FALSE,
      editable = FALSE,
      rownames = FALSE,
      options = list(
        columnDefs = list(list(
          visible = FALSE,
          targets = c(2:6) - 1
        )),
        dom = 't',
        ordering = FALSE
      )
    )
  },
  server = FALSE)
  
  output$file1 <- DT::renderDataTable({
    
    req(input$file1)
    
    df <- read.csv(input$file1$datapath,
                   header = input$header,
                   sep = input$sep,
                   quote = input$quote
                   )
    
    # to create JSON
    # dataCol <- df[,1]
    # allCol <- df[,-1]
    # 
    # # jsonInsertResultAll <- list()
    # for (i in 1:ncol(allCol)){
    #   jsonInsertResult <- toJSON(list(request = "InsertResult", service = "SOS", version = "2.0.0",
    #                                   templateIdentifier = "",
    #                                   resultValues = paste(dataCol, allCol[,i], sep = ",", collapse = "#")),
    #                              pretty = TRUE, auto_unbox = TRUE)
    #   # jsonInsertResultAll[[i]] <- jsonInsertResult
    #   assign(paste0("jsonInsertResultAll", i), jsonInsertResult)
    # }
    # # TODO extract from SensorML swe:Quantity/@definition URL
    # 
    # END to create JSON
    
    if(input$disp == "head") {
      return(head(
        datatable(df,
                  selection = "none",
                  extensions="Scroller",
                  style="bootstrap",
                  class="compact",
                  escape = FALSE,
                  editable = FALSE,
                  options = list(
                    pageLength = 10,
                    columnDefs = list(list(
                      visible = FALSE
                    )),
                    #dom = 't',
                    ordering = FALSE
                  ),
                  rownames = FALSE
        )
      )
      )
    }
    else {
      return(
        datatable(df,
                  selection = "none",
                  extensions="Scroller",
                  style="bootstrap",
                  class="compact",
                  escape = FALSE,
                  editable = FALSE,
                  options = list(
                    pageLength = 10,
                    columnDefs = list(list(
                      visible = FALSE
                    )),
                    #dom = 't',
                    ordering = FALSE
                  ),
                  rownames = FALSE
        )
        )
    }
  },
  server = FALSE
  )
  
  output$selectionParams <- renderUI({
    req(input$file1)
    listParam <- read.csv(input$file1$datapath,
                          header = input$header,
                          sep = input$sep,
                          quote = input$quote
    )
    
    #req(outputsParams())
    # if(length(listParam) != length(outputsParams())) {
    #   div(HTML("<p>Please select a CSV file with the same number of colums compared to the number of parameter collected by the sensor selected</p>"))
    # }  else {
      lapply(1:length(listParam), function(i) {
        # div(HTML(paste0("<p>", i ,"</p>")))
        selectInput(inputId = paste0("params", i),
                    label = "", 
                    multiple = F,
                    choices = names(listParam)
        )
      })
    # }
  })
  
  # to be delete also selectParamCSV in UI
  output$selectParamCSV <- renderPrint({
    req(input$file1)
    listParam <- read.csv(input$file1$datapath,
                          header = input$header,
                          sep = input$sep,
                          quote = input$quote
    )

    # xslInsertResult <- "https://www.get-it.it/objects/sensors/xslt/insertResult_4Shiny.xsl"
    xslInsertResult <- "./insertResult_4Shiny.xsl"
    styleInsertResult <- xml2::read_xml(xslInsertResult, package = "xslt")
    
    xmlInsertResult <- xml2::read_xml(
      # "https://www.get-it.it/objects/sensors/xslt/insertResult_4Shiny.xsl"
      "./insertResult_4Shiny.xsl",
      package = "xslt"
    )
    
    dfTot <- data.frame()
    for (v in 1:length(listParam)){
      a <- as.character(input[[paste0("params", v)]])
      b <- req(outputsParams()[(v),])
      df <- data.frame(col = which(colnames(listParam) == a), par = gsub(' ', '_', b[[2]][1]))
      dfTot <- rbind(dfTot, df)
    }
    
    results <- list()
    for (j in 2:nrow(dfTot)) {
      paramsxmlInsertResult <- list(
        TEMPLATE_ID = templateID(input$SensorMLURI, req(outputsParams())$lat[1], req(outputsParams())$lon[1], dfTot$par[j]),
        VALUES = paste0(listParam[,dfTot$col[1]], '#', listParam[,dfTot$col[j]], collapse = '@')
      )
      results[[j-1]] <- paste0(xslt::xml_xslt(xmlInsertResult, styleInsertResult, paramsxmlInsertResult), collapse = "")
    }
    
    for (h in length(results)) {
      xmlRequest <- results[[h]]
      xmlFile <- "request.xml"
      XML::saveXML(XML::xmlTreeParse(xmlRequest, useInternalNodes = T), xmlFile)
      response <- httr::POST(url = input$sosHost,
                 body = upload_file(xmlFile),
                 config = add_headers(c('Content-Type' = 'application/xml')))
      paste0(response, collapse = '')
    }
    
  })
  
  # Conditions for switch on the Upload observations button
  observe({
    toggleState("sendFile",
                condition = (input$SensorMLURI != "" & is.null(input$file1) == "FALSE" & input$finalCheck == "TRUE")
    )
  })
  
  # event fo upload data button
  observeEvent(input$sendFile, {
    req(input$file1)
    listParam <- read.csv(input$file1$datapath,
                          header = input$header,
                          sep = input$sep,
                          quote = input$quote
    )
    
    # xslInsertResult <- "https://www.get-it.it/objects/sensors/xslt/insertResult_4Shiny.xsl"
    xslInsertResult <- "./insertResult_4Shiny.xsl"
    styleInsertResult <- xml2::read_xml(xslInsertResult, package = "xslt")
    
    xmlInsertResult <- xml2::read_xml(
      # "https://www.get-it.it/objects/sensors/xslt/insertResult_4Shiny.xsl"
      "./insertResult_4Shiny.xsl",
      package = "xslt"
    )
    
    dfTot <- data.frame()
    for (v in 1:length(listParam)){
      a <- as.character(input[[paste0("params", v)]])
      b <- req(outputsParams()[(v),])
      df <- data.frame(col = which(colnames(listParam) == a), par = gsub(' ', '_', b[[2]][1]))
      dfTot <- rbind(dfTot, df)
    }
    
    results <- list()
    for (j in 2:nrow(dfTot)) {
      paramsxmlInsertResult <- list(
        TEMPLATE_ID = templateID(input$SensorMLURI, req(outputsParams())$lat[1], req(outputsParams())$lon[1], dfTot$par[j]),
        VALUES = paste0(listParam[,dfTot$col[1]], '#', listParam[,dfTot$col[j]], collapse = '@')
      )
      results[[j-1]] <- paste0(xslt::xml_xslt(xmlInsertResult, styleInsertResult, paramsxmlInsertResult), collapse = "")
    }
  })
}
# Run the app ----
shinyApp(ui, server)