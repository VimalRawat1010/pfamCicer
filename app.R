#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(RMySQL)
library(DBI)

# Define UI for application that draws a histogram
ui <- fluidPage(theme ="bootstrap.css",
                
                
                # Application title
                titlePanel(h1("Cicer pFAM"),windowTitle ="Pfam"),
                inverse = TRUE,
                
                # Sidebar with a slider input for number of bins
                sidebarLayout(
                  sidebarPanel(
                    selectInput("genome", "Select Genome",c("Cicer A" = "cicer","A. thaliana" = "athat","A. lyrata" = "alyr","C. rubella" = "cap")),
                    h5(uiOutput("userID")),
                    #h3(dateInput("date", "Date:", value = NULL, min = NULL, max = NULL, startview = "month", weekstart = 0,language = "en", width = NULL)),
                    #h3(radioButtons("beers", "Beers:", c( "1" = 1,"2-3" = 3,">3" = 4), selected="1", inline = TRUE)),
                    sliderInput("eval","E-value", min=0, max=0.13, value=0.001),
                    h3(actionButton("enterdata", "Enter", style='font-size:100%'))),
                    
                  # Show a plot of the generated distribution
                  mainPanel(h5(textOutput("text1")), h5(tableOutput("tbl")), h5(tableOutput("tbl1"))
                  )
                )
)



############
server <- function(input, output, session) {
  
  
  data_sets  <- reactive({
    conn2 <- dbConnect(
      drv = RMySQL::MySQL(),
      dbname = "cicer_pfam",
      host = "localhost",
      username = "root",
      password = "abc123")
    on.exit(dbDisconnect(conn2), add = TRUE)
    return (dbGetQuery(conn2, paste0("SELECT  DISTINCT target FROM cicer_pfam.pfam_table ORDER BY target ASC;")))
    
  })
  # Drop-down selection box for which data set
  output$userID <- renderUI({
    selectInput("uID", "Gene Family", as.list(data_sets()))
  })
  
  output$data_table <- renderTable({
    # If missing input, return to avoid error later in function
    #if(is.null(input$uID))
    #return()
    
    # Get the data set
    get(input$uID)
    
  })
  
  goButton1 <- eventReactive(input$enterdata,{
    output$tbl <- renderTable({
      conn <- dbConnect(
        drv = RMySQL::MySQL(),
        dbname = "cicer_pfam",
        host = "localhost",
        username = "root",
        password = "abc123")
      on.exit(dbDisconnect(conn), add = TRUE)
      dbGetQuery(conn, paste0("SELECT target, accession, query_name, Evalue_domain, description FROM cicer_pfam.pfam_table WHERE  target like '" , input$uID ,"' and Evalue_domain < ", input$eval , ";"))
    })
  })
  
  
  goButton2 <- eventReactive(input$enterdata,{
    
    conn1 <- dbConnect(
      drv = RMySQL::MySQL(),
      dbname = "cicer_pfam",
      host = "localhost",
      username = "root",
      password = "abc123")
    on.exit(dbDisconnect(conn1), add = TRUE)
    #dbGetQuery(conn1, paste0("insert into cicer_pfam.pfam_table ( UserID, date, beers) values ('",input$uID,"', '",input$date,"',",input$beers, ") ;"))
    
  })
  
  output$text1 <- renderText({
    #paste0("Please varify", input$uID,", Today :", input$date, "You drank:", input$beers, " beer(s)")
    goButton1()
    goButton2()
  })
  
  
  
}
############

#server <- function(input, output,session) {
#
#    d <- eventReactive(input$enterdata, { input$uID })
#    observeEvent(input$button, {
#                                  paste("insert into beerclub.beerclub (UserID, data, beers) values (",input$uID,",",input$date,",",input$beers)
#                                  result<-reactive({dbSendQuery(con, sql())})
#                                  output$text1 <- renderText({
#                                                              paste("Please varify", input$uID,", Today :", input$date, "You drank:", input$beers, " beer(s)")
#                                                            })
#                           })
#
#}

# Run the application
shinyApp(ui = ui, server = server)
