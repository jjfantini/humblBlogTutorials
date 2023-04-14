# 1: Set up
install.packages(c("tidyquant", "forecast", "ggplot2"))

# 1.1: Load required libraries
library(tidyquant)
library(forecast)
library(ggplot2)

# 2: Collect past five years of price data for AAPL and save it to an object named 'AAPL_df'
AAPL_df <- tq_get("AAPL", from = Sys.Date() - years(5), to = Sys.Date())

# 2.1: Plot and visualize AAPL price data
AAPL_price <- ggplot(AAPL_df, aes(x = date, y = close)) +
        geom_line(col = "blue", linewidth = 1.1) +
        labs(x = "Date", y = "Price", title = "AAPL Price") +
        theme_minimal()

# 2.2: View the plot
AAPL_price

# 3: Get the adjusted close prices and convert to time series object
AAPL_adj_close <- AAPL_df$adjusted
AAPL_ts <- ts(AAPL_adj_close, frequency = 252)

# 3.1: Perform time series decomposition using an additive model
ts_decomp_add <- decompose(AAPL_ts, type = "additive")

# 3.2: Plot the decomposition components
autoplot(ts_decomp_add) + ggtitle("Additive Model Decomposition")

# 4: Perform time series decomposition using LOESS (STL)
ts_decomp_loess <- stl(AAPL_ts, s.window = "periodic")

# 4.1: Plot the decomposition components
autoplot(ts_decomp_loess) + ggtitle("LOESS Decomposition")

# 5: Create a combined plot for decomposition
combined_plot <- cowplot::plot_grid(
        autoplot(ts_decomp_add) + ggtitle("Additive Model Decomposition"),
        autoplot(ts_decomp_loess) + ggtitle("LOESS Decomposition"),
        ncol = 2
)

# 5.1: Display the combined plot
print(combined_plot)


### SHINY APP: =================================================================================================
# Install Shiny if not already installed
install.packages("shiny")

# Load libraries
library(shiny)
library(tidyquant)
library(ggplot2)

# Define the Shiny UI
ui <- fluidPage(
        titlePanel("AAPL Visualization"),
        sidebarLayout(
                sidebarPanel(
                        selectInput("top_plot", "Select Top Plot:", choices = c("AAPL Price" = "price", "Additive Model Decomposition" = "additive", "LOESS Decomposition" = "loess")),
                        selectInput("bottom_plot", "Select Bottom Plot:", choices = c("Additive Model Decomposition" = "additive", "LOESS Decomposition" = "loess"))
                ),
                mainPanel(
                        plotOutput("top_plot_output"),
                        plotOutput("bottom_plot_output")
                )
        )
)

# Define the Shiny server
server <- function(input, output) {

        AAPL_df <- reactive({
                df <- tq_get("AAPL", from = Sys.Date() - years(5), to = Sys.Date())
                df
        })

        # Extract the time series decomposition components
        ts_decomp_add <- reactive({
                AAPL_adj_close <- AAPL_df()$adjusted
                ts_decomp_add <- decompose(ts(AAPL_adj_close, frequency = 252), type = "additive")
                ts_decomp_add
        })

        ts_decomp_loess <- reactive({
                AAPL_adj_close <- AAPL_df()$adjusted
                ts_decomp_loess <- stl(ts(AAPL_adj_close, frequency = 252), s.window = "periodic")
                ts_decomp_loess
        })

        output$top_plot_output <- renderPlot({})
        output$bottom_plot_output <- renderPlot({})

        observeEvent(input$top_plot, {
                if (input$top_plot == "price") {
                        p <- ggplot(AAPL_df(), aes(x = date, y = close)) +
                                geom_line(col = "blue", linewidth = 1.1) +
                                labs(x = "Date", y = "Price", title = "AAPL Price") +
                                theme_minimal()
                } else if (input$top_plot == "additive") {
                        p <- autoplot(ts_decomp_add()) +
                                ggtitle("Additive Model Decomposition")
                } else {
                        p <- autoplot(ts_decomp_loess()) +
                                ggtitle("LOESS Decomposition")
                }
                output$top_plot_output <- renderPlot({ p })
        })

        observeEvent(input$bottom_plot, {
                if (input$bottom_plot == "additive") {
                        p <- autoplot(ts_decomp_add()) +
                                ggtitle("Additive Model Decomposition")
                } else {
                        p <- autoplot(ts_decomp_loess()) +
                                ggtitle("LOESS Decomposition")
                }
                output$bottom_plot_output <- renderPlot({ p })
        })

}

# Run the Shiny app
shinyApp(ui = ui, server = server)
