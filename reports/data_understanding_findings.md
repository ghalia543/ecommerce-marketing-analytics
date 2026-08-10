# Data Understanding Findings

## 1. Dataset Overview

### Dataset purpose

The dataset represents e-commerce transactions and combines information
from several business areas:

-   Orders and transactions
-   Customers and customer segmentation
-   Products and product performance
-   Pricing, discounts, cost, and profitability
-   Payments
-   Shipping and delivery
-   Customer reviews and sentiment
-   Marketing campaigns and acquisition channels
-   Website/session behavior
-   Risk and operational indicators

This makes the dataset suitable for a marketing analytics portfolio
project focused on understanding **customer behavior, acquisition
performance, campaign effectiveness, product performance, and
profitability**.

### Initial dataset size

  Metric                                     Finding
  -------------------------------------- -----------
  Rows                                     1,000,123
  Columns                                         62
  Memory usage                              \~473 MB
  Unique order IDs                           991,930
  Duplicate rows                                   0
  Repeated order IDs                           8,193
  Duplicate order-product combinations             0

The dataset is large enough to demonstrate practical handling of a
high-volume analytical dataset.

------------------------------------------------------------------------

## 2. Initial Structural Findings

The dataset contains **62 columns** with the following broad groups:

  -----------------------------------------------------------------------
  Business Area                       Example Fields
  ----------------------------------- -----------------------------------
  Order                               `order_id`, `order_date`,
                                      `order_status`

  Customer                            `customer_id`, `age`, `gender`,
                                      `customer_segment`

  Geography                           `country`, `city`,
                                      `shipping_country`

  Product                             `product_id`, `product_name`,
                                      `category`, `sub_category`, `brand`

  Pricing & Profitability             `unit_price_usd`,
                                      `discount_percent`,
                                      `total_price_usd`, `cost_usd`,
                                      `profit_usd`

  Payment                             `payment_method`, `payment_status`,
                                      `installment_plan`

  Shipping                            `shipping_method`, `delivery_days`,
                                      `delivery_status`

  Customer Experience                 `rating`, `review_sentiment`,
                                      `customer_feedback`

  Marketing                           `campaign_source`,
                                      `traffic_source`, `coupon_used`,
                                      `coupon_code`

  Digital Behavior                    `device_type`,
                                      `session_duration_minutes`,
                                      `pages_visited`,
                                      `abandoned_cart_before`

  Risk & Operations                   `fraud_risk_score`,
                                      `order_priority`,
                                      `support_ticket_created`
  -----------------------------------------------------------------------

This confirms that the dataset should **not be treated as one flat
analytical table for the final BI model**. A dimensional/star schema
will be considered during the modeling phase.

------------------------------------------------------------------------

# 3. Data Types

Initial data inspection identified:

-   **35 object columns**
-   **15 integer columns**
-   **12 float columns**

### Important type observations

`order_date` and `account_creation_date` are currently stored as
`object` and should be converted to proper datetime types during
cleaning.

Categorical fields such as campaign source, traffic source, customer
segment, payment method, device type, and order status can later be
represented as categorical dimensions in the analytical model.

------------------------------------------------------------------------

# 4. Missing Value Analysis

Three fields contain meaningful missing values:

  --------------------------------------------------------------------------------
  Column                        Missing Rows            Missing % Initial
                                                                  Interpretation
  --------------------- -------------------- -------------------- ----------------
  `return_reason`                    900,244               90.01% Likely not
                                                                  applicable for
                                                                  non-returned
                                                                  orders

  `coupon_code`                      500,083               50.00% Likely not
                                                                  applicable when
                                                                  no coupon was
                                                                  used

  `customer_feedback`                199,617               19.96% May represent
                                                                  orders where no
                                                                  written feedback
                                                                  was submitted
  --------------------------------------------------------------------------------

### Important observation

These missing values should **not automatically be treated as data
errors**.

For example:

-   A non-returned order is expected to have no `return_reason`.
-   An order where `coupon_used = No` is expected to have no
    `coupon_code`.
-   A customer may provide a rating without leaving written feedback.

Therefore, the cleaning phase should distinguish between:

**Missing because the field is not applicable**

and

**Missing because the data is incomplete.**

This distinction is important for business analytics and should be
documented in the data-cleaning rules.

------------------------------------------------------------------------

# 5. Duplicate Analysis

### Exact duplicate rows

No exact duplicate rows were found.

``` text
Duplicate rows: 0
Duplicate percentage: 0.00%
```

### Order ID uniqueness

There are:

-   1,000,123 transaction-level rows
-   991,930 unique order IDs

Therefore, some orders contain multiple rows.

There are **8,193 repeated order IDs**.

