# Querying Dates
library(xts)
data(sample_matrix)
sample.xts <- as.xts(sample_matrix)
sample.xts["2007-01"] # January 2007

# Extracting recurring Intraday Intervals ----
sample.xts["T10:00/T15:00"] # Extract all data between 10AM and 3PM

# Alternating Extraction Techniques ----
dates <- as.Date("2007-01-02")
sample.xts[dates] # Subset x using the vector dates

# Update and replace Elements ----
sample.xts["2007-01-02"] <- NA # replace all values in x on dates with NA

# Find the First or Last Period of Time ----
first(sample.xts, "1 week") # First week of the time series

# Matrix Arithmetic ----
sample.xts + sample.xts # Add two xts objects

# Merging and Modifying Time Series ----
merge(sample.xts, sample.xts) # Merge two xts objects

# Fill Missing Values Using Last or Previous Observation ----
na.locf(sample.xts) # Last observation carried forward

# NA Interpolation ----
na.approx(sample.xts) # Interpolate NAs using linear approximation

# Combine a Leading and Lagging Time Series ----
lag(sample.xts, k = -1) # Create a leading object

# Calculate a Difference of a Series with diff ----
diff(sample.xts, lag = 1) # Calculate the first difference of the series

# Apply and Aggregate by Time ----
ep <- endpoints(sample.xts, on = "months")
period.apply(sample.xts, INDEX = ep, FUN = mean) # Apply mean function by month

# Calculate Basic olling Value of Series by Month ----
rollapply(sample.xts, width = 20, FUN = mean) # rolling mean over 20 periods

# Calculate the olling Standard Deviation of a Time Series ----
rollapply(sample.xts, width = 20, FUN = sd) # rolling standard deviation over 20 periods

# Index, Attributes, and Time Zones ----
.index(sample.xts) # Get the index of the xts object

# Time Zones ----
attr(sample.xts, "tzone") <- "America/New_York" # Set the timezone to New York

# Periods, Periodicity, and Timestamps ----
periodicity(sample.xts) # Get the periodicity of the xts object

# Determining Periodicity ----
periodicity(sample.xts) # Get the periodicity of the xts object

# Counting n periods ----
# Calculate the number of months
nmonths(data)

# Calculate the number of quarters
nquarters(data)

# Calculate the number of years
nyears(data)
