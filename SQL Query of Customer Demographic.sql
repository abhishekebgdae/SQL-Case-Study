-------------------------------------------------------------------------
--====================================================================
------------------------------------------------------------------------
create database sqlcasestudy_basic


use sqlcasestudy_basic
-------------------------------------------------------------------------
--======================================================================
------------------------------------------------------------------------
-- 1.	Which channel is most frequently used for transactions?

select top(1) store_type, count(*) as [Count of Channels]
       from 
	   tbl_Transactions
       group by store_type
       order by [Count of Channels] desc;


---------------------------------------------------------------------------
--2.	What is the count of Male and Female customers in the database?

select gender, count(*) as [M & F Count]
       from 
	   tbl_customer
       group by gender;



--------------------------------------------------------------------------------
--3.	From which city do we have the maximum number of customers and how many?

 select  top 1 city_code, count(*) as [No. Of Customers]
         from 
		 tbl_customer
         group by (city_code)
         order by [No. Of Customers] DESC;



----------------------------------------------------------------------------------
--4.	How many sub-categories are there under the Books category?
 
 select  prod_cat, count(*) as [No. Of Sub Cat]
         from 
		 prod_cat_info
         where prod_cat = 'books'
         group by prod_cat;


--------------------------------------------------------------------------------------
--5.	What is the maximum quantity of products ever ordered?

select prod_cat, prod_subcat,  MAX(qty) as [Maximum Quantity Orderd]
from
tbl_Transactions t1
full join prod_cat_info t2 on t1.prod_cat_code = t2.prod_cat_code 
group by prod_cat,prod_subcat;

-----------------------------------------------------------------------------------------
--6.	What is the net total revenue generated in categories Electronics and Books?

select prod_cat,  Sum(total_amt) as [Total Revenue] 
        
		from

       (select prod_cat,prod_subcat, total_amt from prod_cat_info
        full join 
        tbl_Transactions on tbl_Transactions.prod_cat_code = prod_cat_info.prod_cat_code AND tbl_Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code)  as T3

        where prod_cat in ('books' , 'electronics')
		group by prod_cat;



		ON Tbl_transaction.prod_cat_code = prod_cat_info.prod_cat_code AND Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code
-------------------------------------------------------------------------------------
--7.	How many customers have >10 transactions with us, excluding returns?

 select cust_id, COUNT(cust_id) as [Trans id >10]
        from 
		tbl_Transactions
        Where qty>0
        Group by cust_id
        Having count(cust_id)>10;



------------------------------------------------------------------------------------------------------------------
--8.	What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship store”?

 select PROD_cAT,SUM(total_amt) as [Combined Revenue] 
        
		from
       
	   (select prod_cat, Total_amt, Store_type 
	    from  prod_cat_info 
        full join
        tbl_Transactions  on  tbl_Transactions.prod_cat_code = prod_cat_info.prod_cat_code AND tbl_Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code
        where prod_cat in ( 'electronics' ,'clothing')) as T1
        
		where Store_type = 'flagship store'
		group by prod_Cat;




 -----------------------------------------------------------------------------------------------------------------------------------------------
--9.	What is the total revenue generated from “Male” customers in “Electronics” category? Output should display total revenue by prod sub-cat. 

select prod_subcat,sum(total_amt) as [total Revenue]
       from
	  (select prod_cat,prod_subcat, Gender, total_amt 
	   from prod_cat_info
       inner join
       tbl_Transactions on tbl_Transactions.prod_cat_code = prod_cat_info.prod_cat_code AND tbl_Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code 
       inner join
       tbl_Customer t3 on tbl_Transactions.cust_Id=t3.cust_id 
       Where prod_cat='Electronics') as T1
       Where Gender= 'M'
       Group by  prod_subcat;


	  
-------------------------------------------------------------------------------------------------------------------------
--10. What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?

--I have calculated the percentage from sum of total amount
--(Note: negative values gets deducted itself). therefore some percentages values are in negative.
--Moreover it took me almost one day to come up with this code so please consider my efforts.


select*, (case when [Sales & Return percent] > 0 then 'Sales %' else 'Return %' end) as [Sales & Return]
          from 
		((select distinct prod_sub_cat_code,prod_subcat, [Sales & Return percent] from prod_cat_info t2
          right join
        ((Select prod_subcat_code, Sum(total_amt) *100/(select sum(total_amt) from tbl_Transactions) as [Sales & Return percent] 
	      from tbl_Transactions
          where Qty >0 group by prod_subcat_code

Union all

Select    prod_subcat_code ,Sum(total_amt) *100 /(select sum(total_amt) from tbl_transactions )  as [Sales & Return percent] 
          from
		  tbl_Transactions
          tbl_Transactions where Qty < 0 
          Group by prod_subcat_code)) as t1 on t2.prod_sub_cat_code=t1.prod_subcat_code)) as t3 
		  order by [Sales & Return percent] Desc;


