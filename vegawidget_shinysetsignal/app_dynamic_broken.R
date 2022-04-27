# Broken example of reactive data + set_signal
#
# Please see other files to understand the solution.
# This app does not work as intended, as the connection between the chart and
# the set_signal is lost when the widget is rendered again
#
library(shiny)
library(vegawidget)

ui <- fluidPage(
  sliderInput("minimum_mpg",
              "Select minimum mpg",
              min(mtcars$mpg),
              max(mtcars$mpg),min(mtcars$mpg)
  ),
  vegawidgetOutput("scatterplot",width = 200, height = 200)
)

server <- function(input, output, session) {
  
  output$scatterplot <- renderVegawidget({
    list(
      `$schema` = "https://vega.github.io/schema/vega-lite/v5.json",
      params = list(
        list(name = "chart_title", value = "placeholder title not visible")
      ),
      data = list(values = mtcars[mtcars$mpg >= input$minimum_mpg,]),
      # We will try to set the title dynamically
      title = list(text = list(expr = "chart_title")),
      mark = list(type = "point"),
      encoding = list(
        x = list(field = "mpg", type = "quantitative"),
        y = list(field = "wt", type = "quantitative")
      )
    ) %>% as_vegaspec()
  })
  
  # This block is bound to input$minimum_mpg
  new_title <- reactive({
    df <- mtcars[mtcars$mpg >= input$minimum_mpg,]
    selected_pct <- nrow(df())/nrow(mtcars)*100
    paste0("Viewing ",selected_pct,"% of rows")
  })
  # Update title
  vegawidget::vw_shiny_set_signal("scatterplot", "chart_title", new_title)  
  
}

shinyApp(ui, server)