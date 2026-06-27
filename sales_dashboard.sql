
ALTER TABLE product_sales RENAME COLUMN `Customer Type` TO Customer_Type;

ALTER TABLE product_data RENAME COLUMN `Product ID` TO Product_ID;

ALTER TABLE product_data RENAME COLUMN `Cost Price` TO Cost_Price;

ALTER TABLE product_data RENAME COLUMN `Sale Price` TO Sale_Price;

ALTER TABLE product_sales RENAME COLUMN `Units Sold` TO Units_Sold;

ALTER TABLE product_data RENAME COLUMN `Image URL` TO Image_URL;

ALTER TABLE discount_data RENAME COLUMN `Discount Band` TO Discount_Band;

ALTER TABLE product_sales RENAME COLUMN `Discount Band` TO Discount_Band;

UPDATE product_data
SET Cost_Price = REPLACE(Cost_Price, '$', ''),
    Sale_Price = REPLACE(Sale_Price, '$', '')
WHERE Product_ID IS NOT NULL;
   
ALTER TABLE product_data
MODIFY Cost_Price DECIMAL(10,2),
MODIFY Sale_Price DECIMAL(10,2);

ALTER TABLE product_sales
ADD COLUMN Order_Date DATE;

UPDATE product_sales
SET Order_Date = STR_TO_DATE(`Date`, '%d/%m/%Y');

SELECT `Date`, Order_Date
FROM product_sales
LIMIT 10;

ALTER TABLE product_sales
DROP COLUMN `Date`;

ALTER TABLE product_sales
CHANGE COLUMN Order_Date Date DATE;

select (sale_price * Units_Sold) as revenue from product_data a 
    join product_sales b
    on a.Product_ID = b.Product;
    
UPDATE product_sales
SET Discount_Band = TRIM(Discount_Band);

with Cte1 as
(select
	a.Product,
    a.Category,
    a.brand,
    a.Description,
    a.Cost_Price,
    a.Sale_Price,
    a.Image_url,
    b.date,
    b.customer_type,
    b.Discount_Band,
    b.Units_Sold,
    (sale_price * Units_Sold) as revenue,
    (cost_price * units_sold) as total_cost,
    date_format(date, "%M") as month,
    year(date) as year
    from
		product_data a 
		join product_sales b
		on a.Product_ID = b.Product)
select
	*,
    (1-(Discount*1.0/100))*revenue as discount_revenue
    from cte1 a
	join discount_data b
	on a.month = b.month and a.discount_band = b.discount_band;
