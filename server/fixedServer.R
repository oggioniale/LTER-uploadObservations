# Alert
# Show a simple modal
global <- reactiveValues(response = FALSE)
observe({
  input$sosHost
  # Show a simple modal
  shinyalert(
    title = "Upload observations interface!",
    type = "info",
    confirmButtonText = "Give me an overview",
    timer = 3000,
    showCancelButton = TRUE
  )
})

# start introjs when button is pressed with custom options and events
observe({
  req(input$shinyalert)
  introjs(session, options = list("nextLabel" = "Next →",
                                  "prevLabel" = "← Back",
                                  "skipLabel" = "Skip"),
          events = list("oncomplete" = I('alert("Overview completed.")')))
})

### Codelist for dropdown menu of stations from procedure and sml:Outputs elements within capabilities XML and DescribeSensor request
outputsParamsFixed <- reactive({
  listOutputs <- getOutputsList(sosHost = input$sosHostFixed, procedure = input$SensorMLURIFixed)
  listOutputs$name <- gsub('_', ' ', listOutputs$name)
  listOutputs <- as.data.frame(listOutputs)
  return(listOutputs)
})

outputsProcedures <- reactive({
  listProcedure <- getProcedureList(input$sosHostFixed)
})

observe({
  updateSelectInput(session, "SensorMLURIFixed", choices = outputsProcedures())
})
### End codelist
listaParametri <- reactiveValues(
  listSensorOutputs = list(),
  lunghezza = 0,
  dimensione = c(0,0)
)
observe({
  listaParametri$listSensorOutputs <- outputsParamsFixed()
  listaParametri$lunghezza <- length(outputsParamsFixed())
  listaParametri$dimensione <- dim(outputsParamsFixed())
})
output$outputsValueFixed <- DT::renderDataTable({
  outputDataTable <- datatable(
    listaParametri$listSensorOutputs,
    selection = "none",
    colnames = NULL,
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
  return(
    outputDataTable
  )
},
  server = TRUE
)

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
                  pageLength = 30,
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
                extensions = "Scroller",
                style="bootstrap",
                class="compact",
                escape = FALSE,
                editable = FALSE,
                options = list(
                  pageLength = 30,
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

output$selectionParamsFixed <- renderUI({
  req(input$file1)
  listParam <- read.csv(input$file1$datapath,
                        header = input$header,
                        sep = input$sep,
                        quote = input$quote
  )
  
  #req(outputsParamsFixed())
  # if(length(listParam) != length(outputsParamsFixed())) {
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

# codeXMLFixed
output$codeXMLFixed <- renderUI({
  req(input$file1)
  listParam <- read.csv(input$file1$datapath,
                        header = input$header,
                        sep = input$sep,
                        quote = input$quote
  )
  
  # xslInsertResult <- "https://www.get-it.it/objects/sensors/xslt/insertResult_4Shiny.xsl"
  xslInsertResult <- "./xslt/insertResult_4Shiny.xsl"
  styleInsertResult <- xml2::read_xml(xslInsertResult, package = "xslt")
  
  xmlInsertResult <- xml2::read_xml(
    # "https://www.get-it.it/objects/sensors/xslt/insertResult_4Shiny.xsl"
    "./xslt/insertResult_4Shiny.xsl",
    package = "xslt"
  )
  
  dfTot <- data.frame()
  for (v in 1:length(listParam)){
    a <- as.character(input[[paste0("params", v)]])
    b <- req(outputsParamsFixed()[(v),])
    df <- data.frame(col = which(colnames(listParam) == a), par = gsub(' ', '_', b[[2]][1]))
    dfTot <- rbind(dfTot, df)
  }
  
  results <- list()
  for (j in 2:nrow(dfTot)) {
    paramsxmlInsertResult <- list(
      TEMPLATE_ID = templateID(input$SensorMLURI, req(outputsParamsFixed())$lat[1], req(outputsParamsFixed())$lon[1], dfTot$par[j]),
      VALUES = paste0(listParam[,dfTot$col[1]], '#', listParam[,dfTot$col[j]], collapse = '@')
    )
    results[[j-1]] <- paste0(xslt::xml_xslt(xmlInsertResult, styleInsertResult, paramsxmlInsertResult), collapse = "")
  }
  
  for (h in length(results)) {
    xmlFilePath <- paste("request", h, ".xml", sep = "")
    xmlFile <- file(xmlFilePath, "wt")
    xml2::write_xml(xml2::read_xml(results[[h]]), xmlFilePath)
  }
  
  # print(results[[h]])
  
  # Create a Progress object
  progress <- shiny::Progress$new()
  # Make sure it closes when we exit this reactive, even if there's an error
  on.exit(progress$close())
  progress$set(message = "Making XML request", value = 0)
  
  tags$form(tags$textarea(id = "code",
                          name = "code",
                          as.character(results[[h]])
                          ),
            tags$script(
              HTML(
                "var editorXML = CodeMirror.fromTextArea(document.getElementById(\"code\"), {
          mode: \"xml\",
          lineNumbers: true,
          smartindent: true,
          extraKeys: {\"Ctrl-Space\": \"autocomplete\"}
          });
          editorXML.setSize(\"100%\",\"100%\");"
              )
            ))
})

# Conditions for switch on the Upload observations button
# TODO verify why with this dashboardPagePlus the conditions are not verifing
observe({
  toggleState("sendFile",
              condition = (input$SensorMLURI != "" & is.null(input$file1) == "FALSE" & input$finalCheck == "TRUE")
  )
})

# event for upload data button
observeEvent(input$sendFile, {
  req(input$file1)
  listParam <- read.csv(input$file1$datapath,
                        header = input$header,
                        sep = input$sep,
                        quote = input$quote
  )
  
  # xslInsertResult <- "https://www.get-it.it/objects/sensors/xslt/insertResult_4Shiny.xsl"
  xslInsertResult <- "./xslt/insertResult_4Shiny.xsl"
  styleInsertResult <- xml2::read_xml(xslInsertResult, package = "xslt")
  
  xmlInsertResult <- xml2::read_xml(
    # "https://www.get-it.it/objects/sensors/xslt/insertResult_4Shiny.xsl"
    "./xslt/insertResult_4Shiny.xsl",
    package = "xslt"
  )
  
  dfTot <- data.frame()
  for (v in 1:length(listParam)){
    a <- as.character(input[[paste0("params", v)]])
    b <- req(outputsParamsFixed()[(v),])
    df <- data.frame(col = which(colnames(listParam) == a), par = gsub(' ', '_', b[[2]][1]))
    dfTot <- rbind(dfTot, df)
  }
  
  results <- list()
  for (j in 2:nrow(dfTot)) {
    paramsxmlInsertResult <- list(
      TEMPLATE_ID = templateID(input$SensorMLURI, req(outputsParamsFixed())$lat[1], req(outputsParamsFixed())$lon[1], dfTot$par[j]),
      VALUES = paste0(listParam[,dfTot$col[1]], '#', listParam[,dfTot$col[j]], collapse = '@')
    )
    results[[j-1]] <- paste0(xslt::xml_xslt(xmlInsertResult, styleInsertResult, paramsxmlInsertResult), collapse = "")
  }
  
  for (h in length(results)) {
    
    xmlFilePath <- paste("request", h, ".xml", sep = "")
    xmlFile <- file(xmlFilePath, "wt")
    xml2::write_xml(xml2::read_xml(results[[h]]), xmlFilePath)
    
    # xmlRequest <- results[[h]]
    # xmlFile <- "request.xml"
    # XML::saveXML(XML::xmlTreeParse(xmlRequest, useInternalNodes = T), xmlFile)
    
    if (input$sosHost == 'http://getit.lteritalia.it') {
      # provide the token of GET-IT LTER-italy
      tokenSOS <- paste0('Authorization = Token ', 'aayhb2087npouKKKaiu')
      response <- httr::POST(url = paste0(input$sosHost, '/observations/service'),
                             body = upload_file(xmlFilePath),
                             config = add_headers(c('Content-Type' = 'application/xml', tokenSOS)))
      paste0(response, collapse = '')
    }
    # }  else if (input$sosHost == 'https://uk-lter-sos.sos.cdn.lter-europe.net') {
    #     # provide the token of CDN
    #     tokenSOS <- paste0('Token ', 'xxxxxxxxxxxx')
    #     response <-
    #         httr::POST(
    #             url = paste0(input$sosHost, '/service'),
    #             body = upload_file(xmlFilePath),
    #             config = add_headers(
    #                 c(
    #                     'Content-Type' = 'application/xml',
    #                     'Authorization' = tokenSOS
    #                 )
    #             )
    #         )
    #     cat(paste0(response, collapse = ''))
    # } else if (input$sosHost == 'http://vesk.ve.ismar.cnr.it') {
    #     response <-
    #         httr::POST(
    #             url = paste0(input$sosHost, 'observations/sos/pox'),
    #             body = upload_file(xmlFilePath),
    #             config = add_headers(
    #                 c(
    #                     'Content-Type' = 'application/xml'
    #                 )
    #             )
    #         )
    #     cat(paste0(response, collapse = ''))
    # } else if (input$sosHost == 'http://nextdata.get-it.it') {
    #     response <-
    #         httr::POST(
    #             url = paste0(input$sosHost, 'observations/sos/pox'),
    #             body = upload_file(xmlFilePath),
    #             config = add_headers(
    #                 c(
    #                     'Content-Type' = 'application/xml'
    #                 )
    #             )
    #         )
    #     cat(paste0(response, collapse = ''))
    # } else if (input$sosHost == 'http://wsncentral.iecolab.es') {
    #     # provide the token of iecolab
    #     tokenSOS <- paste0('Token ', 'xxxxxxxxxxxx')
    #     response <-
    #         httr::POST(
    #             url = paste0(input$sosHost, '/sos/service'),
    #             body = upload_file(xmlFilePath),
    #             config = add_headers(
    #                 c(
    #                     'Content-Type' = 'application/xml',
    #                     'Authorization' = tokenSOS
    #                 )
    #             )
    #         )
    #     cat(paste0(response, collapse = ''))
    # } else if (input$sosHost == 'http://teodoor.icg.kfa-juelich.de') {
    #     response <-
    #         httr::POST(
    #             url = paste0(input$sosHost, '/elter.sos/sos'),
    #             body = upload_file(xmlFilePath),
    #             config = add_headers(
    #                 c(
    #                     'Content-Type' = 'application/xml'
    #                 )
    #             )
    #         )
    #     cat(paste0(response, collapse = ''))
    # } else if (input$sosHost == 'http://sk.ise.cnr.it') {
    #     response <-
    #         httr::POST(
    #             url = paste0(input$sosHost, '/observations/sos/pox/'),
    #             body = upload_file(xmlFilePath),
    #             config = add_headers(
    #                 c(
    #                     'Content-Type' = 'application/xml'
    #                 )
    #             )
    #         )
    #     cat(paste0(response, collapse = ''))
    # }
  }
})