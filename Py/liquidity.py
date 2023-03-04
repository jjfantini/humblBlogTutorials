# Step 1: Load required libraries
!pip install bidask

from datetime import datetime, timedelta
import pandas as pd
import numpy as np
import yfinance as yf
import matplotlib.pyplot as plt
from bidask import edge

# Step 2: Collect past 5 years of price data for SNAP and save it to an object named 'snap_df'
snap_df = yf.download('SNAP', start='2016-03-03', end='2023-03-03')

# Step 2.1: Plot and visualize SNAP price
plt.plot(snap_df['Close'])
plt.xlabel('Date')
plt.ylabel('Price')
plt.title('SNAP Price')
plt.show()

# Step 3: Convert snap_df to xts object - we only want OHLC
snap_ohlc = pd.DataFrame(snap_df[['Open', 'High', 'Low', 'Close']].values,
                        index=snap_df.index, columns=['Open', 'High', 'Low', 'Close'])

                        

# Step 4: Estimate bid-ask spread using edge() function -- 1 month rolling liquidity calc
# 4.1 Calculate 1m rolling spread estimation

###############################
def calculate_edge(data):
    """
    Calculates bid-ask spread using edge function on a rolling 21-day window of data.

    Parameters:
        data (pd.DataFrame): OHLC price data.

    Returns:
        pd.Series: Edge values for each row of input data.
    """
    # Create an empty series to hold the edge values
    edge_values = pd.Series(index=data.index, dtype = "float64")

    # Calculate edge function on a rolling 21-day window
    for i in range(21, len(data)):
        window_data = data.iloc[i-21:i]
        edge_values.iloc[i] = edge(window_data['Open'], window_data['High'], window_data['Low'], window_data['Close'])

 # Remove the first 21 rows of edge_values
    edge_values = edge_values[21:]
    
    return edge_values
###############################

snap_spread = calculate_edge(snap_ohlc) * 100

# Step 5: Plot
# Create a figure and axis object
fig, ax1 = plt.subplots()

# Plot snap_df price on primary y-axis
ax1.plot(snap_df.index, snap_df['Close'], color='blue')
ax1.set_xlabel('Date')
ax1.set_ylabel('Price', color='blue')
ax1.tick_params(axis='y', labelcolor='blue')

# Create a secondary y-axis
ax2 = ax1.twinx()

# Plot snap_edge_rolling on secondary y-axis
ax2.plot(snap_spread.index, snap_spread.values, color='red')
ax2.set_ylabel('Spread (%)', color='red')
ax2.tick_params(axis='y', labelcolor='red')
plt.title('$SNAP Bid-Ask EDGE Spread Estimation vs Price (1m rolling spread)')


# Show the plot
plt.show()
