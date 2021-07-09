### validation capabilities 
iv <- InputValidator$new()
iv$add_rule("lat", sv_required())
iv$add_rule("long", sv_required())
iv$add_rule("gmlName", sv_required())
iv$add_rule("sfSampledFeature", sv_required())
iv$add_rule(
  "sfSampledFeature",
  ~ if (!is_valid_uri(.)) "Please provide a valid URL (e.g. http:://www.get-it.it)"
)
# iv$add_rule("sfSampledFeature", ~ if (!is_valid_email(.)) "Please provide a valid email")
iv$enable()

is_valid_uri <- function(x) {
  grepl("^(?:(?:http(?:s)?|ftp)://)(?:\\S+(?::(?:\\S)*)?@)?(?:(?:[a-z0-9\u00a1-\uffff](?:-)*)*(?:[a-z0-9\u00a1-\uffff])+)(?:\\.(?:[a-z0-9\u00a1-\uffff](?:-)*)*(?:[a-z0-9\u00a1-\uffff])+)*(?:\\.(?:[a-z0-9\u00a1-\uffff]){2,})(?::(?:\\d){2,5})?(?:/(?:\\S)*)?$",
        as.character(x),
        ignore.case=TRUE
        )
}
is_valid_email <- function(x) {
  grepl("^\\s*[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}\\s*$", as.character(x), ignore.case=TRUE)
}
### end validation capabilities 

coordinatesFOI <- reactiveValues(lat = NULL, lon = NULL)
output$mymap <- renderLeaflet({
  #Get setView parameters
  new_zoom <- 2
  if(!is.null(input$map_zoom)) new_zoom <- input$map_zoom
  new_lat <- 0
  if(!is.null(input$map_center$lat)) new_lat <- input$map_center$lat
  new_lon <- 0
  if(!is.null(input$map_center$lng)) new_lon <- input$map_center$lng
  
  leaflet() %>% addTiles() %>%
    setView(new_lon, new_lat, zoom = new_zoom) %>%
    # setView(lng = 0, lat = 0, zoom = 1) %>%
    addSearchOSM() %>%
    addDrawToolbar(
      #targetGroup = "new_points",
      polylineOptions = FALSE,
      polygonOptions = FALSE,
      rectangleOptions = FALSE,
      circleOptions = FALSE,
      circleMarkerOptions = FALSE,
      #markerOptions = TRUE,
      editOptions = editToolbarOptions(
        selectedPathOptions = selectedPathOptions()
      )
    )
})

observeEvent(c(input$mymap_draw_edited_features, input$mymap_draw_new_feature), {
  if (!is.null(input$mymap_draw_edited_features)) {
    click_lon <- input$mymap_draw_edited_features$features[[1]]$geometry$coordinates[[1]]
    click_lat <- input$mymap_draw_edited_features$features[[1]]$geometry$coordinates[[2]]
    coordinatesFOI$lat <- c(click_lat)
    coordinatesFOI$lon <- c(click_lon)
    updateTextInput(session, "lat", value = click_lat)
    updateTextInput(session, "long", value = click_lon)
  }
  else
    click_lat <- input$mymap_draw_new_feature$geometry$coordinates[[2]]
    click_lon <- input$mymap_draw_new_feature$geometry$coordinates[[1]]
    coordinatesFOI$lat <- c(click_lat)
    coordinatesFOI$lon <- c(click_lon)
    updateTextInput(session, "lat", value = click_lat)
    updateTextInput(session, "long", value = click_lon)
})

### Codelist for dropdown menu of stations from procedure and sml:Outputs elements within capabilities XML and DescribeSensor request
outputsParamsProfile <- reactive({
  listOutputs <- getOutputsList(sosHost = input$sosHostProfile, procedure = input$SensorMLURIProfile)
  listOutputs$name <- gsub('_', ' ', listOutputs$name)
  listOutputs <- as.data.frame(listOutputs)
  return(listOutputs)
})

outputsProceduresProfile <- reactive({
  listProcedure <- getProcedureList(input$sosHostProfile)
})

observe({
  updateSelectInput(session, "SensorMLURIProfile", choices = outputsProceduresProfile())
})
### End codelist

output$outputsValueProfile <- DT::renderDataTable({
  datatable(
    req(outputsParamsProfile()),
    selection = "none",
    colnames = c('Name', 'URI'),
    extensions = "Scroller",
    style = "bootstrap",
    class = "compact",
    escape = FALSE,
    editable = FALSE,
    rownames = FALSE,
    options = list(
      pageLength = 10,
      columnDefs = list(list(
        visible = FALSE,
        targets = c(2:6) - 1
      )),
      dom = 't',
      ordering = FALSE
    )
  )
}, server = TRUE)

