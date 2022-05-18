--a).Display a list of all property names and their property id’s for Owner Id: 1426. 
USE [Keys]
SELECT [Id], [Name], [Description]
FROM [dbo].[Property]
WHERE [Id] IN (
	SELECT [PropertyId]
	FROM [dbo].[OwnerProperty]
	WHERE [OwnerId]=1426
)

--b).Display the current home value for each property in question a). 
USE [Keys]
SELECT a.[Id], a.[Name], a.[Description], b.[CurrentHomeValue] 
FROM [dbo].[Property] a
LEFT JOIN [dbo].[PropertyFinance] b ON a.[Id]=b.[PropertyId]
WHERE a.[Id] IN (
	SELECT PropertyId
	FROM [dbo].[OwnerProperty]
	WHERE [OwnerId]=1426
)

--c).For each property in question a), return the following:                                                                      
--1).Using rental payment amount, rental payment frequency, tenant start date and tenant end date to write a query that returns the sum of all payments from start date to end date. 
--2).Display the yield.
USE [Keys]
SELECT [TenantId], MAX(ISNULL(c.[FirstName], '') + ' ' + ISNULL(c.[MiddleName], '') + ' ' + ISNULL(c.[LastName], '')) AS TenantName, 
       a.[PropertyId], MAX(b.[Name]) AS [PropertyName], [StartDate], [EndDate], [PaymentFrequencyId], [PaymentAmount], 
	CASE WHEN [PaymentFrequencyId]=1 THEN SUM(DATEDIFF(WEEK, [StartDate], [EndDate])*[PaymentAmount]) 
		 WHEN [PaymentFrequencyId]=2 THEN SUM(DATEDIFF(WEEK, [StartDate], [EndDate])/2*[PaymentAmount])		 
		 WHEN [PaymentFrequencyId]=3 THEN SUM(ROUND(CAST(DATEDIFF(DAY, [StartDate], [EndDate]) AS decimal(5,2))/30, 0)*[PaymentAmount])
	END as [PaymentAmountTotal],
	d.[Yield]
FROM [dbo].[tenantproperty] a
LEFT JOIN [dbo].[property] b ON b.[Id]=a.[PropertyId]
LEFT JOIN [dbo].[Person] c ON c.[Id]=a.[TenantId]
LEFT JOIN [dbo].[PropertyFinance] d ON d.[PropertyId]=a.[PropertyId]
WHERE a.[PropertyId] IN (
	SELECT [PropertyId]
	FROM [dbo].[OwnerProperty]
	WHERE [OwnerId]=1426
)
GROUP BY [TenantId], a.[PropertyId], [StartDate], [EndDate], [PaymentFrequencyId], [PaymentAmount], d.[Yield]
/*
Notes:
According to the DATEDIFF function, there are 12 months from 2017-12-31 to 2018-12-31, but 11 months from 2018-1-1 to 2018-12-31. This is different from real life. 
In this question, I can use DATEDIFF(MONTH, [StartDate], [EndDate])+1 to solve this problem, but it will cause other problems in real projects.
So I set the month to 30 days. If the total number of days in the last month exceeds 15 days, count it as a whole month, otherwise ignore it.
I think it should be setup base on the company's rules.
*/

 
--d).Display all the jobs available
USE [Keys]
SELECT *
FROM [dbo].[Job]
where [JobStatusId]=1
and [OwnerId] IN (
	SELECT [Id]
	FROM [dbo].[Person]
	WHERE [IsActive]=1
)

--e).Display all property names, current tenants first and last names and rental payments per week/ fortnight/month for the properties in question a). 
USE [Keys]
SELECT b.[Name] AS [PropertyName], c.[FirstName], c.[LastName], a.[PaymentAmount], 
	CASE WHEN a.[PaymentFrequencyId]=1 THEN 'Week'
		 WHEN a.[PaymentFrequencyId]=2 THEN 'Fortnight'
		 WHEN a.[PaymentFrequencyId]=3 THEN 'Month'
	END as [PaymentFrequency]
FROM [dbo].[TenantProperty] a 
LEFT JOIN [dbo].[property] b ON b.[Id]=a.[PropertyId]
LEFT JOIN [dbo].[Person] c ON c.[Id]=a.[TenantId]
WHERE [PropertyId] IN (
	SELECT [PropertyId]
	FROM [dbo].[OwnerProperty]
	WHERE [OwnerId]=1426
)
