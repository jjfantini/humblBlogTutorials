# Step 1: Install required packages
!pip install ruptures

# 1.1 Load the required packages
import pandas as pd
import yfinance as yf
import ruptures as rpt
import matplotlib.pyplot as plt

# Step 2: Retrieve the last 5 years of data for AMD
amd = yf.download("AMD", period="5y", interval="1d")
amd = amd[['Adj Close']]
amd_ts = amd.squeeze()

# Step 3: Perform the breakpoints test
algo = rpt.Dynp(model="l2").fit(amd_ts.values)
bp = algo.predict(n_bkps=4)

# 3.1 Get the dates of breakpoints 
bp_rpt = []
for i in bp:
    bp_rpt.append(amd_ts.index[i-1])
bp_rpt = pd.to_datetime(bp_rpt)
bp_rpt

# Step 4: Calculate means of each breakpoint segment
# 4.1 Calculate the first mean
means = [amd_ts[:bp[0]].mean()]

# 4.2 Calculate the rest of the means between breakpoints
for i in range(len(bp)-1):
    means.append(amd_ts[bp[i]+1:bp[i+1]].mean())
means.append(amd_ts[bp[-1]+1:].mean())

# 4.3 Drop NaN values
means = pd.Series(means).dropna().tolist()

# Step 5: Plot the data and breakpoints
plt.plot(amd_ts, label='AMD Price', color = "black")
plt.title('AMD Price')
print_legend = True
for i in bp_rpt:
    if print_legend:
        plt.axvline(i, color='blue',linestyle='solid', label='breaks')
        print_legend = False
    else:
        plt.axvline(i, color='blue',linestyle='solid')
        
# 5.1 Plot means between breakpoints
for i in range(len(means)):
    if i == 0:
        plt.plot([amd_ts.index[0], amd_ts.index[bp[0]]], [means[i], means[i]], color='red', linestyle='dashed', label='means')
    elif i == len(means)-1:
        plt.plot([amd_ts.index[bp[i-1]+1], amd_ts.index[-1]], [means[i], means[i]], color='red', linestyle='dashed')
    else:
        plt.plot([amd_ts.index[bp[i-1]+1], amd_ts.index[bp[i]]], [means[i], means[i]], color='red', linestyle='dashed')

        
plt.grid()
plt.legend()
plt.show()
