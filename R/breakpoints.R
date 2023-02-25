# Step 1: Install required packages
install.packages("strucchange")

# 1.1 Load the required packages
library(tidyquant)
library(strucchange)

# Step 2: Retrieve the last 5 years of data for AMD
amd <- tq_get("AMD", from = Sys.Date() - years(5), to = Sys.Date())

# 2.1 Extract the adjusted close prices as a time series
amd_ts <- ts(amd$adjusted, frequency = 1)

# Step 3: Perform the breakpoitns test test
bp_test <- breakpoints(amd_ts ~ 1)

# 3.1 Extract the estimated breakpoints
bp <- bp_test$breakpoints


# Step 4:  Calculate means of each breakpoint segment
# 4.1 Calculate the first mean
means <- c(mean(amd_ts[1:bp[1]]))

# 4.2 Calculate the rest of the means between breakpoints
for (i in 1:length(bp)) {
        if (i == length(bp)) {
                means <- c(means, mean(amd_ts[(bp[i] + 1):length(amd_ts)]))
        } else {
                means <- c(means, mean(amd_ts[(bp[i] + 1):bp[i + 1]]))
        }
}



# Step 5: Plot time series with vertical lines at breakpoints and horizontal lines at mean values
# 5.1 Plot the original time series
plot(amd_ts, main = "AMD Adjusted Close Prices", ylab = "AMD Price", yaxt = "n")

# 5.2 Plot the breakpoints
abline(v = bp, col = "blue")

# Plot means between breakpoints
for (i in 1:length(means)) {
        if (i == 1) {
                lines(c(1, bp[i]), c(means[i], means[i]), col = "red", lty = 2)
        } else if (i == length(means)) {
                lines(c(bp[i - 1] + 1, length(amd_ts)), c(means[i], means[i]), col = "red", lty = 2)
        } else {
                lines(c(bp[i - 1] + 1, bp[i]), c(means[i], means[i]), col = "red", lty = 2)
        }
}
# Add gridlines
grid()

## END


##BONUS: to prettify the standard R plot, not ussing ggplot2
#add this code between Step 5.1 + 5.2

legend("topleft", legend = "Breakpoints", col = "blue", lty = 1, bty = "n")
legend("topright", legend = "Segment Means", col = "red", lty = 2, bty = "n")

# Set y-axis intervals in steps of 20
yintervals <- pretty(amd_ts, n = ceiling((max(amd_ts) - min(amd_ts))/20))
axis(2, at = yintervals)
