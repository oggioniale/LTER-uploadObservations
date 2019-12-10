tabItem(
  tabName = "fixed",
  fluidRow(
    box(
      width = 4,
      title = "Inputs", 
      closable = FALSE, 
      status = "info", 
      solidHeader = FALSE, 
      collapsible = TRUE,
      
      # Input: sos host selection
      introBox(
        div(HTML("<h4><b>Server endpoint</b></h4>")),
        selectInput(inputId = "sosHost",
                    label = "Select server where you want to upload observations", 
                    multiple = F,
                    choices = list(
                      "LTER-Italy SOS (default) (SOS v2.0.0)" = "http://getit.lteritalia.it"#,
                      # "LTER-Eu CDN SOS (SOS v2.0.0)" = "https://uk-lter-sos.sos.cdn.lter-europe.net", # https://uk-lter-sos.sos.cdn.lter-europe.net/service
                      # "LTER-Italy CNR ISMAR - Venezia (SOS v2.0.0)" = "http://vesk.ve.ismar.cnr.it", # http://vesk.ve.ismar.cnr.it/observations/sos/pox
                      # "NextData Project (SOS v2.0.0)" = "http://nextdata.get-it.it", # http://nextdata.get-it.it/observations/sos/pox
                      # "iEcolab (SOS v1.0.0)" = "http://wsncentral.iecolab.es", # http://wsncentral.iecolab.es/sos/service
                      # "IBG-3 Eifel Rur (SOS v1.0.0)" = "http://teodoor.icg.kfa-juelich.de", # http://teodoor.icg.kfa-juelich.de/elter.sos/sos
                      # "LTER-Italy CNR IRSA - Pallanza (SOS v2.0.0)" = "http://sk.ise.cnr.it" # http://sk.ise.cnr.it/observations/sos/pox/
                    ),
                    selected = "http://getit.lteritalia.it"
        ),
        data.step = 1,
        data.intro = "In this dropdown menu you can select the SOS where you want to upload the observations and where is stored the station/sensor information."
      ),
      
      # Input: procedure URL
      introBox(
        div(HTML("<hr><h4><b>Station</b></h4>")),
        # TODO: add the link to the SOS endpoint selected above. A shinyBS::bsModal appairs in order to visualize the sensors page.
        selectInput(inputId = "SensorMLURI",
                    label = HTML("Select name of the station/sensor (e.g. <a href=\"http://getit.lteritalia.it/sensors/sensor/ds/?format=text/html&sensor_id=http%3A//www.get-it.it/sensors/getit.lteritalia.it/procedure/CampbellScientificInc/noModelDeclared/noSerialNumberDeclared/20170914050327762_790362\">ENEA Santa Teresa meteorological station</a>)"), 
                    multiple = FALSE,
                    ""
        ),
        data.step = 2,
        data.intro = "This is the dopdown menu where you must select the name of the station/sensor."
      ),
      
      # Input: Select a file ----
      introBox(
        div(HTML("<hr><h4><b>File</b></h4>")),
        fileInput("file1", "Choose CSV File",
                multiple = FALSE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")
        ),
        data.step = 3,
        data.intro = "..."
      ),
      
      # Input: Checkbox if file has header ----
      introBox(
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
        data.step = 4,
        data.intro = "..."
      ),
      
      HTML("<br>"),
      
      introBox(
        checkboxInput("finalCheck", 
                      HTML("<b>Check this box when all columns are matched</b>"), 
                      FALSE),
        data.step = 6,
        data.intro = "..."
      ),
      
      introBox(
        actionButton("sendFile", "Upload observations", icon = icon("file-upload")),
        data.step = 7,
        data.intro = "..."
      )
    ),
    introBox(
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
        column(6,
               div(HTML("<h4>Parameters observed by selected sensor</h4>")),
               DT::dataTableOutput("outputsValue")
        ),
        column(6,
               div(HTML("<h4>Colums headers (modify the saparator or the quote for display the name of the colums)</h4>")),
               uiOutput("selectionParams")
        )
      ),
      data.step = 5,
      data.intro = "..."
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
             div(HTML("<hr><h4>Observations to be imported</h4>")),
             # Output: Data file ----
             DT::dataTableOutput("file1"),
             verbatimTextOutput("selectParamCSV")
      )
    )
  )
)
