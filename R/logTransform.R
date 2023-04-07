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

# Step 3: Calculate Returns and Log Returns ====================================================================

# 3.1 Convert snap_df to xts object - we only want OHLC
AMD_xts <- as.xts(AMD_df[,3:6], order.by = AMD_df$date)

# 3.2 Calculate Regular Returns
AMD_df$Returns <- dplyr::lag(AMD_df$adjusted)/AMD_df$adjusted - 1

# Calculate Log Returns
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

combined_plot <- plot_grid(AMD_returns, AMD_logReturns, labels = c("Returns", "Log Returns"), ncol = 2)

# Display the combined plot
print(combined_plot)
