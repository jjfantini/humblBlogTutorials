# 1: Load Required libraries
pip install yfinance
pip install pandas
pip install numpy
pip install matplotlib

# 1.1 Import Needed Functions
import yfinance as yf
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

# Step 2: Collect past 5 years of price data for AMD and save it to an object named 'AMD_df'
AMD_df = yf.download('AMD', start='2018-03-31', end='2023-03-31')

# Step 2.1: Plot and visualize AMD price
AMD_price = AMD_df[['Adj Close']].plot(figsize=(12, 6), xlabel='Date', ylabel='Price', title='AMD Price')

# View the plot
plt.show()
# 3: Calculate Returns and Log Returns

# 3.1 Calculate Regular Returns
AMD_df['Returns'] = AMD_df['Adj Close'].pct_change()

# 3.2 Calculate Log Returns
AMD_df['Log_Returns'] = np.log(AMD_df['Adj Close']).diff()


# Step 4: Plot both Log and Regular Returns

# 4.1 Setup Plot 

fig = plt.figure(figsize=(12, 12))
gs = gridspec.GridSpec(3, 1, height_ratios=[3, 1, 1], hspace=0.3)

# 4.2 Plot and Compare
ax0 = plt.subplot(gs[0])
ax0.plot(AMD_df.index, AMD_df['Adj Close'], color='blue', linewidth=1.1)
ax0.set_title('AMD Price')
ax0.set_ylabel('Price')

ax1 = plt.subplot(gs[1], sharex=ax0)
ax1.plot(AMD_df.index, AMD_df['Returns'], color='black', linewidth=0.5)
ax1.set_title('AMD Daily Returns')
ax1.set_ylabel('Price')

ax2 = plt.subplot(gs[2], sharex=ax0)
ax2.plot(AMD_df.index, AMD_df['Log_Returns'], color='red', linewidth=0.5)
ax2.set_title('AMD Daily Log Returns')
ax2.set_xlabel('Date')
ax2.set_ylabel('Price')

plt.setp(ax0.get_xticklabels(), visible=False)
plt.setp(ax1.get_xticklabels(), visible=False)
plt.tight_layout()
plt.show()
