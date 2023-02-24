#Install required packages
install.packages("strucchange")

# Load the required packages
library(tidyquant)
library(strucchange)

# Retrieve the last 5 years of data for AMD
amd <- tq_get("AMD", from = Sys.Date() - years(5), to = Sys.Date())

# Extract the adjusted close prices as a time series
amd_ts <- ts(amd$adjusted, frequency = 1)

# Perform the test
bp_test <- breakpoints(amd_ts ~ 1)

# Extract the estimated breakpoints
bp <- bp_test$breakpoints

# Calculate mean values between breakpoints
means <- c()
for (i in 1:(length(bp)-1)){
        start <- bp[i] + 1
        end <- bp[i+1]
        means[i] <- mean(amd_ts[start:end])
}

#calculate last mean until end of time series
means[length(bp)] <- mean(amd_ts[(bp[length(bp)]+1):length(amd_ts)])

# Plot time series with vertical lines at breakpoints and horizontal lines at mean values
plot(amd_ts, main = "AMD Adjusted Close Prices", xaxt = "n")

abline(v = bp, col = "blue")

for (i in 1:length(bp)){
        if (i == 1){
                lines(x = seq(1, bp[i]), y = rep(means[i], bp[i]), col = "red", lty = 2, xlim = c(1, bp[i]))
        } else if (i != length(bp)) {
                lines(x = seq(bp[i], bp[i+1]-1), y = rep(means[i], bp[i+1]-bp[i]), col = "red", lty = 2, xlim = c(bp[i], bp[i+1]))
        } else {
                lines(x = seq(bp[i], length(amd_ts)), y = rep(means[i], length(amd_ts)-bp[i]+1), col = "red", lty = 2, xlim = c(bp[i], length(amd_ts)))
        }
}

for (i in 1:length(bp)){
        if (i != length(bp)) {
                lines(x = seq(bp[i], bp[i+1]-1), y = rep(means[i], bp[i+1]-bp[i]), col = "red", lty = 2, xlim = c(bp[i], bp[i+1]))
        } else {
                lines(x = seq(bp[i], length(amd_ts)), y = rep(means[i], length(amd_ts)-bp[i]+1), col = "red", lty = 2, xlim = c(bp[i], length(amd_ts)))
        }
}