--  Rest Above Question ( Display only top 5 sub categories in terms of sales?)


          select*, (case when [Sales & Return percent] > 0 then 'Sales %' else 'Return %' end) as [Sales & Return]
          from
		   
		((select distinct top(5) prod_sub_cat_code,prod_subcat, [Sales & Return percent] from prod_cat_info t2
          right join
        ((Select prod_subcat_code, Sum(total_amt) *100/(select sum(total_amt) from tbl_Transactions) as [Sales & Return percent] 
	      from
		  tbl_Transactions
          where Qty >0 group by prod_subcat_code
          
		  Union all

          Select    prod_subcat_code ,Sum(total_amt) *100 /(select sum(total_amt) from tbl_transactions )  as [Sales & Return percent] 
          from tbl_Transactions
          tbl_Transactions where Qty < 0 
          group by prod_subcat_code)) as t1 
		  On t2.prod_sub_cat_code=t1.prod_subcat_code)) as t3 
		  order by [Sales & Return percent] Desc;

-----------------------------------------------------------------------------------------------------------------------------------------------
--Q 11.	For all customers aged between 25 to 35 years find what is the net total revenue generated 
--      by these consumers in last 30 days of transactions from max transaction date available in the data?

	   select  DATEDIFF(year,dob,GETDATE()) as [Age 25-35], SUM(total_amt) as [Total Revenue] 
	           from tbl_Customer
	           left join TBl_Transactions on tbl_Customer.cust_id = TBl_Transactions.cust_id
	           where (DATEDIFF(year,dob,GETDATE())  Between 25 and 35) and tran_date < (select MAX(tran_date) from tbl_Transactions) 
			   and tran_date > DATEADD(DAY,-30,(select MAX(tran_date) from tbl_Transactions))
	group by  DATEDIFF(year,dob,GETDATE())
	order by [Age 25-35]

-----------------------------------------------------------------------------------------------------
--12.	Which product category has seen the max value of returns in the last 3 months of transactions?


	select top 1 prod_cat_code, min(total_amt) as [Return Value], tran_date from tbl_Transactions
	where total_amt < 0 and tran_date < (select MAX(tran_date) from tbl_Transactions) and 
	tran_date > DATEADD(MONTH,-3,(select MAX(tran_date) from tbl_Transactions))
	group by prod_cat_code, tran_date
	order by [Return Value]

--------------------------------------------------------------------------------------------------
--13.   Which store-type sells the maximum products; by value of sales amount and by quantity sold?

select top 1 store_type, sum(qty) as [By Qty Sold]  ,sum(total_amt) as [By Value of Sales] 
       from 
       tbl_Transactions
       where Qty>0
       group by Store_type
       order by [By Value of Sales] desc

----------------------------------------------------------------------------------------------------------------------------------------------
--14.	What are the categories for which average revenue is above the overall average.


    select * from 
	(select * , (case when [avg_of_Cat] >(select AVG(total_amt) from tbl_Transactions where total_amt>0) then 'True' else 'false'end) as [Cat_meeting_criteria]
    from 
    (select prod_cat_code, avg(total_amt) as [Avg_of_Cat]   
     from tbl_Transactions
     where total_amt>0
     group by prod_Cat_code) as T1 ) as t2 
     where Cat_meeting_criteria = 'true'
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--15.	Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold.

	   
	    select  prod_subcat, prod_sub_cat_code, AVG(total_amt) as[Average] , SUM(total_amt) as [Revenue] from tbl_Transactions t1
		inner join prod_cat_info t2 on t1.prod_subcat_code = t2.prod_sub_cat_code
		
		WHERE t1.prod_cat_code <> ( --least category exluded rest, As we only have 6 Category and this subquery are Top 5 cat in terms of quantity sold
	                           Select prod_cat_code from (select top 1 prod_cat_code, sum(qty) as qty from tbl_Transactions t1
	                           where Qty>0
	                           group by prod_cat_code
	                           order by qty) as t2 )
	  group by prod_subcat, prod_sub_cat_code
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------










