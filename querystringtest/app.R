# Example of using Javascript to set URL and change input
# For some reason it works only once though
library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
    tags$head(
        tags$script(HTML(
            'function setSlider(value) {
                Shiny.setInputValue("sliderFromURL", value)
            }'
        ))
    ),

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30),
            tags$a(href = "#", 
                   onclick = "setSlider(30)",
                   "30")
        ),

        # Show a plot of the generated distribution
        mainPanel(
           textOutput("querystring")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {

    # Read the input set with JavaScript
    # Set the bins parameter in the URL (will be read below)
    observeEvent(input$sliderFromURL, {
        updateQueryString(paste0("?bins=",input$sliderFromURL), "push")
    })
    
    # Observe the sessoin clientData object
    # If bins is there, update the slider input with the new value
    observe({ 
        query <- parseQueryString(session$clientData$url_search)
        if (!is.null(query$bins)) {
            message(query$bins)
            updateQueryString(NULL)
            updateSliderInput(session, "bins", value = query$bins)
        }
    })
    
    # Read the slider input
    output$querystring <- renderText({
        input$bins
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
