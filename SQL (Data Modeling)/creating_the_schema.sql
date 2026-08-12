USE MarketingAnalytics;
GO

IF OBJECT_ID('dw.FactOrderItem', 'U') IS NOT NULL
    DROP TABLE dw.FactOrderItem;
GO

IF OBJECT_ID('dw.DimCustomer', 'U') IS NOT NULL
    DROP TABLE dw.DimCustomer;
GO

IF OBJECT_ID('dw.DimProduct', 'U') IS NOT NULL
    DROP TABLE dw.DimProduct;
GO

IF OBJECT_ID('dw.DimMarketing', 'U') IS NOT NULL
    DROP TABLE dw.DimMarketing;
GO

IF OBJECT_ID('dw.DimCoupon', 'U') IS NOT NULL
    DROP TABLE dw.DimCoupon;
GO

IF OBJECT_ID('dw.DimShipping', 'U') IS NOT NULL
    DROP TABLE dw.DimShipping;
GO

IF OBJECT_ID('dw.DimDate', 'U') IS NOT NULL
    DROP TABLE dw.DimDate;
GO



CREATE TABLE dw.DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,

    CustomerID VARCHAR(50) NOT NULL,
    CustomerName VARCHAR(200),
    Gender VARCHAR(20),
    Age INT,
    CustomerSegment VARCHAR(30),
    Country VARCHAR(100),
    City VARCHAR(100),
    CustomerLoyaltyScore DECIMAL(10,2),
    TotalOrdersByCustomer INT,
    AccountCreationDate DATE,

    CONSTRAINT UQ_DimCustomer_CustomerID
        UNIQUE (CustomerID)
);
GO



CREATE TABLE dw.DimProduct (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,

    ProductID VARCHAR(50) NOT NULL,
    ProductName VARCHAR(200),
    Category VARCHAR(100),
    SubCategory VARCHAR(100),
    Brand VARCHAR(100),
    ProductRatingAvg DECIMAL(5,2),
    ProductReviewsCount INT,

    CONSTRAINT UQ_DimProduct_ProductID
        UNIQUE (ProductID)
);
GO


CREATE TABLE dw.DimMarketing (
    MarketingKey INT IDENTITY(1,1) PRIMARY KEY,

    CampaignSource VARCHAR(50),
    TrafficSource VARCHAR(50),
    DeviceType VARCHAR(30)
);
GO


CREATE TABLE dw.DimCoupon (
    CouponKey INT IDENTITY(1,1) PRIMARY KEY,

    CouponCode VARCHAR(50) NULL
);
GO


CREATE TABLE dw.DimShipping (
    ShippingKey INT IDENTITY(1,1) PRIMARY KEY,

    ShippingMethod VARCHAR(50),
    ShippingCountry VARCHAR(100),
    WarehouseLocation VARCHAR(100)
);
GO


CREATE TABLE dw.DimDate (
    DateKey INT PRIMARY KEY,

    FullDate DATE NOT NULL,
    Year INT,
    Quarter INT,
    Month INT,
    MonthName VARCHAR(20),
    Day INT,
    DayName VARCHAR(20),
    IsWeekend BIT
);
GO



CREATE TABLE dw.FactOrderItem (
    OrderItemKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    ------------------------------------------------
    -- Degenerate Transaction Identifiers
    ------------------------------------------------
    OrderID VARCHAR(50) NOT NULL,

    ------------------------------------------------
    -- Foreign Keys
    ------------------------------------------------
    CustomerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    MarketingKey INT NOT NULL,
    CouponKey INT NOT NULL,
    ShippingKey INT NOT NULL,
    DateKey INT NOT NULL,

    ------------------------------------------------
    -- Order Information
    ------------------------------------------------
    OrderStatus VARCHAR(30),
    ReturnReason VARCHAR(100),

    ------------------------------------------------
    -- Sales Measures
    ------------------------------------------------
    Quantity INT,
    UnitPriceUSD DECIMAL(18,2),
    DiscountPercent DECIMAL(5,2),
    DiscountAmountUSD DECIMAL(18,2),

    TotalPriceUSD DECIMAL(18,2),
    CostUSD DECIMAL(18,2),
    ProfitUSD DECIMAL(18,2),
    TaxUSD DECIMAL(18,2),

    ------------------------------------------------
    -- Inventory / Shipping Measures
    ------------------------------------------------
    StockQuantity INT,
    ShippingCostUSD DECIMAL(18,2),
    DeliveryDays INT,
    DeliveryStatus VARCHAR(30),

    ------------------------------------------------
    -- Payment
    ------------------------------------------------
    PaymentMethod VARCHAR(50),
    PaymentStatus VARCHAR(30),
    InstallmentPlan VARCHAR(30),

    ------------------------------------------------
    -- Customer Experience
    ------------------------------------------------
    Rating INT,
    ReviewSentiment VARCHAR(30),
    CustomerFeedback VARCHAR(500),

    ------------------------------------------------
    -- Digital Engagement
    ------------------------------------------------
    SessionDurationMinutes DECIMAL(10,2),
    PagesVisited INT,
    AbandonedCartBefore VARCHAR(10),

    ------------------------------------------------
    -- Risk / Business
    ------------------------------------------------
    FraudRiskScore DECIMAL(10,2),
    ProfitMarginPercent DECIMAL(10,2),
    OrderPriority VARCHAR(20),
    SupportTicketCreated VARCHAR(10),

    ------------------------------------------------
    -- Foreign Key Constraints
    ------------------------------------------------
    CONSTRAINT FK_Fact_Customer
        FOREIGN KEY (CustomerKey)
        REFERENCES dw.DimCustomer(CustomerKey),

    CONSTRAINT FK_Fact_Product
        FOREIGN KEY (ProductKey)
        REFERENCES dw.DimProduct(ProductKey),

    CONSTRAINT FK_Fact_Marketing
        FOREIGN KEY (MarketingKey)
        REFERENCES dw.DimMarketing(MarketingKey),

    CONSTRAINT FK_Fact_Coupon
        FOREIGN KEY (CouponKey)
        REFERENCES dw.DimCoupon(CouponKey),

    CONSTRAINT FK_Fact_Shipping
        FOREIGN KEY (ShippingKey)
        REFERENCES dw.DimShipping(ShippingKey),

    CONSTRAINT FK_Fact_Date
        FOREIGN KEY (DateKey)
        REFERENCES dw.DimDate(DateKey)
);
GO


ALTER TABLE dw.FactOrderItem
ADD
    OrderDateTime DATETIME2,
    OrderHour TINYINT;
GO