### Order-product uniqueness

The combination:

``` text
order_id + product_id
```

has no duplicates.

This suggests that the dataset is likely structured at approximately:

> **Order × Product level**

rather than strictly one row per order.

This is an important finding for future aggregation.

For example, order-level revenue should not simply be summed from a
table after joining additional product-level tables without considering
the grain.

------------------------------------------------------------------------

# 6. Categorical Data Findings

## Order Status

  Status            Rows
  ------------ ---------
  Completed      700,232
  Returned        99,879
  Pending         99,748
  Cancelled       50,163
  Processing      50,101

The dataset contains multiple order lifecycle states, which can support
funnel and operational analysis.

------------------------------------------------------------------------

## Customer Segment

  Segment        Rows
  --------- ---------
  Regular     599,295
  Premium     300,404
  VIP         100,424

Customer segmentation is particularly relevant for retention, revenue
contribution, and campaign targeting analysis.

------------------------------------------------------------------------

## Marketing Campaign Source

  Campaign Source        Rows
  ----------------- ---------
  Organic             167,251
  Facebook            167,023
  Google Ads          166,783
  Instagram           166,524
  Email               166,456
  Affiliate           166,086

The campaign distribution is relatively balanced, which is useful for
comparing channels.

However, campaign performance should not be evaluated using transaction
count alone. Revenue, profit, customer quality, conversion-related
behavior, and repeat purchasing should also be considered.

------------------------------------------------------------------------

## Traffic Source

  Traffic Source        Rows
  ---------------- ---------
  Social             200,316
  Email              200,122
  Referral           199,913
  Search             199,903
  Direct             199,869

This provides a second marketing acquisition dimension that can be
compared with `campaign_source`.

------------------------------------------------------------------------

## Device Type

  Device         Rows
  --------- ---------
  Tablet      334,820
  Desktop     333,056
  Mobile      332,247

Device-level analysis can help identify differences in customer
behavior, order value, and campaign performance.

------------------------------------------------------------------------

# 7. Customer Data Findings

Customer-level attributes include:

-   Age
-   Gender
-   Customer segment
-   Country and city
-   Loyalty score
-   Total historical orders
-   Account creation date

### Observed ranges

  Variable               Min   Max
  -------------------- ----- -----
  Age                     18    75
  Loyalty score            0   100
  Orders by customer       1    50

The dataset contains approximately **991,945 unique customer IDs**,
which is very close to the number of unique orders.

This should be investigated further during data modeling to understand
whether customer attributes are repeated snapshots or whether customers
are mostly associated with a single/few transactions.

------------------------------------------------------------------------

# 8. Product Data Findings

The dataset contains:

-   753,516 unique `product_id` values
-   48 unique product names
-   5 categories
-   22 sub-categories
-   20 brands

This is an important modeling consideration.

The very high number of product IDs compared with the number of product
names suggests that multiple product IDs may exist for the same product
name or that product IDs are generated at a transactional level.

This relationship should be investigated before creating a product
dimension.

### Product-related numeric ranges

  Metric                  Min        Max
  ----------------- --------- ----------
  Unit price          \$10.00   \$500.00
  Quantity                  1          5
  Product rating          3.0        5.0
  Product reviews           0      5,000
  Stock quantity            0      1,000

------------------------------------------------------------------------

# 9. Financial Findings

The main financial fields are:

-   `unit_price_usd`
-   `quantity`
-   `discount_percent`
-   `discount_amount_usd`
-   `total_price_usd`
-   `cost_usd`
-   `profit_usd`
-   `tax_usd`
-   `shipping_cost_usd`
-   `profit_margin_percent`

### Key descriptive statistics

  Metric                Mean     Median       Min          Max
  --------------- ---------- ---------- --------- ------------
  Unit price        \$147.02   \$125.11   \$10.00     \$500.00
  Total price       \$403.24   \$290.19    \$7.53   \$2,499.75
  Cost              \$242.31   \$172.53    \$4.03   \$1,743.70
  Profit            \$160.93   \$108.79    \$0.70   \$1,495.75
  Discount %           8.50%     10.00%        0%          25%
  Profit margin       39.47%     39.90%     6.66%       60.02%

### Distribution observation

Both `total_price_usd` and `profit_usd` are strongly **right-skewed**.

Most orders are concentrated toward lower values, while a smaller number
of orders have substantially higher order values and profits.

This should be considered when:

-   Comparing averages
-   Detecting outliers
-   Segmenting customers
-   Building visualizations
-   Evaluating campaign performance

For business reporting, medians and percentiles may complement averages.

------------------------------------------------------------------------

# 10. Marketing and Customer Behavior Variables

