# Step 1: Install required packages (no need in Python)
!pip install rpy2

# 1.1 Load the required packages
import yfinance as yf
import pandas as pd
import matplotlib.pyplot as plt

# 1.2 Load rpy2 package and set up a connection to an R session:
import rpy2.robjects.packages as rpackages
import rpy2.robjects as robjects

# 1.3 Install strucchange in R
utils = rpackages.importr('utils')
utils.install_packages('strucchange')

# 1.4 Activate strucchange
strucchange = rpackages.importr('strucchange')


# Step 2: Retrieve the last 5 years of data for AMD
amd = yf.download("AMD", start=pd.Timestamp.today() - pd.DateOffset(years=5), end=pd.Timestamp.today())

# 2.1 Extract the adjusted close prices as a time series
amd_ts = amd['Adj Close']

# Step 3: Perform the breakpoint test
bp_test = breakpoints(amd_ts, h=1)

# 3.1 Extract the estimated breakpoints
bp = bp_test.breakpoints

# Step 4: Calculate means of each breakpoint segment
# 4.1 Calculate the first mean
means = [amd_ts[0:bp[0]].mean()]

# 4.2 Calculate the rest of the means between breakpoints
for i in range(len(bp)):
    if i == len(bp)-1:
        means.append(amd_ts[(bp[i]+1):].mean())
    else:
        means.append(amd_ts[(bp[i]+1):bp[i+1]].mean())

# Step 5: Plot time series with vertical lines at breakpoints and horizontal lines at mean values
# 5.1 Plot the original time series
plt.plot(amd_ts.index, amd_ts.values)
plt.title("AMD Adjusted Close Prices")

# 5.2 Plot the breakpoints
for b in bp:
    plt.axvline(x=amd_ts.index[b], color='blue')

# Plot means between breakpoints
for i in range(len(means)):
    if i == 0:
        plt.axhline(y=means[i], xmin=0, xmax=bp[i]/len(amd_ts), color='red', linestyle='--')
    elif i == len(means)-1:
        plt.axhline(y=means[i], xmin=bp[i-1]/len(amd_ts), xmax=1, color='red', linestyle='--')
    else:
        plt.axhline(y=means[i], xmin=bp[i-1]/len(amd_ts), xmax=bp[i]/len(amd_ts), color='red', linestyle='--')

# Show the plot
plt.show()
