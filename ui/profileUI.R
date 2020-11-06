tabItem(
  tabName = "profile",
  fluidRow(
    box(
      width = 4,
      title = "Inputs profile observations", 
      closable = FALSE, 
      status = "info", 
      solidHeader = FALSE, 
      collapsible = TRUE,
      # Input: sos host selection
      div(HTML("<h4>Server endpoint</h4>")),
      selectInput(inputId = "sosHostProfile",
                  label = "Select server where you want to upload observations", 
                  multiple = F,
                  choices = endpointsSos,
                  selected = "http://demo0.get-it.it"
      ),
      
      # Input: procedure URL
      div(HTML("<hr><h4><b>Station</b></h4>")),
      # TODO: add the link to the SOS endpoint selected above. A shinyBS::bsModal appairs in order to visualize the sensors page.
      selectInput(inputId = "SensorMLURIProfile",
                  label = HTML("Select name of the station/sensor (e.g. <a href=\"http://getit.lteritalia.it/sensors/sensor/ds/?format=text/html&sensor_id=http%3A//www.get-it.it/sensors/getit.lteritalia.it/procedure/CampbellScientificInc/noModelDeclared/noSerialNumberDeclared/20170914050327762_790362\">ENEA Santa Teresa meteorological station</a>)"), 
                  multiple = FALSE,
                  ""
      ),
      
      # Input: FOI POPUP
      actionButton(inputId = 'foiProfile', 
                   label = 'Click for provide station\'s position'
                   ),
      shinyBS::bsModal(
        id = "modalnewProfile",
        title = "Draw the marker for the new station's position if is not already present in the lisf above",
        trigger = "foiProfile",
        size = "large",
        # editModUI("editor"),
        leafletOutput(outputId = "mymap"),
        textInput("lat", "Latitude (e.g. 45.9206)"),
        textInput("long", "Longitude (e.g. 8.6019)"),
        #   # selectInput(inputId = "srs",
        #   #             label = "Projection",
        #   #             multiple = F,
        #   #             choices = list(
        #   #               "WGS84"="http://www.opengis.net/def/crs/EPSG/0/4326",
        #   #               "..." = ""
        #   #             ),
        #   #             selected = "http://www.opengis.net/def/crs/EPSG/0/4326"
        #   # ),
        textInput("gmlName", "Station's name"),
        textInput("sfSampledFeature", "Sampled Feature (URI)")
      ),
      div(HTML("<hr><h4>File</h4>")),
      # Input: Select a file
      checkboxInput("withTimeProfile", 
                    HTML("<b>Is your dataset with date and time?</b>"), 
                    TRUE),
      fileInput("file1Profile", "Choose CSV File",
                multiple = FALSE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")
      ),
      
      # Input: Checkbox if file has header ----
      checkboxInput("headerProfile", "Header", TRUE),
      
      # Input: Select separator ----
      radioButtons("sepProfile", "Separator",
                   choices = c(Comma = ",",
                               Semicolon = ";",
                               Tab = "\t"),
                   selected = ","),
      
      # Input: Select quotes ----
      radioButtons("quoteProfile", "Quote",
                   choices = c(None = "",
                               "Double Quote" = '"',
                               "Single Quote" = "'"),
                   selected = '"'),
      
      # Input: Select number of rows to display ----
      radioButtons("dispProfile", "Display",
                   choices = c(Head = "head",
                               All = "all"),
                   selected = "all"),
      checkboxInput("finalCheckProfile", 
                    HTML("<b>Check this box when all columns are matched</b>"), 
                    FALSE),
      actionButton("sendFileProfile", "Upload observations", icon = icon("file-upload"))
    ),
    # Main panel for displaying outputs ----
    boxPlus(
      width = 8,
      title = "Parameters matching", 
      closable = FALSE, 
      status = "info", 
      solidHeader = FALSE, 
      collapsible = TRUE,
      enable_sidebar = TRUE,
      sidebar_width = 25,
      sidebar_start_open = FALSE,
      sidebar_content = tagList(
        tags$p("The blue circles identify the amount of datasets shared in the site, the pins identify the LTER sites distributed in the world. By clicking on one of these you can get more information on the site and on the data sets shared by it."),
        tags$p(tags$b("Press i for collaps this slidebar."))
      ),
      fluidRow(
        column(6,
               div(HTML("<h4>Parameters observed by selected sensor</h4>")),
               DT::dataTableOutput(outputId = "outputsValueProfile")
        ),
        column(6,
               div(HTML("<h4>Colums headers (modify the saparator or the quote for display the name of the colums)</h4>")),
               uiOutput(outputId = "selectionParamsProfile")
        )
      )
    ),
    fluidRow(
      boxPlus(
        width = 12,
        title = "Observations table",
        closable = FALSE, 
        status = "info", 
        solidHeader = FALSE, 
        collapsible = TRUE,
        enable_sidebar = TRUE,
        sidebar_width = 25,
        sidebar_start_open = FALSE,
        sidebar_content = tagList(
          tags$p("The blue circles identify the amount of datasets shared in the site, the pins identify the LTER sites distributed in the world. By clicking on one of these you can get more information on the site and on the data sets shared by it."),
          tags$p(tags$b("Press i for collaps this slidebar."))
        ),
        column(12,
               div(HTML("<hr><h4>Observations will be imported</h4>")),
               # Output: Data file ----
               DT::dataTableOutput(outputId = "file1Profile"),
               uiOutput(outputId = "selectParamCSVProfile")
        )
      )
    )
  )
)