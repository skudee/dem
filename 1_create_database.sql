USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'веломагазин')
BEGIN
    CREATE DATABASE веломагазин;
END
GO

USE веломагазин;
GO

-- Категории товаров
CREATE TABLE dbo.Category (
    Id    INT          NOT NULL IDENTITY(1,1),
    Name  NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Category PRIMARY KEY (Id)
);
GO

-- Производители
CREATE TABLE dbo.Producer (
    Id    INT          NOT NULL IDENTITY(1,1),
    Name  NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Producer PRIMARY KEY (Id)
);
GO

-- Поставщики
CREATE TABLE dbo.Provider (
    Id    INT          NOT NULL IDENTITY(1,1),
    Name  NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Provider PRIMARY KEY (Id)
);
GO

-- Единицы измерения
CREATE TABLE dbo.Unit (
    Id    INT         NOT NULL IDENTITY(1,1),
    Name  NVARCHAR(5) NOT NULL,
    CONSTRAINT PK_Unit PRIMARY KEY (Id)
);
GO

-- Роли пользователей
CREATE TABLE dbo.Role (
    Id    INT          NOT NULL IDENTITY(1,1),
    Name  NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Role PRIMARY KEY (Id)
);
GO

-- Статусы заказов
CREATE TABLE dbo.OrderStatus (
    Id    INT          NOT NULL IDENTITY(1,1),
    Name  NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_OrderStatus PRIMARY KEY (Id)
);
GO

-- Пункты выдачи
CREATE TABLE dbo.PickUpPoint (
    Id       INT          NOT NULL IDENTITY(1,1),
    PostCode NVARCHAR(6)  NOT NULL,
    City     NVARCHAR(30) NOT NULL,
    Street   NVARCHAR(30) NOT NULL,
    Building NVARCHAR(6)      NULL,
    CONSTRAINT PK_PickUpPoint PRIMARY KEY (Id)
);
GO

-- Товары
CREATE TABLE dbo.Product (
    Id            INT           NOT NULL IDENTITY(1,1),
    Article       NVARCHAR(10)  NOT NULL,
    Name          NVARCHAR(100) NOT NULL,
    UnitId        INT           NOT NULL,
    Price         MONEY         NOT NULL,
    ProviderId    INT           NOT NULL,
    ProducerId    INT           NOT NULL,
    CategoryId    INT           NOT NULL,
    Discount      DECIMAL(4,2)  NOT NULL DEFAULT 0,
    AmountInStock DECIMAL(6,2)  NOT NULL DEFAULT 0,
    Description   NVARCHAR(MAX)     NULL,
    Photo         NVARCHAR(MAX)     NULL,
    CONSTRAINT PK_Product          PRIMARY KEY (Id),
    CONSTRAINT UQ_Product_Article  UNIQUE (Article),
    CONSTRAINT CK_Product_Price    CHECK (Price > 0),
    CONSTRAINT CK_Product_Discount CHECK (Discount >= 0 AND Discount <= 100),
    CONSTRAINT CK_Product_Amount   CHECK (AmountInStock >= 0),
    CONSTRAINT FK_Product_Unit     FOREIGN KEY (UnitId)     REFERENCES dbo.Unit(Id),
    CONSTRAINT FK_Product_Provider FOREIGN KEY (ProviderId) REFERENCES dbo.Provider(Id),
    CONSTRAINT FK_Product_Producer FOREIGN KEY (ProducerId) REFERENCES dbo.Producer(Id),
    CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryId) REFERENCES dbo.Category(Id)
);
GO

-- Пользователи
CREATE TABLE dbo.[User] (
    Id        INT          NOT NULL IDENTITY(1,1),
    Surname   NVARCHAR(30) NOT NULL,
    Name      NVARCHAR(30) NOT NULL,
    Patronmic NVARCHAR(30)     NULL,
    Login     NVARCHAR(50) NOT NULL,
    Password  NVARCHAR(30) NOT NULL,
    RoleId    INT          NOT NULL,
    CONSTRAINT PK_User       PRIMARY KEY (Id),
    CONSTRAINT UQ_User_Login UNIQUE (Login),
    CONSTRAINT FK_User_Role  FOREIGN KEY (RoleId) REFERENCES dbo.Role(Id)
);
GO

-- Заказы
CREATE TABLE dbo.[Order] (
    Id            INT         NOT NULL IDENTITY(1,1),
    CreationDate  DATE        NOT NULL DEFAULT GETDATE(),
    DeliveryDate  DATE            NULL,
    PickUpPointId INT         NOT NULL,
    UserId        INT         NOT NULL,
    ReceiptCode   NVARCHAR(4)     NULL,
    StatusId      INT         NOT NULL,
    CONSTRAINT PK_Order             PRIMARY KEY (Id),
    CONSTRAINT CK_Order_Dates       CHECK (DeliveryDate IS NULL OR DeliveryDate >= CreationDate),
    CONSTRAINT FK_Order_PickUpPoint FOREIGN KEY (PickUpPointId) REFERENCES dbo.PickUpPoint(Id),
    CONSTRAINT FK_Order_User        FOREIGN KEY (UserId)        REFERENCES dbo.[User](Id),
    CONSTRAINT FK_Order_Status      FOREIGN KEY (StatusId)      REFERENCES dbo.OrderStatus(Id)
);
GO

-- Товары в заказе
CREATE TABLE dbo.ProductInOrder (
    Id        INT NOT NULL IDENTITY(1,1),
    OrderId   INT NOT NULL,
    ProductId INT NOT NULL,
    Amount    INT NOT NULL DEFAULT 1,
    CONSTRAINT PK_ProductInOrder         PRIMARY KEY (Id),
    CONSTRAINT UQ_ProductInOrder         UNIQUE (OrderId, ProductId),
    CONSTRAINT CK_ProductInOrder_Amount  CHECK (Amount > 0),
    CONSTRAINT FK_ProductInOrder_Order   FOREIGN KEY (OrderId)   REFERENCES dbo.[Order](Id),
    CONSTRAINT FK_ProductInOrder_Product FOREIGN KEY (ProductId) REFERENCES dbo.Product(Id)
);
GO

PRINT 'База данных веломагазин успешно создана!';
GO