output$file1Profile <- DT::renderDataTable({
  
  req(input$file1Profile)
  
  df <- read.csv(input$file1Profile$datapath,
                 header = input$headerProfile,
                 sep = input$sepProfile,
                 quote = input$quoteProfile
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
  
  if(input$dispProfile == "head") {
    return(head(
      datatable(df,
                selection = "none",
                extensions = "Scroller",
                style = "bootstrap",
                class = "compact",
                escape = FALSE,
                editable = FALSE,
                options = list(
                  pageLength = 10,
                  # columnDefs = list(list(
                  #   visible = FALSE
                  # )),
                  # dom = 't',
                  ordering = FALSE
                ),
                rownames = FALSE
      )
    ) %>% formatStyle('Time',  color = 'red', backgroundColor = 'orange', fontWeight = 'bold')
    )
  }
  else {
    return(
      datatable(df,
                selection = "none",
                extensions = "Scroller",
                style = "bootstrap",
                class = "compact",
                escape = FALSE,
                editable = FALSE,
                options = list(
                  pageLength = 10,
                  # columnDefs = list(list(
                  #   visible = FALSE
                  # )),
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

output$selectionParamsProfile <- renderUI({
  req(input$file1Profile)
  observationsTotal <- read.csv(input$file1Profile$datapath,
                        header = input$headerProfile,
                        sep = input$sepProfile,
                        quote = input$quoteProfile
  )
  
  #req(outputsParamsProfile())
  # if(length(observationsTotal) != length(outputsParamsProfile())) {
  #   div(HTML("<p>Please select a CSV file with the same number of colums compared to the number of parameter collected by the sensor selected</p>"))
  # }  else {
  lapply(1:length(observationsTotal), function(i) {
    # div(HTML(paste0("<p>", i ,"</p>")))
    selectInput(inputId = paste0("params", i),
                label = "", 
                multiple = F,
                choices = names(observationsTotal)
    )
  })
  # }
})

output$selectParamCSVProfile <- renderUI({
  req(input$file1Profile)
  
  observationsTotal <- read.csv(input$file1Profile$datapath,
                        header = input$headerProfile,
                        sep = input$sepProfile,
                        quote = input$quoteProfile
  )
  
  nValues <- nrow(observationsTotal)
  paramsXmlInsertResultProfile <- list(
    # from observationsTotal
    OM_ObservationID = 'o_1',
    BEGIN_TIME = observationsTotal %>% dplyr::arrange(date_time) %>% dplyr::slice(1) %>% dplyr::ungroup() %>% .[,1] %>% as.character(), # e.g. 2008-01-31T09:25:00
    NUM_VALUE = nrow(observationsTotal) %>% as.character(), # e.g. 123
    END_TIME = observationsTotal %>% dplyr::arrange(date_time) %>% dplyr::slice(nValues) %>% dplyr::ungroup() %>% .[,1] %>% as.character(), # e.g. 2008-01-31T09:28:55
    LAB_DATETIME = observationsTotal %>% dplyr::arrange(date_time) %>% .[nValues, 1] %>% as.character(), # e.g. 2008-01-31T09:28:55
    sweValues = observationsTotal %>% 
      dplyr::mutate(new = paste(date_time, depth, temperature, sep = "#")) %>% 
      dplyr::select(new) %>% 
      dplyr::summarise(obs = paste(new, collapse = '@')) %>% 
      as.character(), # e.g. 2008-01-31T09:25:00#1#13.04@2008-01-31T09:25:05#2#13.053@...
    # from input$SensorMLURIProfile
    PROCEDURE = input$SensorMLURIProfile, # e.g. http://sp7.irea.cnr.it/sensors/vesk.ve.ismar.cnr.it/procedure/Seabird/SBE37/noSerialNumberDeclared/20140223115413720_11525
    OFFERING = paste0(
      'offering:',
      input$SensorMLURIProfile,
      '/observations'
    ), # e.g. offering:<PROCEDURE>/observations
    # from sensor
    # OBS_PROPERTY = , # e.g. http://vocabs.lter-europe.net/EnvThes/20166
    omResult_sweField_name = req(outputsParamsProfile()) %>% 
      .[["name"]] %>% 
      gsub(' ', '_', .) %>% 
      as.list(), # e.g. Maximum_depth_below_surface_of_the_water_body
    omResult_sweField_definition = req(outputsParamsProfile()) %>% 
      .[["definition"]] %>% 
      gsub(' ', '_', .) %>% 
      as.list(), # e.g. http://vocab.nerc.ac.uk/collection/P01/current/MAXWDIST/
    omResult_sweField_sweUom_code = req(outputsParamsProfile()) %>% 
      .[["uom"]] %>% 
      gsub(' ', '_', .) %>% 
      as.list(), # e.g. m
    # from map
    SF_SpatialSamplingFeature_gmlName = paste0('Profile of ', input$gmlName), # e.g. PTF - Piattaforma Acqua Alta
    SF_SpatialSamplingFeature_gmlDescription = paste0('Profile collected in the station ', input$gmlName, ' within the eLTER site ', ReLTER::getSiteGeneral(input$sfSampledFeature)$title),
    SF_SpatialSamplingFeature_gmlId = paste0('SSF_profile_', gsub(pattern="[[:punct:]]|[[:space:]]", input$gmlName, replacement="_")), # e.g. PTF
    SF_SpatialSamplingFeature_identifier = paste0('http://www.get-it.it/sensors/getit.lteritalia.it/sensors/foi/SSF/SP/4326/', input$lat, '/', input$long), # e.g. http://www.get-it.it/sensors/getit.lteritalia.it/sensors/foi/SSF/SP/4326/45.3138/12.5088
    SF_SpatialSamplingFeature_sfSampledFeature = input$sfSampledFeature, # e.g. https://deims.org/f30007c4-8a6e-4f11-ab87-569db54638fe
    SF_SpatialSamplingFeature_gmlPoint_gmlId = paste0('point_', gsub(pattern="[[:punct:]]|[[:space:]]", input$gmlName, replacement="_")), # e.g. ptf
    SF_SpatialSamplingFeature_gmlPoint_gmlPos = paste0(
      input$lat,
      ' ',
      input$long
    ) # e.g. 45.3138 12.5088
  )
  
  xmlInsertObsProfile <- xml2::read_xml(
    "xslt/insertObsProfile_4Shiny.xml"
  )
  
  omObservationId <- xml2::xml_find_first(xmlInsertObsProfile, ".//om:OM_Observation")
  xml2::xml_attr(omObservationId, "gml:id") <- paramsXmlInsertResultProfile$OM_ObservationID
  
  offering <- xml2::xml_find_first(xmlInsertObsProfile, './/sos:offering/text()')
  xml2::xml_text(offering) <- paramsXmlInsertResultProfile$OFFERING
  
  beginTime <- xml2::xml_find_first(xmlInsertObsProfile, './/gml:beginPosition/text()')
  xml2::xml_text(beginTime) <- paramsXmlInsertResultProfile$BEGIN_TIME
  
  endTime <- xml2::xml_find_first(xmlInsertObsProfile, './/gml:endPosition/text()')
  xml2::xml_text(endTime) <- paramsXmlInsertResultProfile$END_TIME
  
  labDateTime <- xml2::xml_find_first(xmlInsertObsProfile, './/gml:timePosition/text()')
  xml2::xml_text(labDateTime) <- paramsXmlInsertResultProfile$LAB_DATETIME
  
  procedure <- xml2::xml_find_first(xmlInsertObsProfile, ".//om:procedure")
  xml2::xml_attr(procedure, "xlink:href") <- paramsXmlInsertResultProfile$PROCEDURE
  
  # obsProperty <- xml2::xml_find_first(xmlInsertObsProfile, ".//om:observedProperty")
  # xml2::xml_attr(obsProperty, "xlink:href") <- paramsXmlInsertResultProfile$OBS_PROPERTY
  
  numValue <- xml2::xml_find_first(xmlInsertObsProfile, './/swe:Count/swe:value/text()')
  xml2::xml_text(numValue) <- paramsXmlInsertResultProfile$NUM_VALUE
  
  sweValue <- xml2::xml_find_first(xmlInsertObsProfile, './/om:result/swe:DataArray/swe:values/text()')
  xml2::xml_text(sweValue) <- paramsXmlInsertResultProfile$sweValues
  
  # from map
  gmlPos <- xml2::xml_find_first(xmlInsertObsProfile, './/gml:pos/text()')
  xml2::xml_text(gmlPos) <- paramsXmlInsertResultProfile$SF_SpatialSamplingFeature_gmlPoint_gmlPos
  
  gmlName <- xml2::xml_find_first(xmlInsertObsProfile, './/gml:name/text()')
  xml2::xml_text(gmlName) <- paramsXmlInsertResultProfile$SF_SpatialSamplingFeature_gmlName
  
  gmlDescription <- xml2::xml_find_first(xmlInsertObsProfile, './/gml:description/text()')
  xml2::xml_text(gmlDescription) <- paramsXmlInsertResultProfile$SF_SpatialSamplingFeature_gmlDescription
  
  gmlId <- xml2::xml_find_first(xmlInsertObsProfile, './/om:featureOfInterest/sams:SF_SpatialSamplingFeature')
  xml2::xml_attr(gmlId, "gml:id") <- paramsXmlInsertResultProfile$SF_SpatialSamplingFeature_gmlId
  
  identifier <- xml2::xml_find_first(xmlInsertObsProfile, './/gml:identifier')
  xml2::xml_text(identifier) <- paramsXmlInsertResultProfile$SF_SpatialSamplingFeature_identifier
  
  sfSampledFeature <- xml2::xml_find_first(xmlInsertObsProfile, './/sf:sampledFeature')
  xml2::xml_attr(sfSampledFeature, 'xlink:href') <- paramsXmlInsertResultProfile$SF_SpatialSamplingFeature_sfSampledFeature
  
  gmlIdPoint <- xml2::xml_find_first(xmlInsertObsProfile, './/om:featureOfInterest/sams:SF_SpatialSamplingFeature/sams:shape/gml:Point')
  xml2::xml_attr(gmlIdPoint, "gml:id") <- paramsXmlInsertResultProfile$SF_SpatialSamplingFeature_gmlPoint_gmlId
  
  phenomenomTime <- xml2::xml_new_root(
    'swe:DataRecord',
    "xmlns:swe" = "http://www.opengis.net/swe/2.0",
    "xmlns:xlink" = "http://www.w3.org/1999/xlink"
  ) %>%
    xml2::xml_add_child("swe:field") %>% 
    xml2::xml_add_child("swe:Time") %>%
    xml2::xml_add_child("swe:uom") %>%
    xml2::xml_root()
  fieldTime <- xml2::xml_find_first(phenomenomTime, ".//swe:field")
  TimeTime <- xml2::xml_find_first(phenomenomTime, ".//swe:Time")
  uomTime <- xml2::xml_find_first(phenomenomTime, ".//swe:uom")
  xml2::xml_attrs(fieldTime) <- c(name = 'phenomenonTime')
  xml2::xml_attrs(TimeTime) <- c(definition = 'http://www.opengis.net/def/property/OGC/0/PhenomenonTime')
  xml2::xml_attr(uomTime, "xlink:href" ) <- 'http://www.opengis.net/def/uom/ISO-8601/0/Gregorian'
  for (i in 1:length(paramsXmlInsertResultProfile$omResult_sweField_name)) {
    omResultFields <- xml2::xml_new_root(
      'root',
      "xmlns:swe" = "http://www.opengis.net/swe/2.0"
    ) %>%
      xml2::xml_add_child("swe:field") %>% 
      xml2::xml_add_child("swe:Quantity") %>%
      xml2::xml_add_child("swe:uom") %>%
      xml2::xml_root()
    
    field <- xml2::xml_find_first(omResultFields, ".//swe:field")
    quantity <- xml2::xml_find_first(omResultFields, ".//swe:Quantity")
    uom <- xml2::xml_find_first(omResultFields, ".//swe:uom")
    xml2::xml_attrs(field) <- c(name = paramsXmlInsertResultProfile$omResult_sweField_name[[i]])
    xml2::xml_attrs(quantity) <- c(definition = paramsXmlInsertResultProfile$omResult_sweField_definition[[i]])
    xml2::xml_attrs(uom) <- c(code = paramsXmlInsertResultProfile$omResult_sweField_sweUom_code[[i]])
    xml2::xml_add_child(phenomenomTime, xml2::xml_find_first(omResultFields, ".//swe:field"))
  }
  omResult <- xml2::xml_find_first(xmlInsertObsProfile, './/swe:DataRecord')
  omResultAll <- phenomenomTime #%>% xml_children()
  xml2::xml_replace(omResult, omResultAll)
  
  xmlFilePath <- "requestProfile.xml"
  xmlFile <- file(xmlFilePath, "wt")
  xml2::write_xml(xmlInsertObsProfile, xmlFilePath)
  
  tags$form(tags$textarea(id = "code",
                          name = "code",
                          as.character(xml2::read_xml(xmlFilePath))
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

observe({
  toggleState("sendFileProfile",
              condition = (input$SensorMLURIProfile != "" & is.null(input$file1Profile) == "FALSE" & input$finalCheckProfile == "TRUE"))
})