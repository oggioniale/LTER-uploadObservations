tabItem(
  tabName = "profile",
  fluidRow(
    boxPlus(
      width = 4,
      title = "Inputs profile observations", 
      closable = FALSE, 
      status = "info", 
      solidHeader = FALSE, 
      collapsible = TRUE,
      enable_sidebar = TRUE,
      sidebar_width = 25,
      sidebar_start_open = FALSE,
      sidebar_content = tagList(
        tags$p("This section allows to upload the observations, retrieved by a sensor running along a vertical profile/transect (e.g. a column of water or air, a well, etc.), in the LTER-Italy system."),
        tags$p(tags$b("Press the gear for collaps this slidebar and start with the work."))
      ),
      column(12,
             # Input: sos host selection
             div(HTML("<h4>Server endpoint</h4>")),
             selectInput(inputId = "sosHostProfile",
                         label = "Select server where you want to upload observations", 
                         multiple = F,
                         choices = endpointsSos,
                         selected = "http://getit.lteritalia.it"
             ),
             
             # Input: procedure URL
             div(HTML("<hr><h4><b>Sensor</b></h4>")),
             # TODO: add the link to the SOS endpoint selected above. A shinyBS::bsModal appairs in order to visualize the sensors page.
             selectInput(inputId = "SensorMLURIProfile",
                         label = HTML("Select name of the station/sensor (e.g. <a href=\"http://getit.lteritalia.it/sensors/sensor/ds/?format=text/html&sensor_id=http%3A//www.get-it.it/sensors/getit.lteritalia.it/procedure/CampbellScientificInc/noModelDeclared/noSerialNumberDeclared/20170914050327762_790362\" target=\"_blank\">ENEA Santa Teresa meteorological station</a>)"), 
                         multiple = FALSE,
                         ""
             ),
             
             # Input: FOI POPUP
             actionButton(inputId = 'foiStationProfile', 
                          label = HTML('Provide information about the station')
             ),
             shinyBS::bsModal(
               id = "modalnewProfile",
               title = "Draw the marker for the new station's position or select one of station.",
               trigger = "foiStationProfile",
               size = "large",
               fluidRow(
                 column(6, DT::dataTableOutput(outputId = "oldStationProfile")),
                 column(6, leafletOutput(outputId = "mymap")),
                 column(
                   12,
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
                   textInput(
                     "sfSampledFeature", 
                     HTML(
                       "Sampled Feature URI - Please provide the DEIMS.iD of the eLTER site (e.g. <a href=\"https://deims.org/f30007c4-8a6e-4f11-ab87-569db54638fe\" target=\"_blank\">Lago Maggiore</a>)"
                     )
                   )
                 )
               )#,
               # verbatimTextOutput('x4')
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
      )
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
        tags$p("The box is use to match the parameters observed by the station selected and the headers of the colums in the file uploaded. This allows to: i. verify that the observations  that you would like to upload have the correct units of measurement; ii. upload properly the observations with the properties observed; iii. enrich the observation with the semantic information about the property observed (verify the property concept by click on the parameter)."),
        tags$p("It is assumed that the observations being uploaded have been collected by the selected sensor."),
        tags$p(tags$b("Press the gear for collaps this slidebar and start with the work."))
      ),
      column(6,
             div(HTML("<h4>Parameters observed by selected sensor</h4>")),
             DT::dataTableOutput(outputId = "outputsValueProfile")
      ),
      column(6,
             div(HTML("<h4>Colums headers (modify the saparator or the quote for display the name of the colums)</h4>")),
             uiOutput(outputId = "selectionParamsProfile")
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