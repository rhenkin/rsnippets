# navbarPage with modules and URL parameter navigation
#
# Main pattern for navigation is creating hrefs for:
# /?tab=module_name
#  tab is read by the app server function, in theory can have any name
# URL parameters are read through:
# query <- parseQueryString(session$clientData$url_search)
# So we will look for query[["tab"]] and call
# updateNavbarPage with selected = query[["tab"]]
# and pass remaining arguments to session$userData$module_name
# 
# Additional important values to keep track of:
# - value in tabPanel for each module
# - id of navbarPage
# - inputId for the inputs in each module
#
# Example app does not include all error checking that would be required

library(shiny)

# Module that sends URL parameters
module1_ui <- function() {
    ns <- NS("module1")
    tabPanel("Module 1",
             value = "module1",
             fluidPage(
                 uiOutput(ns("text_output"))
             ))
}

# Module which receives URL parameters
module2_ui <- function() {
    ns <- NS("module2")
    tabPanel("Module 2",
             value = "module2",
             fluidPage(
                 radioButtons(ns("radiobtn"),
                              "Select an option",
                              choices = c("a", "b", "c")),
                 selectizeInput(ns("selection"),
                                "Select from list",
                                choices = c("d" , "e", "f"))
             ))
}

ui <- fluidPage(
    navbarPage(title = "Shiny navbarPage links test",
               id = "mainMenu",
               module1_ui(),
               module2_ui())
)

module1_server <- function() {
    moduleServer(
        "module1",
        function(input, output, session) {
            output$text_output <- renderUI({
                
                # Combine all options and create clickable links
                radio_choices <- c("a", "b", "c")
                select_choices <- c("d", "e", "f")
                combinations <- expand.grid(radio_choices, select_choices)
                # Create a tag list with <p><a href=""></a></p>
                do.call(tagList,
                        apply(combinations,1,function(x) {
                            p(tags$a(href = URLencode(
                                paste0(
                                    "/?tab=module2&radiobtn=",
                                    x[["Var1"]],
                                    "&selection=",
                                    x[["Var2"]]
                                )
                            ), paste(x[["Var1"]], x[["Var2"]])))
                        })
                )
            })
        }
    )
}

module2_server <- function() {
    moduleServer(
        "module2",
        function(input, output, session) {
            # Monitors the userData for this module
            # Updates any existing argument that was passed
            observeEvent(session$userData$module2, { 
                params <- session$userData$module2
                if (!is.null(params[["radiobtn"]])) {
                    updateRadioButtons(session,
                                       "radiobtn",
                                       selected = params[["radiobtn"]])
                }
                if (!is.null(params[["selection"]])) {
                    updateSelectInput(session,
                                      "selection",
                                      selected = params[["selection"]])
                }
        })
    })
}

# App server function
server <- function(input, output, session) {
    # Monitors clientData$url_search, redirects user to the specified tab
    # And pass query to session$userData, which will be read in module
    observe({
        query <- parseQueryString(session$clientData$url_search)
        if (!is.null(query[["tab"]])) {
            tab <- query[["tab"]]
            updateNavbarPage(session, inputId = "mainMenu", selected = tab)
            session$userData[[tab]] <- query
        }
    })
    
    module1_server()
    module2_server()
}

# Run the application 
shinyApp(ui = ui, server = server)
