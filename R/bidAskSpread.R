# Setup:
install.packages("bidask")

# Step 1: Load required libraries
library(tidyquant)
library(bidask)
library(ggplot2)
library(cowplot)

# Step 2: Collect past 5 years of price data for SNAP and save it to an object named 'snap_df'
snap_df <- tq_get("SNAP", from = Sys.Date() - years(5), to = Sys.Date())

# Step 2.1: Plot and visualize SNAP price
snap_plot <- ggplot(snap_df, aes(x = date, y = close)) +
        geom_line(col = "blue", size = 1.1) +
        labs(x = "Date", y = "Price", title = "SNAP Price") +
        theme_minimal()
snap_plot


# Step 3: Convert snap_df to xts object - we only want OHLC
snap_xts <- as.xts(snap_df[,3:6], order.by = snap_df$date)

# Step 4: Estimate bid-ask spread using spread() function -- 1month rolling liquidity calc
# 4.1 Calculate 1m rolling spread estimation
snap_spread <- spread(snap_xts, width = 21,  method = c("EDGE", "GMM", "AR"))

# 4.2 convert xts to data frame for easy plotting
snap_spread_df <- data.frame(Date=index(snap_spread), spread=coredata(snap_spread))

# Step 5: Create a data frame to store both spread calculations

# 5.1 Find different in df length (snap_spread_df is 21 rows shorter due to rolling window)
row_diff <- nrow(snap_df) - nrow(snap_spread_df)

# 5.2 Create df with both tiime series you'd like to plot
plot_df <- data.frame(date   = snap_spread_df$Date,
                      price  = snap_df$close[-c(1:row_diff)],
                      spread.edge = snap_spread_df$spread.EDGE * 100,
                      spread.gmm = snap_spread_df$spread.GMM * 100,
                      spread.ar = snap_spread_df$spread.AR * 100) # multiply spread by 100 to convert to percentage

# Step 6: Visualize liquidity and price for SNAP
# 6.1 Create y-axis scaling factor
scaleFactor.edge <- max(plot_df$price) / max(plot_df$spread.edge)
scaleFactor.gmm <- max(plot_df$price) / max(plot_df$spread.gmm)
scaleFactor.ar <- max(plot_df$price) / max(plot_df$spread.ar)

# 6.2 create plot for edge
snap_plot.edge <- ggplot(plot_df, aes(x=date)) +
        geom_line(aes(y=price), col="blue", size = 1.5) +
        geom_line(aes(y=spread.edge * scaleFactor.edge), col="red") +
        scale_y_continuous(name="price", sec.axis=sec_axis(~./scaleFactor.edge, name="spread (%)")) + # add percentage symbol to secondary axis label
        labs(title = "$SNAP Bid-Ask EDGE Spread Estimation vs Price (1m rolling spread)") +
        geom_hline(aes(yintercept = 1 * scaleFactor.edge, col = "black"), lty = "dashed", size = 1.2,
                   show.legend = TRUE) +
        scale_colour_manual(name = 'Legend',
                            values =c('black'='black'), labels = c('1% Spread Max')) +
        theme(
                axis.title.y.left=element_text(color="blue"),
                axis.text.y.left=element_text(color="blue"),
                axis.title.y.right=element_text(color="red"),
                axis.text.y.right=element_text(color="red")
        )
# 6.3 create plot for GMM
snap_plot.gmm <- ggplot(plot_df, aes(x=date)) +
        geom_line(aes(y=price), col="blue", size = 1.5) +
        geom_line(aes(y=spread.gmm * scaleFactor.gmm), col="red") +
        scale_y_continuous(name="price", sec.axis=sec_axis(~./scaleFactor.gmm, name="spread (%)")) + # add percentage symbol to secondary axis label
        labs(title = "$SNAP Bid-Ask GMM Spread Estimation vs Price (1m rolling spread)") +
        geom_hline(aes(yintercept = 1 * scaleFactor.gmm, col = "black"), lty = "dashed", size = 1.2,
                   show.legend = TRUE) +
        scale_colour_manual(name = 'Legend',
                            values =c('black'='black'), labels = c('1% Spread Max')) +
        theme(
                axis.title.y.left=element_text(color="blue"),
                axis.text.y.left=element_text(color="blue"),
                axis.title.y.right=element_text(color="red"),
                axis.text.y.right=element_text(color="red")
        )

# 6.3 create plot for AR
snap_plot.ar <- ggplot(plot_df, aes(x=date)) +
        geom_line(aes(y=price), col="blue", size = 1.5) +
        geom_line(aes(y=spread.ar * scaleFactor.ar), col="red") +
        scale_y_continuous(name="price", sec.axis=sec_axis(~./scaleFactor.ar, name="spread (%)")) + # add percentage symbol to secondary axis label
        labs(title = "$SNAP Bid-Ask AR Spread Estimation vs Price (1m rolling spread)") +
        geom_hline(aes(yintercept = 1 * scaleFactor.ar, col = "black"), lty = "dashed", size = 1.2,
                   show.legend = TRUE) +
        scale_colour_manual(name = 'Legend',
                            values =c('black'='black'), labels = c('1% Spread Max')) +
        theme(
                axis.title.y.left=element_text(color="blue"),
                axis.text.y.left=element_text(color="blue"),
                axis.title.y.right=element_text(color="red"),
                axis.text.y.right=element_text(color="red")
        )

# Step 7: Combine Plots
combined_plot <- plot_grid(snap_plot.edge, snap_plot.gmm, snap_plot.ar, ncol = 1)
