USE WideWorldImportersDW;
 GO
 --CREATE SCHEMA [Cube];
 GO

CREATE OR ALTER VIEW [Cube].[City] AS
SELECT [City Key] ,[WWI City ID]
,[City] ,[State Province]
,[Country] ,[Continent]
,[Sales Territory],[Region]
,[Subregion],[Location]
,[Latest Recorded Population]
FROM [Dimension].[City]
GO

CREATE OR ALTER VIEW [Cube].[Customer] AS
SELECT [Customer Key] ,[WWI Customer ID]
,[Customer] ,[Bill To Customer]
,[Category] ,[Buying Group]
,[Primary Contact],[Postal Code]
FROM [Dimension].[Customer];
GO

CREATE OR ALTER VIEW [Cube].[Date] AS
SELECT [Date],[Day Number]
,[Day] ,[Month]
,[Short Month] ,[Calendar Month Number]
,[Calendar Month Label] ,[Calendar Year]
,[Calendar Year Label] ,[Fiscal Month Number]
,[Fiscal Month Label] ,[Fiscal Year]
,[Fiscal Year Label] ,[ISO Week Number]
,CASE WHEN GETDATE() = [Date] THEN 1 ELSE 0 END AS [Today]
FROM [Dimension].[Date];
GO

CREATE OR ALTER VIEW [Cube].[Salesperson] AS
SELECT [Employee Key] ,[WWI Employee ID]
,[Employee] ,[Preferred Name]
,SUBSTRING([Employee],CHARINDEX(' ', [Employee])+1, LEN([Employee])) AS [Last
Name]
,SUBSTRING([Employee],1,CHARINDEX(' ', [Employee])) AS [First Name]
,[Valid From] ,[Valid To]
,CASE WHEN [Valid To] > '9999-01-01' THEN 1 ELSE 0 END AS [Current]
,[Lineage Key]
FROM [Dimension].[Employee]
WHERE [Is Salesperson] = 1;
GO

CREATE OR ALTER VIEW [Cube].[Salesperson-Current] AS
SELECT [WWI Employee ID]
,[Employee] ,[Preferred Name]
,SUBSTRING([Employee],CHARINDEX(' ', [Employee])+1, LEN([Employee])) AS [Last
Name]
,SUBSTRING([Employee],1,CHARINDEX(' ', [Employee])) AS [First Name]
FROM [Dimension].[Employee]
WHERE [Is Salesperson] = 1 AND [Valid To] > '9999-01-01';
GO

CREATE OR ALTER VIEW [Cube].[Item] AS
SELECT [Stock Item Key]
,[WWI Stock Item ID] ,[Stock Item]
,[Color] ,[Selling Package]
,[Buying Package] ,[Brand]
,[Size] ,[Lead Time Days]
,[Quantity Per Outer] ,[Is Chiller Stock]
,[Barcode] ,[Tax Rate]
,[Unit Price] ,[Recommended Retail Price]
,[Typical Weight Per Unit] ,[Valid From]
,[Valid To]
,CASE WHEN [Valid To] > '9999-01-01' THEN 1 ELSE 0 END AS [Current]
,[Lineage Key]
FROM [Dimension].[Stock Item];
GO

CREATE OR ALTER VIEW [Cube].[Item-Current] AS
SELECT [WWI Stock Item ID]
,[Stock Item] ,[Color]
,[Selling Package] ,[Buying Package]
,[Brand] ,[Size]
,[Lead Time Days] ,[Quantity Per Outer]
,[Is Chiller Stock] ,[Barcode]
,[Tax Rate] ,[Unit Price]
,[Recommended Retail Price]
,[Typical Weight Per Unit]
FROM [Dimension].[Stock Item]
WHERE [Valid To] > '9999-01-01';
GO

CREATE OR ALTER VIEW [Cube].[Sales] AS
SELECT fs.[Sale Key] ,fs.[City Key]
,dc.[WWI City ID] ,fs.[Customer Key]
,dcu.[WWI Customer ID] ,fs.[Bill To Customer Key]
,dbc.[WWI Customer ID] as [WWI Bill To Customer ID]
,fs.[Stock Item Key] ,dsi.[WWI Stock Item ID]
,fs.[Invoice Date Key] ,fs.[Delivery Date Key]
,fs.[Salesperson Key] ,de.[WWI Employee ID]
,fs.[WWI Invoice ID] ,fs.[Description]
,fs.[Package] ,fs.[Quantity]
,fs.[Unit Price] ,fs.[Tax Rate]
,fs.[Total Excluding Tax] ,fs.[Tax Amount]
,fs.[Profit] ,fs.[Total Including Tax]
,fs.[Total Dry Items] ,fs.[Total Chiller Items]
,1 as [Sales Count] ,fs.[Lineage Key]
FROM [Fact].[Sale] fs
INNER JOIN [Dimension].[City] dc ON dc.[City Key] = fs.[City Key]
INNER JOIN [Dimension].[Customer] dcu ON dcu.[Customer Key] = fs.[Customer Key]
INNER JOIN [Dimension].[Customer] dbc ON dbc.[Customer Key] = fs.[Bill To Customer Key]
INNER JOIN [Dimension].[Stock Item] dsi ON dsi.[Stock Item Key] = fs.[Stock Item Key]
INNER JOIN [Dimension].[Employee] de ON de.[Employee Key] = fs.[Salesperson Key];
GO

CREATE OR ALTER VIEW [Cube].[Invoice] AS
SELECT fs.[WWI Invoice ID] ,fs.[Invoice Date Key]
FROM [Fact].[Sale] fs
GROUP BY fs.[WWI Invoice ID] ,fs.[Invoice Date Key];
GO

CREATE OR ALTER VIEW [Cube].[Invoice Sales] AS
SELECT fs.[WWI Invoice ID] ,fs.[City Key]
,dc.[WWI City ID] ,fs.[Customer Key]
,dcu.[WWI Customer ID] ,fs.[Bill To Customer Key]
,dbc.[WWI Customer ID] AS [WWI Bill To Customer ID]
,fs.[Invoice Date Key] ,fs.[Salesperson Key]
,de.[WWI Employee ID]
,SUM(fs.[Total Excluding Tax]) AS [Invoice Total Excluding Tax]
,SUM(fs.[Tax Amount]) AS [Invoice Tax Amount]
,SUM(fs.[Profit]) AS [Invoice Profit]
,SUM(fs.[Total Including Tax]) AS [Invoice Total Including Tax]
,SUM(fs.[Total Dry Items]) AS [Invoice Total Dry Items]
,SUM(fs.[Total Chiller Items]) AS [Invoice Total Chiller Items]
,1 AS [Invoice Count] ,COUNT([Sale Key]) AS [Sales Count]
FROM [Fact].[Sale] fs
INNER JOIN [Dimension].[City] dc ON dc.[City Key] = fs.[City Key]
INNER JOIN [Dimension].[Customer] dcu ON dcu.[Customer Key] = fs.[Customer Key]
INNER JOIN [Dimension].[Customer] dbc ON dbc.[Customer Key] = fs.[Bill To Customer Key]
INNER JOIN [Dimension].[Employee] de ON de.[Employee Key] = fs.[Salesperson Key]
GROUP BY fs.[WWI Invoice ID] ,fs.[City Key]
,dc.[WWI City ID] ,fs.[Customer Key]
,dcu.[WWI Customer ID] ,fs.[Bill To Customer Key]
,dbc.[WWI Customer ID] ,fs.[Invoice Date Key]
,fs.[Salesperson Key] ,de.[WWI Employee ID];
GO

