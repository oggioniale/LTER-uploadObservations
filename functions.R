###
# Functions
###
# create templateID
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

# List of procedure URI and name by SOS endpoint
getProcedureList <- function(sosHost) {
  # xslProcUrl.url <- "https://www.get-it.it/objects/sensors/xslt/Capabilities_proceduresUrlList.xsl"
  xslProcUrl.url <- "./xslt/Capabilities_proceduresUrlList.xsl"
  styleProcUrl <- read_xml(xslProcUrl.url, package = "xslt")
  listProcedure <- read.csv(text = xml_xslt((
    read_xml(
      paste0(sosHost,
             '/observations/service?service=SOS&request=GetCapabilities&Sections=Contents'),
      package = "xslt"
    )
  ), styleProcUrl), header = TRUE, sep = ';', as.is = TRUE)
  
  if (nrow(listProcedure) == 0) {
    listProcedure <- list()
  } else {
    sensorName <- vector("character", nrow(listProcedure))
    for (i in 1:nrow(listProcedure)) {
      SensorML <- read_xml(
        as.character(
          paste0(
            sosHost,
            '/observations/service?service=SOS&amp;version=2.0.0&amp;request=DescribeSensor&amp;procedure=',
            listProcedure$uri[i],
            '&amp;procedureDescriptionFormat=http%3A%2F%2Fwww.opengis.net%2FsensorML%2F1.0.1'
          )
        )
      )
      ns <- xml_ns(SensorML)
      sensorName[i] <- as.character(xml_find_all(
        SensorML, 
        "//sml:identification/sml:IdentifierList/sml:identifier[@name='short name']/sml:Term/sml:value/text()",
        ns
      ))
      
    }
    listProcedure <- as.list(listProcedure$uri)
    names(listProcedure) <- sensorName
  }
  
  return(listProcedure)
}
# getProcedureList(sosHost = 'http://getit.lteritalia.it')

# List of sml:outputs name, definition and code by SOS endpoint and Procedure endpoint
getOutputsList <- function(sosHost, procedure) {
  # xslObs.url <- "https://www.get-it.it/objects/sensors/xslt/sensor2outputs_4Shiny.xsl"
  xslObs.url <- "xslt/sensor2outputs_4Shiny.xsl"
  style <- read_xml(xslObs.url, package = "xslt")
  listOutputs <- read.csv(text = xml_xslt((
    read_xml(
      paste0(
        sosHost, # https://sensorweb.demo.52north.org/52n-sos-webapp/service
        '/observations/sos/kvp?service=SOS&version=2.0.0&request=DescribeSensor&procedure=',
        procedure, # http://www.52north.org/test/procedure/9
        '&procedureDescriptionFormat=http://www.opengis.net/sensorml/2.0'
      ),
      package = "xslt"
    )
  ), style), header = TRUE, sep = ';')
  
  return(listOutputs)
}
# getOutputsList(sosHost = 'http://demo0.get-it.it', procedure = 'http://sp7.irea.cnr.it/sensors/getit.lteritalia.it/procedure/CampbellScientificInc/noModelDeclared/noSerialNumberDeclared/20170914050327762_790362')

