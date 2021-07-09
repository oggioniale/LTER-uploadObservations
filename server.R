###
# Sources
###
source("functions.R", local = TRUE)$value

###
# Server
###
shinyServer(function(input, output, session) {
    
    # Server fixed station
    source("server/fixedServer.R", local = TRUE)$value
    
    # Server profile
    source("server/profileServer.R", local = TRUE)$value
    
    # Server profile
    # source("server/pathServer.R", local = TRUE)$value
    
    # Server bio
    # source("server/sampleServer.R", local = TRUE)$value

})
