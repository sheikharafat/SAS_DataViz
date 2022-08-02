/*
Project Title: Crime Map of San Francisco characterized by Month and Incident Types.
Student Name: Sheikh Yasir Arafat

In this program, i will create different types of map for the san Francisco
crime data set. These maps are characterized by Month and Incident type. I
have read the SFPD Incident Report: 2018 to Present data set which is downloaded
from "https://data.sfgov.org/Public-Safety/
Police-Department-Incident-Reports-Historical-2003/tmnf-yvry".

This data set contains 514199 observations and 34 variables. The most frequent type
incidents are Larceny Theft, Assault, Malicious Mischief and Non-Criminal. 

This program has four phases.

Phase 1: Read the data by Proc Import and clean and prepared the data in a
data step. The final data named as "Police_clean".

Phase 2: Use proc freq to extract information from the cleaned data set and
develop bar charts. I have created a macro named as "%Incident_year_bar ()" 
for creating the bar charts by which we can see the frequency of incidents 
according to year. The examples are given below: 

%Incident_year_bar (Incident_type= 'Larceny Theft') *used for Figure 1;

%Incident_year_bar (Incident_type= 'Malicious Mischief') *used for Figure 2;

%Incident_year_bar (Incident_type= 'Assault')

%Incident_year_bar (Incident_type= 'Non-Criminal')


Phase 3: In this stage, we have created the maps. We have used the SGMAP
to develop maps. There are several ways available for importing map into SGMAP.
We have used three different approach and created three macros for that. The macro
named as "%map_open()" used openstreetmap for importing map, similarly "%map_choro()"
used choromap and "%map_esri()" used esrimap. Each of these macros has two arguments,
month and Incident. The examples of these macros are given below:

%map_open(month=January,Incident=Larceny Theft) *used for Figure 3;
%map_open(month=June,Incident=Assault)

%map_choro(month=January,Incident=Larceny Theft) *used for Figure 4;
%map_choro(month=June,Incident=Assault) *used for Figure 6;
%map_choro(month=December,Incident=Malicious Mischief) *used for Figure 8;

%map_esri(month=November,Incident=Larceny Theft)
%map_esri(month=June,Incident=Assault) *used for Figure 5;
%map_esri(month=December,Incident=Malicious Mischief) *used for Figure 7;

Phase 4: Here, we have developed a single macro that combines all the three
macros in Phase 3 and provide all the three types of maps at the same time.
This macro is named as "%map_san()". Similar to the above macros, this also
has two arguments, month and Incident. The examples of this macros are given below:

%map_san(month=December,Incident=Larceny Theft)
%map_san(month=February,Incident=Assault)  

*/


/* Phase 1*/

/* Here we have read our data set by using proc import and the step cleaned
and prepared the data. Here, we have deleted the missing observations as well.
Keeping only the required variables out of all 34 variables */

/* user should define the location of the data set*/
%let path=M:\STA 502A\Project;

options validvarname=v7; *create valid variable name;

/* proc import is used to read the data*/
	/*used the same data file name as downloaded from the google drive*/
proc import datafile="&path\Police_Department_Incident_Reports__2018_to_Present.csv"
	out=Police /*output dataset name*/
	dbms=csv;
	guessingrows=max; /*consider the all the information without trancation*/
run;

/* data cleaning and processing*/
data Police_clean; 
	set Police; *select the original data;
	month_name=put(Incident_Date,monname.); *create a variable for month;
	if Latitude= '' then delete; *delete missing obs;
	if Longitude= '' then delete; *delete missing obs;
	keep Latitude Longitude Incident_Category month_name Incident_Year;
	/* ask to keep only the selected variables*/
run;


/* Phase 2 */

/* Here we have performed the freuency analysis and create the bar graphs
based on year. For enhancing the flexibility, we have created a macro for
developing bar graphs*/ 

/* using the following proc freq to create the frequency table of incidents*/
title "Frequency table of Different types of Incidents";
proc freq data=Police_clean  order = FREQ noprint;
		/*ask to sort by frequency*/
tables Incident_Category /nocum; /*ask not to provide the cumulative*/
run;


/* using the following proc freq to create the frequency table of months*/
title "Frequency table for the Months of Incidents";
proc freq data=Police_clean  order = FREQ noprint;
		/*ask to sort by frequency*/
tables month_name /nocum; /*ask not to provide the cumulative*/
run;

/* The following macro is used to create bar graphs*/
%macro Incident_year_bar (Incident_type=,);
title "Bar plot of &Incident_type in Different year";
proc sgplot data=Police_clean (where =(Incident_Category = &Incident_type));
	/* select the incident types*/
 vbar Incident_Year; /*ask to create bar plot*/
 xaxis label="Year";
 yaxis label='Frequency of Incident';
