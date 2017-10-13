/*Not Working*/*libname ICHData PCFILES "\\cifs2\homedir$\office\Data file -Gu.xlsx";
/*Not Working*/*proc import out=ICH datafile="\\cifs2\homedir$\office\Data file -Gu.xlsx" DBMS = EXCELCS;
/*Checking total number of sample*/
proc sql;
create table Total as
select COUNT(*) as CNT
from ICH
;
quit;/*Total number of sample is 2131*/

/*Checking missing values*/
proc means data=ICH NMISS N; 
run;/*A couple of variables have missing values*/

/*checking MRN duplication*/
proc sql;
create table MRN_Dup as
select  t1.MRN
       ,count(t1.MRN)
from ICH t1
group by t1.MRN
order by t1.MRN desc
;
quit;/*MRN has no duplicates*/

proc sql;
create table ICH_M as
select  t1.MRN
       ,t1.Age
	   ,case when t1.Sex=1 then 'Female' else 'Male' end as Sex
       ,case when t1.Race=1 then 'White'
	         when t1.Race=2 then 'Black'
			 when t1.Race=3 then 'Asian'
			 when t1.Race=5 then 'Other'
			 when t1.Race=6 then 'Native Hawaiian/Pacific Islander'
			 when t1.Race=7 then 'American Indian/Alaskan Native'
			 when t1.Race=8 then 'More than one race'
			 when t1.Race=9999 then 'Missing' end as Race
	   ,case when t1.Ethnicity=1 then 'HispanicLatino'
	         when t1.Ethnicity=2 then 'Unknown'
			 when t1.Ethnicity=9999 then 'Missing' end as Ethnicity
	   /*,t1.GCS*//*Still not sure how to interpret the value*/
	   ,case when t1.'Ischemic CVA'n=2 then "Yes" 
             when t1.'Ischemic CVA'n=1 then "No"
             when t1.'Ischemic CVA'n=9999 then "Missing" end as IschemicCVA
	   ,case when t1.'Previous Hemorrhage'n=2 then "Yes"
             when t1.'Previous Hemorrhage'n=1 then "No"
             when t1.'Previous Hemorrhage'n=9999 then "Missing" end as PreviousHemorrhage
	   ,case when t1.Warfarin=2 then "Yes"
	         when t1.Warfarin=1 then "No"
			 when t1.Warfarin=9999 then "Missing" end as Warfarin
	   ,case when t1.NOAC=1 then 'None'
	         when t1.NOAC=2 then 'Dabigatran'
			 when t1.NOAC=3 then 'Rivaroxaban'
			 when t1.NOAC=4 then 'Apixaban'
			 when t1.NOAC=6 then 'Other'
			 when t1.NOAC=9999 then 'Missing' end as NOAC 
	   ,case when t1.'ICH Volume'n=9999 then .
             else t1.'ICH Volume'n end as ICHVolume
	   ,case when t1.'IVH Vol'n=9999 then .
             else t1.'IVH Vol'n end as IVHVolume
	   ,case when t1.Intraventricular=2 then "Yes"
	         when t1.Intraventricular=1 then "No"
			 else "Missing" end as Intraventricular
	   ,case when t1.EVD=2 then "Yes"
	         when t1.EVD=1 then "No"
		     else "Missing" end as EVD
	   ,case when t1.'Hematoma Evacuation'n=2 then "Yes"
             when t1.'Hematoma Evacuation'n=1 then "No" 
             else "Missing" end as HematomaEvacuation
       ,t1.'Length of Hospital Stay (Days)'n as LengthOfStay
       ,t1.'30-Day Mortality'n as Mortality30Day
	   ,case when t1.'Transfer?'n=1 then 'No'
	         when t1.'Transfer?'n=2 then 'Yes'
			 when t1.'Transfer?'n=9999 then 'Missing' end as Transfer
	   ,case when t1.'Discharge GOS'n=1 then "1"
			 when t1.'Discharge GOS'n=2 then "2"
			 when t1.'Discharge GOS'n=3 then "3"
			 when t1.'Discharge GOS'n=4 then "4"
			 when t1.'Discharge GOS'n=5 then "5"
             else "Missing" end as DischargeGOS
	   ,case when t1.'Discharge GOS'n in (4 5) then "1"
	         else "0" end as GOS45    
from ICH t1
;
quit;

proc sql;
create table ICH_F as
select  t1.MRN
       ,t1.Age
	   ,t1.Sex
       ,case when t1.Race=9999 then .
	         else t1.Race end as Race
	   ,case when t1.Ethnicity=9999 then .
	         else t1.Ethnicity end as Ethnicity
	   ,case when t1.'Ischemic CVA'n=9999 then .
             else t1.'Ischemic CVA'n end as IschemicCVA
	   ,case when t1.'Previous Hemorrhage'n=9999 then .
             else t1.'Previous Hemorrhage'n end as PreviousHemorrhage
	   ,case when t1.Warfarin=9999 then .
	         else t1.Warfarin end as Warfarin
	   ,case when t1.NOAC=9999 then . 
             else t1.NOAC end as NOAC 
	   ,case when t1.'ICH Volume'n=9999 then .
             else t1.'ICH Volume'n end as ICHVolume
	   ,case when t1.'IVH Vol'n=9999 then .
             else t1.'IVH Vol'n end as IVHVolume
	   ,case when t1.Intraventricular in (8888 9999) then .
	         else t1.Intraventricular end as Intraventricular
	   ,case when t1.EVD in (7777 9999) then .
	         else t1.EVD end as EVD
	   ,case when t1.'Hematoma Evacuation'n=9999 then .
             else t1.'Hematoma Evacuation'n end as HematomaEvacuation
       ,t1.'Length of Hospital Stay (Days)'n as LengthOfStay
       ,case when t1.'30-Day Mortality'n="Yes" then 2
             when t1.'30-Day Mortality'n="No" then 1 end as Mortality30Day
	   ,case when t1.'Transfer?'n=9999 then .
             else t1.'Transfer?'n end as Transfer
	   ,case when t1.'Discharge GOS'n in (7777 9999) then .
             else t1.'Discharge GOS'n end as DischargeGOS
	   ,case when t1.'Discharge GOS'n in (4 5) then 1
	         else 0 end as GOS45    
from ICH t1
;
quit;
 			 
ods select BasicIntervals BasicMeasures;
proc univariate data=ICH_M cibasic;
	var Age ICHVolume IVHVolume LengthOfStay;
run;

proc freq data=ICH_M;
	table Sex Race Ethnicity IschemicCVA 
          PreviousHemorrhage Warfarin NOAC
          Intraventricular EVD HematomaEvacuation
          Mortality30Day Transfer DischargeGOS GOS45;
run;
/*Logistic model*/
proc logistic data=ICH_F;
model GOS45(EVENT='1')=Age ICHVolume IVHVolume LengthOfStay
            Sex Race Ethnicity IschemicCVA 
          	PreviousHemorrhage Warfarin NOAC
          	Intraventricular EVD HematomaEvacuation
          	Mortality30Day Transfer
           ;
output out=pred p=phat lower=lcl upper=ucl predprobs=(individual crossvalidate);
run;

proc logistic data=ICH_F;
model Transfer(EVENT='1')=Age ICHVolume IVHVolume LengthOfStay
            Sex Race Ethnicity IschemicCVA 
          	PreviousHemorrhage Warfarin NOAC
          	Intraventricular EVD HematomaEvacuation
          	Mortality30Day DischargeGOS
           ;
output out=pred p=phat lower=lcl upper=ucl predprobs=(individual crossvalidate);
run;





