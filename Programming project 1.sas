FILENAME REFFILE '/home/u63025740/BAN110/Suicide Rate Data.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=Suicide_dataset;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=Suicide_dataset; RUN;

proc print DATA=Suicide_dataset (obs=10); RUN;


*checking missing values; 

proc means data=Suicide_dataset NMISS mean;
run;

proc format;
	value $missfmt ' '='Missing' other='Not Missing';
run;

proc freq data=Suicide_dataset;
	format _CHAR_ $missfmt.;
	tables _CHAR_ / missing missprint nocum nopercent;
run;

*there is no missing values;

*EDA;
*top countries in total number of suicide;
PROC SQL;
  create table total_num_suicide as
  SELECT country, sum(suicides_no) as total_num_suicide
  FROM Suicide_dataset
  group by country;
QUIT;

proc sql;
create table sorted_total_num_suicide as
select country, total_num_suicide from total_num_suicide
  order by total_num_suicide desc;
quit;

data top10_countries ;
set sorted_total_num_suicide  (obs=10);
run;

proc sgplot data=top10_countries;                                                                                                                     
   hbar country / response=total_num_suicide categoryorder=respdesc;                                                                                                              
   yaxis display=(nolabel);                                                                                                                       
   xaxis label='total number of suicide';                                                                                                        
run; 

*mean number of suicides in different years;
proc sql;
create table suicides_no as
select year, mean(suicides_no) as mean from Suicide_dataset
where 1990<year<2016
group by year;
quit;

proc gplot data=suicides_no;
 plot mean*year; symbol i=spline;
run;
quit;



*calculating the correlation between variables;
proc corr data=Suicide_dataset  plots=matrix(histogram) PLOTS(MAXPOINTS=1000000);
run;



*1. Personal objective;
*Is the suicide rate higher for men than for women?;

proc means data=Suicide_dataset sum nonobs;
class sex;
var suicides_no;
run;


proc SGPLOT data = Suicide_dataset;
vbar sex / response=suicides_no;
title 'sum of suicides separated by gender';
run;
quit;

*2. Are suicide rates higher among the elderly than among the young?;

proc means data=Suicide_dataset sum nonobs;
class age;
var suicides_no;
run;


proc SGPLOT data = Suicide_dataset;
vbar age / response=suicides_no categoryorder=respdesc;
title 'sum of suicides separated by age';
run;
quit;

*3. Do suicide rates vary greatly between countries?;

*running  ANOVA test
null hypothesis the mean of suicide in different countries is equal 
alternative hypothesis the mean on suicide in different countries is different;

proc anova data = Suicide_dataset PLOTS;
class country;
model suicides_no = country;
run; 

* since the p-value is less than 0.05 we reject the null hypothesis, 
Thus, the mean on suicide in different countries is different;



*Foreseeable challenges; 

PROC SGPLOT data=suicides_no;
  SCATTER x=year y=mean / markerattrs=(symbol=circlefilled);
  REG x=year y=mean /lineattrs=(color=red thickness=2 pattern=dot);
RUN;