run;
%mend Incident_year_bar;


/* Phase 3 */

/* Here, we have created the macros for developing the maps.We have imported
three different types of maps for creating the final maps. Each of the macro 
has two arguments namely month and Incident. By specifying these into the macros,
we can easily create the maps*/  

/* The following is used to create maps*/
/* The following macro used openstreetmap*/
%macro map_open(month=,Incident=); /*select month and incident type*/
data data_out;
	set Police_clean; /* select the data*/
	if (compress(month_name)="&month" and Incident_Category="&Incident") then output;
run;
title "Map of San Francisco in &month for &Incident";
proc sgmap plotdata=data_out; 
	openstreetmap; /*import map*/
    scatter x=Longitude y=Latitude / /*specify the locations*/
	markerattrs=(color=red size=2)
    legendlabel = "&Incident occurred";
run;
quit;
%mend map_open;



/* The following is used to create maps*/
/*Using choromap to create the maps*/
%macro map_choro(month=,Incident=); /*select month and incident type*/
data San_Francisco;
set mapsgfk.uscity (where=(STATECODE="CA" and City="San Francisco"));
	/*import the san Francisco map area border*/
run;
data data_out;
	set Police_clean; /*select the data*/
	if (compress(month_name)="&month" and Incident_Category="&Incident") then output;
run;
title "Map of San Francisco in &month for &Incident";
proc sgmap mapdata=San_Francisco plotdata=data_out;
	choromap / mapid=ID; /*create border*/
    scatter x=Longitude y=Latitude /
	legendlabel = "&Incident occurred"
	markerattrs=(color=red size=2);
run;
quit;
%mend map_choro;


/* The following is used to create maps*/
/*Using ESRI MAPS to create the maps*/

%macro map_esri(month=,Incident=); /*select month and incident type*/
data data_out;
	set Police_clean; /*select the data*/
	if (compress(month_name)="&month" and Incident_Category="&Incident") then output;
run;
title "Map of San Francisco in &month for &Incident";
proc sgmap plotdata=data_out;
	esrimap url='http://services.arcgisonline.com/arcgis/rest/services/USA_Topo_Maps';
		/*import ersi map*/
   scatter x=Longitude y=Latitude /
	legendlabel = "&Incident occurred"
	markerattrs=(color=red size=2);
run;
quit;
%mend map_esri;



/* Phase 4 */

/* Here, we have created a single macro that have used all the three different
imported maps and provide three different maps at a time. This macro also has
two arguments namely month and Incident. By specifying these into the macros,
we can easily create all the three maps at a time*/ 

/* The following is used to create maps*/

%macro map_san(month=,Incident=); /*select month and incident type*/
data data_out;
	set Police_clean; /* select the data*/
	if (compress(month_name)="&month" and Incident_Category="&Incident") then output;
run;
title "Map of San Francisco in &month for &Incident using Openstreetmap";
/* This will provide the map using openstreetmap*/
proc sgmap plotdata=data_out; 
	openstreetmap; /*import map*/
    scatter x=Longitude y=Latitude / /*specify the locations*/
	markerattrs=(color=red size=2)
    legendlabel = "&Incident occurred";
run;
/* The following data step has san Francisco map area border which
will require for the choromap*/
data San_Francisco;
set mapsgfk.uscity (where=(STATECODE="CA" and City="San Francisco"));
	/*import the san Francisco map area border*/
run;
title "Map of San Francisco in &month for &Incident using Choromap";

/* This will provide the map using choromap*/
proc sgmap mapdata=San_Francisco plotdata=data_out;
	choromap / mapid=ID; /*create border*/
    scatter x=Longitude y=Latitude /
	legendlabel = "&Incident occurred"
	markerattrs=(color=red size=2);
run;
title "Map of San Francisco in &month for &Incident using Esrimap";
/* This will provide the map using esrimap*/
proc sgmap plotdata=data_out;
	esrimap url='http://services.arcgisonline.com/arcgis/rest/services/USA_Topo_Maps';
		/*import ersi map*/
   scatter x=Longitude y=Latitude /
	legendlabel = "&Incident occurred"
	markerattrs=(color=red size=2);
run;
quit;
%mend map_san;


/* Discussion: Here, we have developed maps based on the month and incident type.
We have also create the bar graphs for visualizing the changes of crimes with respect
to time. The frequency analysis helped us to find out the most frequent type of
incidents. Finally, the macros enhance the flexibility of developing maps. */
