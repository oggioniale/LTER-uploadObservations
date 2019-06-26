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

###
# UI
###
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
                    source("fixedUI.R", local = TRUE)$value,
                    source("profileUI.R", local = TRUE)$value
                )
            )
        )
    )
)
