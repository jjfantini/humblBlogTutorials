# Setup:
install.packages("bidask")

# Step 1: Load required libraries
library(tidyquant)
library(bidask)
library(ggplot2)

# Step 2: Collect past 5 years of price data for SNAP and save it to an object named 'snap_df'
snap_df <- tq_get("SNAP", from = Sys.Date() - years(5), to = Sys.Date())

# Step 3: Use 'edge()' function from 'bidask' package to estimate bid-ask spread of 'snap_df'
snap_edge <- snap_df %>%
        edge(high = high, low = low, open = open, close = close)

# View first 10 rows of estimated spread using edge() function
head(snap_edge, n = 10)

# Step 4: Use 'spread()' function from 'bidask' package to estimate bid-ask spread of 'snap_df'

# Convert snap_df to xts object - we only want OHLC
snap_xts <- as.xts(snap_df[,3:6], order.by = snap_df$date)

# Estimate bid-ask spread using spread() function -- 1month rolling liquidity calc
snap_spread <- spread(snap_xts, width = 21,  method = c("EDGE", "GMM", "AR"))

# Step 5: Plot SNAP price
snap_plot <- ggplot(snap_df, aes(x = date, y = close)) +
        geom_line() +
        labs(x = "Date", y = "Price", title = "SNAP Price") +
        theme_minimal()
snap_plot

# Step 6: Visualize bid-ask spread using ggplot2
# convert xts to data frame
snap_spread_df <- data.frame(Date=index(snap_spread), spread=coredata(snap_spread))

# plot EDGE spread over time
spread_plot <- ggplot(snap_spread_df, aes(x=Date, y=spread.EDGE)) +
        geom_line() +
        ggtitle("SNAP Bid-Ask Spread using EDGE Method") +
        ylab("Spread") +
        xlab("Date")
spread_plot

# Step 7: Combine plots
combined_plot <- plot_grid(snap_plot, spread_plot, nrow = 2, align = "v", axis = "lr")

# Display combined plot
combined_plot

#-------
snap_plot <- snap_plot +
        scale_y_continuous(name = "Price", sec.axis = sec_axis(~ . / snap_xts[, "close"][.], name = "Spread")) +
        geom_line(data = snap_spread_df, aes(y = spread.EDGE), color = "red")

# Add secondary y-axis with spread.EDGE
snap_plot <- ggplot(snap_df, aes(x = date, y = close)) +
        geom_line() +
        geom_line(data = snap_spread_df, aes(x = Date, y = spread.EDGE), color = "red") +
        scale_y_continuous(name = "Price", sec.axis = sec_axis(~ . / snap_xts[, "close"][.], name = "Spread")) +
        labs(x = "Date", y = "Price", title = "SNAP Price and Bid-Ask Spread") +
        theme_minimal()

snap_plot
