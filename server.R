###
# Sources
###
source("functions.R", local = TRUE)$value

###
# Server
###
shinyServer(function(input, output) {

    # xslObs.url <- "https://www.get-it.it/objects/sensors/xslt/sensor2outputs_4Shiny.xsl"
    xslObs.url <- "./sensor2outputs_4Shiny.xsl"
    style <- read_xml(xslObs.url, package = "xslt")
    outputsParams <- reactive({
        listOutputs <- read.csv(text = xml_xslt((
            read_xml(
                paste0(input$sosHost,
                       '/observations/sos/kvp?service=SOS&version=2.0.0&request=DescribeSensor&procedure=',
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
            if (input$sosHost == 'http://getit.lteritalia.it') {
                # provide the token of GET-IT LTER-italy
                tokenSOS <- paste0('Authorization = Token ', 'xxxxxxxxxxxx')
                response <- httr::POST(url = paste0(input$sosHost, '/observations/service'),
                                       body = upload_file(xmlFile),
                                       config = add_headers(c('Content-Type' = 'application/xml', tokenSOS)))
                paste0(response, collapse = '')
            } else {
                # provide the token of CDN
                tokenSOS <- paste0('Authorization = Token ', 'xxxxxxxxxxxx')
                response <- httr::POST(url = paste0(input$sosHost, '/observations/service'),
                                       body = upload_file(xmlFile),
                                       config = add_headers(c('Content-Type' = 'application/xml', tokenSOS)))
                paste0(response, collapse = '')
            }
        }
        print(tokenSOS)
        
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

})
