/************************************************/
/* Top 10 SAS Functions                         */
/* Efficiency, Readability, and Maintainability */
/* Presented by: Carleigh Jo Crabtree           */
/* Email: CarleighJo.Crabtree@sas.com           */
/************************************************/

/* Replace path with path to data */
libname topten "C:/TopFunctions";

/* Replacing IF-THEN conditional processing */

/* IFC */

data ProfitInvestigation1;
	set topten.superstore;
	keep Profit PosNegProfit;
	if Profit>0 then PosNegProfit="Positive Profit";
	else if Profit<=0 then PosNegProfit="Negative Profit";
	else PosNegProfit="Missing- Investigate";
run;

data ProfitInvestigation2;
	set topten.superstore;
	keep Profit PosNegProfit;
	PosNegProfit=ifc(Profit>0, "Positive Profit", "Negative Profit", "Missing- Investigate");
run;

/* IFN */

data FuturePromo1;
	set topten.superstore;
	keep Ship_Date Order_Date Sales FuturePromo;
	if (Ship_Date-Order_Date)>5 and Sales>500 then FuturePromo=round(Sales*.1);
	else FuturePromo=0;
run;

data FuturePromo2;
	set topten.superstore;
	keep Ship_Date Order_Date Sales FuturePromo;
	FuturePromo=ifn((Ship_Date-Order_Date)>5 and Sales>500, round(Sales*.1), 0);
run;

/* Manipulating, creating, and shifting dates */

/* MONTH, DAY, YEAR, QTR, MDY */

data dates;
	set topten.orders_new;
	keep customer_birthdate CustomerBdayMonth CustomerBdayYear CustomerBdayDate CustomerBdayQtr BdayPromo;
/* 	Have: Customer_Birthdate with number of days since Jan 1, 1960 */
/*  Extracting month, day and year */
	CustomerBdayMonth=month(customer_birthdate);
	CustomerBdayYear=year(customer_birthdate);
	CustomerBdayDate=day(customer_birthdate);
	CustomerBdayQtr=qtr(customer_birthdate);
	
/*  Have: Customer bday month in a column */
/*  Create column with first day of month in their bday month, with current year */
	BdayPromo=mdy(CustomerBdayMonth, 1, year(today()));
		
	format BdayPromo date9.;
run;

/* INTNX, INTCK */

data employees;
	set topten.employee_master;
	keep employee_hire_date Anniversary Celebration;
/* 	Have: Employee hire date */
/*  Find 10 year anniversary */
	Anniversary=intnx('year', Employee_hire_date, 10, 'same');
	
/* 	Celebrate the anniversary in the middle of the month */
	Celebration=intnx('month', Anniversary, 0, 'middle');
	
	format Anniversary Celebration date9.;
run;

data empl;
	keep  Employee_ID Employee_Name Employee_Hire_Date FirstDay WeeksPassedD WeeksPassedC;
	set topten.employee_master;
	/*  Number of months or years customer has been working today */
	if year(employee_hire_date)=2011;
	if month(employee_hire_date)=<11 then FirstDay=mdy(month(employee_hire_date)+1, day(birth_date), year(employee_hire_date));
	else FirstDay=mdy(1, day(birth_date), year(employee_hire_date)+1);
	format FirstDay date9.;
	
/* 	Have: Employee hire date and start date */
/*  How many months passed between the start and hire date? */
	WeeksPassedD=intck('week', employee_hire_date, FirstDay, 'd');
	WeeksPassedC=intck('week', employee_hire_date, FirstDay, 'c');
run;

/* Converting column types */

/* Create data */

data topten.superstore_new;
	set topten.superstore;
	keep  Customer_ID Customer_Name ShipDate OrderDate Order_ID Order_Date Ship_Date;
	OrderDate=put(Order_Date, mmddyy10.);
	ShipDate=put(Ship_Date, mmddyy10.);
run;

/* Have: Character columns with dates */
/* Convert to numeric columns */

data inputFunction;
	set topten.superstore_new;
	drop Order_Date Ship_Date;
	NumOrderDate=input(OrderDate, mmddyy10.);
	NumShipDate=input(ShipDate, mmddyy10.);
	
	*format NumOrderDate NumShipDate date9.;
run;

/* Have: Numeric columns with dates */
/* Create a character column with day of week name */

data putFunction;
	set topten.superstore_new;
	drop OrderDate ShipDate;
	OrderDay=strip(put(Order_Date, downame.));
	ShipDay=strip(put(Ship_Date, downame.));
run;

/* Manipulating character values */

/* FIND, SUBSTR, COMPRESS, SCAN, CAT, TRANWRD */

data topten.charmanipulation;
	set topten.superstore;
	keep product_id  Product_Name Category Sub_Category SubCatCode ProdName ProdName2;
/* 	Extract the product subcategory code from Product_ID */
	SubCatCode=scan(product_id, 2, '-');

/*  Replace & with and- check row 50 */
	ProdName=tranwrd(Product_Name, "&", "and");
	
/* 	Remove single quotes from ProdName- check row 5 and 17 */
	ProdName2=compress(ProdName, "':" );
run;

proc sql;
select distinct catx('-', SubCatCode, Sub_Category) as SubCatsAndCodes
	from charmanipulation;
quit;

data ship;
	set topten.superstore;
	keep ship_mode PosClassBegins LastChar Shipping Shipping2;
	where ship_mode ne "Same Day";
	PosClassBegins=find(ship_mode, 'Class');
	LastChar=PosClassBegins-2;
	Shipping=substr(ship_mode, 1, LastChar);
/*  Extract Frist, Second, or Standard from ship_mode */
	Shipping2=substr(ship_mode, 1, find(ship_mode, 'Class')-2);
run;

/* Eliminating case sensitivity on the WHERE statement */

data caseSensitive;
	set topten.superstore;
	keep Product_Name;
	where Product_Name like '%chair%';
/* 	where upcase(Product_Name) like '%CHAIR%'; */
run;

/* Using patterns to manipulate data */

data prx;
	set topten.employee_master;
	keep Employee_Name FirstLast;
/*  Swap Last, Frist to First Last removing comma */
	FirstLast=prxchange('s/(\w+), (\w+)/$2 $1/', -1, employee_name);
run;

/* Create data */
proc sql outobs=5;
create table topten.nameFix as
select distinct customer_name
	from topten.orders_new;
quit;

data removeTitles;
	set nameFix;
/*  Swap Last, Title. First to First Last removing title and comma */
	ProperName=prxchange('s/(\w+), (?:\w+\.\s)?(\w+)/$2 $1/', -1, customer_name);
/*  Swap Last, Title. First to Title. First Last keeping title and removing comma */
	ProperName2=prxchange('s/(\w+), (\w+\.\s)?(\w+)/$2 $3 $1/', -1, customer_name);
run;
