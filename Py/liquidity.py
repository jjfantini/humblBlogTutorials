# Step 1: Load required libraries
!pip install bidask

from datetime import datetime, timedelta
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from bidask import edge

# Step 2: Collect past 5 years of price data for SNAP and save it to an object named 'snap_df'
from_date = datetime.now() - timedelta(days=5*365)
to_date = datetime.now()
snap_df = pd.DataFrame(tq.get('SNAP', from_date, to_date))

# Step 2.1: Plot and visualize SNAP price
plt.plot(snap_df['date'], snap_df['close'])
plt.xlabel('Date')
plt.ylabel('Price')
plt.title('SNAP Price')
plt.show()

# Step 3: Convert snap_df to xts object - we only want OHLC
snap_xts = pd.DataFrame(snap_df[['open', 'high', 'low', 'close']].values,
                        index=pd.DatetimeIndex(snap_df['date']), columns=['open', 'high', 'low', 'close'])

# Step 4: Estimate bid-ask spread using spread() function -- 1month rolling liquidity calc
# 4.1 Calculate 1m rolling spread estimation
snap_edge = edge(snap_xts)

# 4.2 convert xts to data frame for easy plotting
snap_spread_df = pd.DataFrame({'Date': snap_spread.index, 'spread': snap_spread['EDGE']})

# Step 5: Create a data frame to store both spread calculations

# 5.1 Find different in df length (snap_spread_df is 21 rows shorter due to rolling window)
row_diff = len(snap_df) - len(snap_spread_df)

# 5.2 Create df with both time series you'd like to plot
plot_df = pd.DataFrame({'date': snap_spread_df['Date'], 
                        'price': snap_df['close'][row_diff:], 
                        'spread.edge': snap_spread_df['spread'].values*100,
                        'spread.gmm': snap_spread['GMM'].values*100,
                        'spread.ar': snap_spread['AR'].values*100})

# Step 6: Visualize liquidity and price for SNAP
# 6.1 Create y-axis scaling factor
scaleFactor_edge = plot_df['price'].max() / plot_df['spread.edge'].max()
scaleFactor_gmm = plot_df['price'].max() / plot_df['spread.gmm'].max()
scaleFactor_ar = plot_df['price'].max() / plot_df['spread.ar'].max()

# 6.2 create plot for edge
fig, ax1 = plt.subplots()
ax1.plot(plot_df['date'], plot_df['price'], color='blue', linewidth=1.5)
ax1.set_xlabel('Date')
ax1.set_ylabel('Price', color='blue')
ax1.tick_params(axis='y', labelcolor='blue')
ax2 = ax1.twinx()
ax2.plot(plot_df['date'], plot_df['spread.edge']*scaleFactor_edge, color='red')
ax2.set_ylabel('Spread (%)', color='red')
ax2.tick_params(axis='y', labelcolor='red')
ax2.axhline(y=scaleFactor_edge, color='black', linestyle='dashed', linewidth=1.2, label='1% Spread Max')
ax2.legend(loc='upper right')
plt.title('$SNAP Bid-Ask EDGE Spread Estimation vs Price (1m rolling spread)')
plt.show()

# 6.3 create plot for
