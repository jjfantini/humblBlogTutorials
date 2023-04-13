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

# 2.3: View the plot
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
        ncol = 1
)

# 5.1: Display the combined plot
print(combined_plot)
