INSERT INTO dw.DimCustomer
(
    CustomerID,
    CustomerName,
    Gender,
    Age,
    CustomerSegment,
    Country,
    City,
    CustomerLoyaltyScore,
    TotalOrdersByCustomer,
    AccountCreationDate
)
SELECT
    customer_id,
    MAX(customer_name),
    MAX(gender),
    MAX(age),
    MAX(customer_segment),
    MAX(country),
    MAX(city),
    MAX(customer_loyalty_score),
    MAX(total_orders_by_customer),
    TRY_CONVERT(DATE, MAX(account_creation_date))
FROM dbo.ecommerce_dataset
GROUP BY customer_id;
GO
select top 10 * from dw.DimCustomer




INSERT INTO dw.DimProduct
(
    ProductID,
    ProductName,
    Category,
    SubCategory,
    Brand,
    ProductRatingAvg,
    ProductReviewsCount
)
SELECT
    product_id,
    MAX(product_name),
    MAX(category),
    MAX(sub_category),
    MAX(brand),
    MAX(product_rating_avg),
    MAX(product_reviews_count)
FROM dbo.ecommerce_dataset
GROUP BY product_id;
GO
select top 10 * from dw.DimProduct


INSERT INTO dw.DimMarketing
(
    CampaignSource,
    TrafficSource,
    DeviceType
)
SELECT DISTINCT
    campaign_source,
    traffic_source,
    device_type
FROM dbo.ecommerce_dataset;
GO
select top 10 * from dw.DimMarketing



INSERT INTO dw.DimCoupon
(
    CouponCode
)
VALUES
('NO_COUPON');
GO

INSERT INTO dw.DimCoupon
(
    CouponCode
)
SELECT DISTINCT
    coupon_code
FROM dbo.ecommerce_dataset
WHERE coupon_code IS NOT NULL;
GO
select top 10 * from dw.DimCoupon


INSERT INTO dw.DimShipping
(
    ShippingMethod,
    ShippingCountry,
    WarehouseLocation
)
SELECT DISTINCT
    shipping_method,
    shipping_country,
    warehouse_location
FROM dbo.ecommerce_dataset;
GO
select top 10 * from dw.DimShipping




DECLARE @MinDate DATE;
DECLARE @MaxDate DATE;

SELECT
    @MinDate = MIN(TRY_CONVERT(DATE, order_date)),
    @MaxDate = MAX(TRY_CONVERT(DATE, order_date))
FROM dbo.ecommerce_dataset;

;WITH DateSeries AS
(
    SELECT @MinDate AS FullDate

    UNION ALL

    SELECT DATEADD(DAY, 1, FullDate)
    FROM DateSeries
    WHERE FullDate < @MaxDate
)
INSERT INTO dw.DimDate
(
    DateKey,
    FullDate,
    Year,
    Quarter,
    Month,
    MonthName,
    Day,
    DayName,
    IsWeekend
)
SELECT
    CONVERT(INT, CONVERT(VARCHAR(8), FullDate, 112)),
    FullDate,
    YEAR(FullDate),
    DATEPART(QUARTER, FullDate),
    MONTH(FullDate),
    DATENAME(MONTH, FullDate),
    DAY(FullDate),
    DATENAME(WEEKDAY, FullDate),
    CASE
        WHEN DATENAME(WEEKDAY, FullDate) IN ('Saturday', 'Sunday')
        THEN 1
        ELSE 0
    END
FROM DateSeries
OPTION (MAXRECURSION 0);
GO
select top 10 * from dw.DimDate














INSERT INTO dw.FactOrderItem
(
    OrderID,

    CustomerKey,
    ProductKey,
    MarketingKey,
    CouponKey,
    ShippingKey,
    DateKey,

    OrderStatus,
    ReturnReason,

    Quantity,
    UnitPriceUSD,
    DiscountPercent,
    DiscountAmountUSD,

    TotalPriceUSD,
    CostUSD,
    ProfitUSD,
    TaxUSD,

    StockQuantity,
    ShippingCostUSD,
    DeliveryDays,
    DeliveryStatus,

    PaymentMethod,
    PaymentStatus,
    InstallmentPlan,

    Rating,
    ReviewSentiment,
    CustomerFeedback,

    SessionDurationMinutes,
    PagesVisited,
    AbandonedCartBefore,

    FraudRiskScore,
    ProfitMarginPercent,
    OrderPriority,
    SupportTicketCreated,

    OrderDateTime,
    OrderHour
)
SELECT
    e.order_id,

    c.CustomerKey,
    p.ProductKey,
    m.MarketingKey,
    cp.CouponKey,
    s.ShippingKey,

    CONVERT(
        INT,
        CONVERT(
            VARCHAR(8),
            TRY_CONVERT(DATE, e.order_date),
            112
        )
    ),

    e.order_status,
    e.return_reason,

    e.quantity,
    e.unit_price_usd,
    e.discount_percent,
    e.discount_amount_usd,

    e.total_price_usd,
    e.cost_usd,
    e.profit_usd,
    e.tax_usd,

    e.stock_quantity,
    e.shipping_cost_usd,
    e.delivery_days,
    e.delivery_status,

    e.payment_method,
    e.payment_status,
    e.installment_plan,

    e.rating,
    e.review_sentiment,
    e.customer_feedback,

    e.session_duration_minutes,
    e.pages_visited,
    e.abandoned_cart_before,

    e.fraud_risk_score,
    e.profit_margin_percent,
    e.order_priority,
    e.support_ticket_created,

    TRY_CONVERT(DATETIME2, e.order_date),
    DATEPART(
        HOUR,
        TRY_CONVERT(DATETIME2, e.order_date)
    )

FROM dbo.ecommerce_dataset e

INNER JOIN dw.DimCustomer c
    ON e.customer_id = c.CustomerID

INNER JOIN dw.DimProduct p
    ON e.product_id = p.ProductID

INNER JOIN dw.DimMarketing m
    ON e.campaign_source = m.CampaignSource
    AND e.traffic_source = m.TrafficSource
    AND e.device_type = m.DeviceType

INNER JOIN dw.DimCoupon cp
    ON COALESCE(e.coupon_code, 'NO_COUPON') = cp.CouponCode

INNER JOIN dw.DimShipping s
    ON e.shipping_method = s.ShippingMethod
    AND e.shipping_country = s.ShippingCountry
    AND e.warehouse_location = s.WarehouseLocation;

GO
select top 10 * from dw.FactOrderItem











