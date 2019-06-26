# Define UI for application that draws a histogram
shinyUI(
    fluidPage(
        dashboardPagePlus(
            skin = "green-light",
            collapse_sidebar = TRUE,
            dashboardHeaderPlus(
                title = tagList(
                    tags$span(class = "logo-lg", "eLTER - Upload obs"), 
                    tags$img(src = "http://www.get-it.it/assets/img/loghi/lter_leaf.jpg")), 
                # fixed = FALSE,
                # enable_rightsidebar = TRUE,
                # rightSidebarIcon = "gears",
                tags$li(class ="dropdown", 
                        tags$a(
                            href="http://www.lter-europe.net",
                            tags$img(src="http://www.get-it.it/assets/img/loghi/eLTERH2020.png"),
                            style="margin:0;padding-top:2px;padding-bottom:2px;padding-left:10px;padding-right:10px;",
                            target="_blank"
                        )
                ),
                tags$li(class ="dropdown", 
                        tags$a(
                            href="http://www.lteritalia.it",
                            tags$img(src="http://www.get-it.it/assets/img/loghi/LogoLTERIta.png"),
                            style="margin:0;padding-top:2px;padding-bottom:2px;padding-left:10px;padding-right:10px;",
                            target="_blank"
                        )
                )
            ),
            dashboardSidebar(
                collapsed = TRUE,
                sidebarMenu(
                    menuItem("Fixed Station", tabName = "fixed", icon = icon("map", lib = "font-awesome")),
                    menuItem("Profile", tabName = "profile", icon = icon("table", lib = "font-awesome"))
                )
            ),
            dashboardBody(
                tabItems(
                    tabItem(tabName = "fixed",
                            fluidRow(
                                box(
                                    width = 4,
                                    title = "Inputs", 
                                    closable = FALSE, 
                                    status = "info", 
                                    solidHeader = FALSE, 
                                    collapsible = TRUE,
                                    
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
                                boxPlus(
                                    width = 8,
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
                    ),
                    tabItem(tabName = "profile")
                )
            )
        )
    )
)
