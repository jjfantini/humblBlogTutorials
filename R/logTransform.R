# Setup:
install.packages("tidyquant")
install.packages("ggplot2")

# Step 1: Load required libraries ==============================================================================
library(tidyquant)
library(ggplot2)


# Step 2: Collect past 5 years of price data for SNAP and save it to an object named 'AMD_df' ==================
AMD_df <- tq_get("AMD", from = Sys.Date() - years(5), to = Sys.Date())

# Step 2.1: Plot and visualize SNAP price
AMD_price <- ggplot(AMD_df, aes(x = date, y = close)) +
        geom_line(col = "blue", linewidth = 1.1) +
        labs(x = "Date", y = "Price", title = "AMD Price") +
        theme_minimal()

# Step 2.2: View the plot
AMD_price

# BONUS:
# If you want to see and compare a log-transformed AMD_price
# AMD_df$Log_Adjusted <- log(AMD_df$adjusted)
#
# # Create a plot for log-transformed price
# AMD_logPrice <- ggplot(AMD_df, aes(x = date, y = Log_Adjusted)) +
#         geom_line(col = "green", linewidth = 1.1) +
#         labs(x = "Date", y = "Log-Price", title = "AMD Log-Price") +
#         theme_minimal()
# AMD_logPrice

# Step 3: Calculate Returns and Log Returns ====================================================================

# 3.1 Calculate Regular Returns
AMD_df$Returns <- dplyr::lag(AMD_df$adjusted)/AMD_df$adjusted - 1

# 3.2 Calculate Log Returns
AMD_df$Log_Returns <- c(NA, diff(log(AMD_df$adjusted)))


# Step 4: Plot both Log and Regular Returns ====================================================================

# 4.1 Plot Regular Returns
AMD_returns <- ggplot(AMD_df, aes(x = date, y = Returns)) +
        geom_line(col = "black", linewidth = 0.5) +
        labs(x = "Date", y = "Price", title = "AMD Daily Returns") +
        theme_minimal()

# 4.2 Plot Log Returns
AMD_logReturns <- ggplot(AMD_df, aes(x = date, y = Log_Returns)) +
        geom_line(col = "red", linewidth = 0.5) +
        labs(x = "Date", y = "Price", title = "AMD Daily Log Returns") +
        theme_minimal()

# 4.3 Compare === (optional step) ==============================================================================

# We will use cowplot to plot side by side, if you don't have this package, you know the drill
library(cowplot)

combined_plot <- plot_grid(AMD_returns, AMD_logReturns, ncol = 1)

# Display the combined plot
print(combined_plot)

# Plot the price above the returns
# Combine the plots using cowplot with custom height ratios
# BONUS: You can chnage this to AMD_logPrice to compare it to the log price data
combined_plot_price <- plot_grid(AMD_price, AMD_returns, AMD_logReturns, ncol = 1, rel_heights = c(3, 1, 1))

# Display the combined plot
print(combined_plot_price)


### SHINY APP: =================================================================================================
# Install Shiny if not already installed
install.packages("shiny")

# Load libraries
library(shiny)
library(tidyquant)
library(ggplot2)

# Define the Shiny UI
ui <- fluidPage(
        titlePanel("AMD Price and Returns"),
        sidebarLayout(
                sidebarPanel(
                        selectInput("top_plot", "Select Top Plot:", choices = c("AMD Price" = "price", "AMD Log Price" = "logprice")),
                        selectInput("bottom_plot", "Select Bottom Plot:", choices = c("AMD Returns" = "returns", "AMD Log Returns" = "logreturns"))
                ),
                mainPanel(
                        plotOutput("top_plot_output"),
                        plotOutput("bottom_plot_output")
                )
        )
)

# Define the Shiny server
server <- function(input, output) {

        AMD_df <- reactive({
                df <- tq_get("AMD", from = Sys.Date() - years(5), to = Sys.Date())
                df$Log_Adjusted <- log(df$adjusted)
                df$Returns <- dplyr::lag(df$adjusted)/df$adjusted - 1
                df$Log_Returns <- c(NA_real_, diff(log(df$adjusted)))
                df
        })

        output$top_plot_output <- renderPlot({})
        output$bottom_plot_output <- renderPlot({})

        observeEvent(input$top_plot, {
                selected_plot <- if (input$top_plot == "price") {
                        p <- ggplot(AMD_df(), aes(x = date, y = close)) +
                                geom_line(col = "blue", linewidth = 1.1) +
                                labs(x = "Date", y = "Price", title = "AMD Price") +
                                theme_minimal()
                } else {
                        p <- ggplot(AMD_df(), aes(x = date, y = Log_Adjusted)) +
                                geom_line(col = "green", linewidth = 1.1) +
                                labs(x = "Date", y = "Log-Price", title = "AMD Log-Price") +
                                theme_minimal()
                }
                output$top_plot_output <- renderPlot({ selected_plot })
        })

        observeEvent(input$bottom_plot, {
                selected_plot <- if (input$bottom_plot == "returns") {
                        p <- ggplot(AMD_df(), aes(x = date, y = Returns)) +
                                geom_line(col = "black", linewidth = 0.5) +
                                labs(x = "Date", y = "Price", title = "AMD Daily Returns") +
                                theme_minimal()
                } else {
                        p <- ggplot(AMD_df(), aes(x = date, y = Log_Returns)) +
                                geom_line(col = "red", linewidth = 0.5) +
                                labs(x = "Date", y = "Price", title = "AMD Daily Log Returns") +
                                theme_minimal()
                }
                output$bottom_plot_output <- renderPlot({ selected_plot })
        })

}

# Run the Shiny app
shinyApp(ui = ui, server = server)
