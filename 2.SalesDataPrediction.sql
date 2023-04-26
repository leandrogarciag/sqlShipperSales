/*
Title: Sales Date Prediction
Author: William Leandro Garcia Guerrero
Fecha : 25/04/2023
Descripci�n: 
1.CustomerOrders: Esta es una expresi�n de tabla com�n (CTE) que recupera la informaci�n de los clientes junto con las fechas de sus �rdenes
2.CustomerOrderDifferences: Esta CTE calcula la diferencia en d�as entre cada par de �rdenes consecutivas de un cliente utilizando la funci�n DATEDIFF.
3.CustomerAverageDifferences: Esta CTE calcula el promedio de d�as entre �rdenes para cada cliente. Usa la funci�n AVG para calcular el promedio y agrupa los resultados por ID de cliente y nombre.
4.Consulta principal: La consulta principal utiliza todas las CTE anteriores y une la informaci�n para obtener la fecha de la �ltima orden de cada cliente y calcular la fecha de la pr�xima orden 
predicha sumando el promedio de d�as entre �rdenes a la fecha de la �ltima orden. Agrupa los resultados por nombre de cliente y ID de cliente, y ordena los resultados por nombre de cliente.

Se utiliza CTE para dividir el problema en pasos peque�os y manejables, mostrando el resultado esperado
*/

USE StoreSample;

--1. CustomerOrders:
WITH CustomerOrders AS (
    SELECT
        cust.companyname AS CustomerName,
        cust.custid,
        ord.orderdate,
        ROW_NUMBER() OVER (PARTITION BY cust.custid ORDER BY ord.orderdate) AS OrderSequence,
        LEAD(ord.orderdate) OVER (PARTITION BY cust.custid ORDER BY ord.orderdate) AS NextOrderDate
    FROM
        Sales.Customers cust
        JOIN Sales.Orders ord ON cust.custid = ord.custid
),

--2.CustomerOrderDifferences:
CustomerOrderDifferences AS (
    SELECT
        CustomerName,
        custid,
        orderdate,
        NextOrderDate,
        DATEDIFF(day, orderdate, NextOrderDate) AS DaysBetweenOrders
    FROM
        CustomerOrders
),

--3.CustomerAverageDifferences: 
CustomerAverageDifferences AS (
    SELECT
        CustomerName,
        custid,
        AVG(CAST(DaysBetweenOrders AS FLOAT)) AS AverageDaysBetweenOrders
    FROM
        CustomerOrderDifferences
    WHERE
        DaysBetweenOrders IS NOT NULL
    GROUP BY
        CustomerName,
        custid
)
--4.Consulta principal: 
SELECT
    cad.CustomerName,
    MAX(cod.orderdate) AS LastOrderDate,
    DATEADD(day, CEILING(cad.AverageDaysBetweenOrders), MAX(cod.orderdate)) AS NextPredictedOrder
FROM
    CustomerOrderDifferences cod
    JOIN CustomerAverageDifferences cad ON cod.custid = cad.custid
GROUP BY
    cad.CustomerName,
    cad.custid,
    cad.AverageDaysBetweenOrders
ORDER BY
    cad.CustomerName;
