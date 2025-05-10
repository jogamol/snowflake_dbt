def model(dbt, session):
    """
    Python model for customer value analysis and segmentation.
    """
    import pandas as pd
    from datetime import datetime, timedelta
    import numpy as np

    # Get the customer orders data using dbt's ref
    customer_orders_df = dbt.ref("int_customer_orders").to_pandas()

    # Print column names to debug
    print("Available columns:")
    for col in customer_orders_df.columns:
        print(f"- {col}")

    # Let's determine which date column to use for recency calculation
    # Check if most_recent_order_date exists
    order_date_column = None
    possible_date_columns = ['most_recent_order_date', 'last_order_date', 'order_date', 'valid_from']

    for col in possible_date_columns:
        if col in customer_orders_df.columns:
            print(f"Using {col} for recency calculation")
            order_date_column = col
            break

    if order_date_column is None:
        print("WARNING: No suitable date column found for recency calculation!")
        # Create a dummy recency column
        customer_orders_df['recency'] = 0
    else:
        # Handle potential NaN values in date fields
        customer_orders_df[order_date_column] = pd.to_datetime(
            customer_orders_df[order_date_column],
            errors='coerce'
        )

        # Create a fixed current date to avoid timezone issues
        current_date = datetime.now().date()

        # Calculate recency (days since last order)
        # Handle None/NaN values for customers with no orders
        customer_orders_df['recency'] = customer_orders_df[order_date_column].apply(
            lambda x: (current_date - x.date()).days if pd.notna(x) else 999
        )

    # Check if total_orders exists, otherwise use a default/dummy value
    if 'total_orders' not in customer_orders_df.columns:
        print("WARNING: 'total_orders' column not found. Using default value 1.")
        customer_orders_df['frequency'] = 1
    else:
        # Fill missing values for frequency
        customer_orders_df['frequency'] = customer_orders_df['total_orders'].fillna(0)

    # Check if lifetime_value exists, otherwise use a default/dummy value
    if 'lifetime_value' not in customer_orders_df.columns:
        print("WARNING: 'lifetime_value' column not found. Using default value 0.")
        customer_orders_df['monetary'] = 0
    else:
        # Calculate monetary value (average order value)
        # Use total_orders if it exists, otherwise use 1 to avoid division by zero
        if 'total_orders' in customer_orders_df.columns:
            customer_orders_df['monetary'] = np.where(
                customer_orders_df['total_orders'] > 0,
                customer_orders_df['lifetime_value'] / customer_orders_df['total_orders'],
                0
            )
        else:
            customer_orders_df['monetary'] = customer_orders_df['lifetime_value']

    # Create customer segment based on RFM
    conditions = [
        (customer_orders_df['recency'] <= 90) &
        (customer_orders_df['frequency'] >= 3) &
        (customer_orders_df['monetary'] >= 1000),

        (customer_orders_df['recency'] <= 180) &
        (customer_orders_df['frequency'] >= 2),

        (customer_orders_df['recency'] <= 365)
    ]
    choices = ['High Value', 'Mid Value', 'Low Value']

    # Apply segmentation logic using numpy select
    customer_orders_df['customer_segment'] = np.select(
        conditions,
        choices,
        default='Inactive'
    )

    # Calculate customer health score with proper null handling
    recency_score = np.minimum(365, customer_orders_df['recency'].fillna(999))
    recency_component = (365 - recency_score) * 0.3

    frequency_component = customer_orders_df['frequency'].fillna(0) * 0.3

    monetary_component = (customer_orders_df['monetary'].fillna(0) / 1000) * 0.4

    customer_orders_df['health_score'] = (
            recency_component +
            frequency_component +
            monetary_component
    ).clip(0, 100)

    # Convert health score to integer for better readability
    customer_orders_df['health_score'] = customer_orders_df['health_score'].round(1)

    # Always add is_current column
    customer_orders_df['is_current'] = True

    # Add required columns if they don't exist
    required_columns = [
        'customer_id', 'customer_name', 'market_segment',
        'nation_name', 'region_name', 'first_order_date',
        'customer_tenure_days', 'total_returns', 'valid_from',
        'valid_to', 'is_current'
    ]

    for col in required_columns:
        if col not in customer_orders_df.columns:
            print(f"WARNING: Required column '{col}' not found. Adding empty column.")
            if col in ['first_order_date', 'valid_from', 'valid_to']:
                customer_orders_df[col] = pd.NaT
            elif col in ['is_current']:
                customer_orders_df[col] = True
            elif col in ['customer_tenure_days', 'total_returns']:
                customer_orders_df[col] = 0
            else:
                customer_orders_df[col] = None

    # Ensure we have a column for total_orders in the final output
    if 'total_orders' not in customer_orders_df.columns:
        customer_orders_df['total_orders'] = customer_orders_df['frequency']

    # Ensure we have a column for lifetime_value in the final output
    if 'lifetime_value' not in customer_orders_df.columns:
        customer_orders_df['lifetime_value'] = customer_orders_df['monetary'] * customer_orders_df['frequency']

    # Add the order date column if it's not already one of our key columns
    if order_date_column is not None and order_date_column not in required_columns and order_date_column != 'most_recent_order_date':
        customer_orders_df['most_recent_order_date'] = customer_orders_df[order_date_column]
    elif 'most_recent_order_date' not in customer_orders_df.columns:
        customer_orders_df['most_recent_order_date'] = pd.NaT

    # Select all needed columns for final output
    result_columns = [
        'customer_id', 'customer_name', 'market_segment',
        'nation_name', 'region_name', 'total_orders',
        'lifetime_value', 'first_order_date', 'most_recent_order_date',
        'customer_tenure_days', 'total_returns', 'recency',
        'frequency', 'monetary', 'customer_segment', 'health_score',
        'valid_from', 'valid_to', 'is_current'
    ]

    # Keep only columns that exist in the dataframe
    available_columns = [col for col in result_columns if col in customer_orders_df.columns]

    result_df = customer_orders_df[available_columns]

    return result_df