The dataset contains several variables that can support a strong
marketing analysis:

### Acquisition

-   `campaign_source`
-   `traffic_source`

### Digital behavior

-   `device_type`
-   `session_duration_minutes`
-   `pages_visited`
-   `abandoned_cart_before`

### Promotions

-   `coupon_used`
-   `coupon_code`
-   `discount_percent`
-   `discount_amount_usd`

### Customer value

-   `customer_segment`
-   `customer_loyalty_score`
-   `total_orders_by_customer`
-   `total_price_usd`
-   `profit_usd`

### Customer experience

-   `rating`
-   `review_sentiment`
-   `customer_feedback`
-   `support_ticket_created`

These variables create an opportunity to connect **marketing activity →
customer behavior → sales → profitability → customer experience**.

------------------------------------------------------------------------

# 11. Potential Data Quality Checks

The initial exploration did not identify major missingness or
duplication problems beyond the expected conditional fields.

However, the cleaning phase should validate the following business
rules.

## Date consistency

Check:

-   `order_date` against `order_year`
-   `order_date` against `order_month`
-   `order_date` against `order_day`
-   `is_weekend` against the actual weekday
-   `account_creation_date <= order_date`

## Financial consistency

Check relationships such as:

``` text
unit_price × quantity
discount_amount
total_price
cost
profit
profit_margin
```

For example, investigate whether:

``` text
profit_usd ≈ total_price_usd - cost_usd
```

and whether:

``` text
profit_margin_percent ≈ profit_usd / total_price_usd × 100
```

Small differences may be caused by rounding, but large differences
should be investigated.

## Categorical consistency

Validate relationships such as:

``` text
coupon_used = No → coupon_code should be missing
coupon_used = Yes → coupon_code should be populated
```

and:

``` text
order_status = Returned → return_reason should be populated
order_status != Returned → return_reason should generally be missing
```

These are **validation hypotheses**, not assumptions to apply blindly.

## Rating and score ranges

Validate that:

-   `rating` is between 1 and 5
-   `product_rating_avg` is between 1 and 5
-   `customer_loyalty_score` is between 0 and 100
-   `fraud_risk_score` is between 0 and 100
-   `profit_margin_percent` is within a reasonable business range

------------------------------------------------------------------------

# 12. Important Modeling Observation

The dataset currently mixes multiple business entities in one table.

The following entities can be identified:

``` text
Customers
Products
Orders
Order Items
Marketing / Acquisition
Payments
Shipping
Customer Feedback
```

Therefore, the next phase should investigate a **dimensional/star
schema** rather than using the raw table directly as the final Power BI
model.

A possible conceptual model is:

``` text
                    DimCustomer
                         |
                         |
DimMarketing ---- FactOrderItem ---- DimProduct
                         |
                         |
                    DimDate
                         |
                    DimShipping
```

The exact model should be determined after confirming the grain and
relationships.

------------------------------------------------------------------------

# 13. Key Findings Summary

### Dataset quality

-   Dataset contains over **1 million rows** and 62 columns.
-   No exact duplicate rows were found.
-   8,193 order IDs are repeated.
-   No duplicate `order_id + product_id` combinations were found.
-   Missing values appear to be largely conditional/business-related
    rather than universally random.

### Marketing relevance

The dataset provides strong coverage for:

-   Campaign performance
-   Traffic-source analysis
-   Customer segmentation
-   Customer value analysis
-   Coupon and discount effectiveness
-   Device behavior
-   Abandoned-cart behavior
-   Product performance
-   Profitability analysis
-   Customer sentiment

### Analytical risks

The main risks to address before dashboard development are:

1.  Confirming the dataset grain.
2.  Validating repeated order IDs.
3.  Converting date fields to proper datetime types.
4.  Validating financial calculation consistency.
5.  Validating conditional missing values.
6.  Investigating the unusually high number of product IDs relative to
    product names.
7.  Avoiding double counting when aggregating order-level KPIs.
8.  Considering skewness in revenue and profit distributions.

------------------------------------------------------------------------

# 14. Recommended Next Phase

The next phase should be **Data Cleaning & Validation**.

Recommended sequence:

1.  Convert date columns to datetime.
2.  Validate date-derived fields.
3.  Standardize categorical text values.
4.  Validate conditional missing values.
5.  Validate financial formulas.
6.  Check numeric ranges and impossible values.
7.  Investigate repeated `order_id` records.
8.  Investigate `product_id` relationships.
9.  Identify the final analytical grain.
10. Create a cleaned analytical dataset.
11. Document all transformations in `data_cleaning_log.md`.

After cleaning, proceed to **data modeling**, followed by EDA and Power
BI dashboard development.
