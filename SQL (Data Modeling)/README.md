# Phase 2 — Data Modeling

## Objective

After completing the data exploration and cleaning phase, the original flat e-commerce dataset was transformed into a structured analytical data model.

The dataset contains approximately 1 million transaction records and combines customer, product, marketing, shipping, payment, and engagement information in a single table.

To make the data easier to analyze and prepare it for Power BI, a **Star Schema** was implemented using SQL Server.

---

## Modeling Approach

The model consists of:

- One central fact table
- Six dimension tables

```text
                         DimCustomer
                              |
                              |
DimDate -----> FactOrderItem <----- DimProduct
                    |
          +---------+---------+
          |         |         |
    DimMarketing DimCoupon DimShipping
```

The fact table stores transactional data and measurable business metrics, while the dimension tables provide descriptive attributes for analysis and filtering.

---

## Fact Table

### `dw.FactOrderItem`

**Grain:** One row represents one product within one order.

The table contains:

- `OrderItemKey` — Surrogate primary key
- `OrderID` — Original transaction identifier
- Foreign keys to all dimensions
- Sales and financial measures
- Order and return information
- Payment information
- Customer experience metrics
- Digital engagement metrics
- Risk and profitability metrics

### Main Measures

- Quantity
- Unit Price
- Discount Amount
- Total Price
- Cost
- Profit
- Tax
- Shipping Cost
- Delivery Days
- Session Duration
- Pages Visited
- Fraud Risk Score
- Profit Margin

---

## Dimension Tables

### `dw.DimCustomer`

**Grain:** One row per unique customer.

Contains:

- Customer ID and Name
- Gender and Age
- Customer Segment
- Country and City
- Loyalty Score
- Total Orders
- Account Creation Date

Used for customer segmentation, geographic analysis, loyalty analysis, and customer value analysis.

---

### `dw.DimProduct`

**Grain:** One row per unique product.

Contains:

- Product ID and Name
- Category
- Subcategory
- Brand
- Average Product Rating
- Product Reviews Count

Used for product, category, subcategory, and brand performance analysis.

---

### `dw.DimMarketing`

**Grain:** One row per unique combination of:

- Campaign Source
- Traffic Source
- Device Type

Used to analyze marketing channels, campaigns, traffic sources, and device performance.

---

### `dw.DimCoupon`

**Grain:** One row per coupon code.

A `NO_COUPON` member represents transactions where no coupon was used.

Used for coupon usage, discount effectiveness, and coupon profitability analysis.

---

### `dw.DimShipping`

**Grain:** One row per unique shipping configuration.

Contains:

- Shipping Method
- Shipping Country
- Warehouse Location

Used for shipping and fulfillment analysis.

---

### `dw.DimDate`

**Grain:** One row per calendar date.

Contains:

- Full Date
- Year
- Quarter
- Month
- Month Name
- Day
- Day Name
- Weekend Indicator

Used for time-based analysis and reporting.

The transaction timestamp is also retained in the fact table for time-of-day analysis.

---

## Relationships

All dimensions have a **1-to-many relationship** with the fact table.

```text
DimCustomer  ──┐
DimProduct   ──┤
DimMarketing ──┤
DimCoupon    ──┼──> FactOrderItem
DimShipping  ──┤
DimDate      ──┘
```

Surrogate keys are used to connect the dimensions to the fact table, while the original business identifiers such as `CustomerID`, `ProductID`, and `OrderID` are retained where needed.

---

## Why a Star Schema?

The star schema was selected because the dataset is intended for analytical reporting and dashboard development.

It provides:

- Clear separation between descriptive attributes and measures
- Reduced repetition of customer and product information
- Simple relationships for BI tools
- Easier filtering and aggregation
- A scalable structure for future analysis

For example, marketing performance can be analyzed by combining:

```text
DimMarketing + FactOrderItem
```

Customer performance can be analyzed using:

```text
DimCustomer + FactOrderItem
```

Product trends can be analyzed using:

```text
DimProduct + DimDate + FactOrderItem
```

---

## Technology Choice

### SQL Server

Used for:

- Dimensional modeling
- Creating the star schema
- Primary and foreign key relationships
- Loading dimensions and fact data
- Data integrity

### Power BI

The modeled SQL Server database will be used as the data source for the dashboard and reporting layer.

This keeps the responsibilities separated:

```text
SQL Server → Data Modeling & Storage
Power BI   → Visualization & Business Reporting
```

---

## Final Model

| Table | Type | Grain |
|---|---|---|
| `dw.DimCustomer` | Dimension | One row per customer |
| `dw.DimProduct` | Dimension | One row per product |
| `dw.DimMarketing` | Dimension | Campaign / Traffic / Device combination |
| `dw.DimCoupon` | Dimension | One row per coupon |
| `dw.DimShipping` | Dimension | Shipping configuration |
| `dw.DimDate` | Dimension | One row per date |
| `dw.FactOrderItem` | Fact | One row per order-product combination |

---

## Outcome

The original flat dataset has been transformed into a structured **SQL Server Star Schema** that separates customer, product, marketing, coupon, shipping, and date information from transactional measures.

The model is now ready to be connected to **Power BI** for the marketing analytics and dashboard development phase.
