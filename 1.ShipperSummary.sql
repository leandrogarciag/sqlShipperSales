/*
Title: SHIPPER SUMMARY
Author: William Leandro Garcia Guerrero
Fecha : 25/04/2023
Descripción: Se crea una tabla temporal que contiene la información de shipperid,orderid, el costo total de la orden sin descuento(OrderCost)
y el número total de products enviados en cada orden (ItemsShipped). Luego se unen las tablas y se agrupan para mostrar la salida esperada

*/
USE StoreSample;

WITH ShipperOrderDetails AS (
    SELECT
        O.shipperid,
        O.orderid,
        SUM(OD.unitprice * OD.qty) AS OrderCost,
        SUM(OD.qty) AS ItemsShipped
    FROM
        Sales.Orders O
        JOIN Sales.OrderDetails OD ON O.orderid = OD.orderid
    GROUP BY
        O.shipperid,
        O.orderid
)
SELECT
    S.companyname AS CompanyName,
    SUM(O.freight) AS TotalFreight,
    SUM(SOD.OrderCost) AS TotalCostShipped,
    SUM(SOD.ItemsShipped) AS TotalItemsShipped
FROM
    Sales.Shippers S
    JOIN Sales.Orders O ON S.shipperid = O.shipperid
    JOIN ShipperOrderDetails SOD ON O.shipperid = SOD.shipperid AND O.orderid = SOD.orderid
GROUP BY
    S.companyname
ORDER BY
    S.companyname;



