# Broken example of shiny_get_signal with dynamic data
#
# The app below won't behave as you might expect, as shiny_get_signal WILL break
# when you move the slider.
#
# To test, click on the legend to filter, then move slider to filter by mpg
# And try to click on legend again. The legend filter still works, but you can't
# retrieve the clicked value anymore
#
# There might be a workaround using renderUI, but the other app has an elegant
# solution
#
library(shiny)
library(vegawidget)

ui <- fluidPage(
  sliderInput("minimum_mpg",
              "Select minimum mpg",
              min(mtcars$mpg),
              max(mtcars$mpg),min(mtcars$mpg)
  ),
  vegawidgetOutput("scatterplot",width = 200, height = 200),
  textOutput("sel_cyl")
)

server <- function(input, output, session) {
  observe({
    df <- mtcars[mtcars$mpg >= input$minimum_mpg,]
    output$scatterplot <- renderVegawidget({
      list(
        `$schema` = "https://vega.github.io/schema/vega-lite/v5.json",
        params = list(
          list(name = "fill_sel",
               select = list(type = "point",
                             fields = list("cyl"),
                             on = "click",
                             clear = "dblclick",
                             toggle = FALSE),
               bind = "legend"),
          list(name = "chart_title", value = "placeholder title not visible")
        ),
        # Note the use of name = "source"
        data = list(values = df),
        mark = list(
          type = "point",
          filled = TRUE,
          opacity = list("expr" = "fill_sel.cyl == datum.cyl")),
        encoding = list(
          x = list(field = "mpg", type = "quantitative"),
          y = list(field = "wt", type = "quantitative"),
          fill = list(field = "cyl", type = "ordinal")
        )
      ) %>% as_vegaspec()
    })
    
    selected_cyl <- vw_shiny_get_signal("scatterplot","fill_sel","value")
    output$sel_cyl <- renderPrint({ selected_cyl() })  
    
  })
  
  
}

shinyApp(ui, server)