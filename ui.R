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
library(rintrojs)
library(fs)
library(shinyalert)
# remotes::install_github("rstudio/shinyvalidate")
library(shinyvalidate)

###
# UI
###
shinyUI(
  fluidPage(
    introjsUI(),
    useShinyalert(),
    dashboardPagePlus(
      skin = "blue",
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
        )#,
        # tags$li(class = "dropdown",
        #         actionButton("help", "Give me an overview", style="margin-right: 10px; margin-top: 8px; color: #fff; background-color: #0069D9; border-color: #0069D9")
        # )
      ),
      dashboardSidebar(
        collapsed = TRUE,
        sidebarMenu(
          menuItem("Fixed Station", tabName = "fixed", icon = icon("map-marked-alt", lib = "font-awesome"))
          ,
          menuItem("Transect (vertical)", tabName = "profile", icon = icon("stream", lib = "font-awesome"))
          # ,
          # menuItem("Transect (horizontal)", tabName = "path", icon = icon("wave-square", lib = "font-awesome"))
          ,
          menuItem("On Sample", tabName = "sample", icon = icon("eyedropper", lib = "font-awesome"))
        )
      ),
      dashboardBody(
        tags$head(
          tags$link(rel = "stylesheet", type = "text/css", href = "css/style.css")
        ),
        tabItems(
          source("ui/fixedUI.R", local = TRUE)$value
          ,
          source("ui/profileUI.R", local = TRUE)$value
          # ,
          # source("ui/pathUI.R", local = TRUE)$value
          ,
          source("ui/sampleUI.R", local = TRUE)$value
        )
      )
    )
  )
)
