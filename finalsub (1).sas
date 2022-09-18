libname practice "/home/u61015226/Azana/Assignment2";
ods noproctitle;
options validvarname=v7;

ods pdf file="/home/u61015226/Export/metkey.pdf" startpage=never style=analysis;
proc import datafile='/home/u61015226/Azana/Assignment2/keywords.csv'
	dbms=csv
	out=practice.keywords
	replace;
run;

proc import datafile='/home/u61015226/Azana/Assignment2/metadata.csv'
	dbms=csv
	out=practice.metadata
	replace;
	guessingrows= 300;
run;

proc sort data=practice.keywords
	out= keywords;
	by id;
run;

proc sort data=practice.metadata
	out= metadata;
	by id;	
run;

data metkey;
	merge keywords metadata;
	by id;
run;
data metkey;
	set metkey;
	where revenue>0
	and popularity > 0 and budget >0;
	label 
		vote_average= "Average review scores"
		revenue ="Revenue"
		popularity="Popularity"
		release_date="Release Date"
		budget = "Budget"
		genres="Genres"
		year_range="Year";	
	format revenue DOLLAR15. budget DOLLAR10.;
	year= year(release_date);
	where release_date is not missing;	
run;

title "Average review scores";
footnote "Average review scores for movies";
proc means data= metkey maxdec=2 nonobs mean;
	var vote_average;
run;

data metyear;
	set metkey;
	length year_range $10;
	label year_range="Year";
	if year >= 1800 and year < 1900 then year_range="1800s";
	else if year>=1900 and year <2000 then year_range="1900s";
	else  year_range="2000s";
	where vote_average> 0;
run;

ods graphics / reset width=6.4in height=4.8in imagemap;
proc sgplot data=WORK.METYEAR;
	title height=14pt "Average review scores of movies over a period of time";
	footnote2 justify=left height=12pt "1800-2020";
	vbar year_range / response=vote_average stat=mean;
	yaxis grid;
run;
ods graphics / reset;
title;
footnote2;


ods pdf startpage=now;
data popgen;
	set metyear;
	label
		genres="Genres";
	format popularity 7.2;
	where popularity>0 and genres is not missing;
	keep popularity genres;
run;

proc sort data= popgen
	out= popgen_sorted;
	by descending popularity;
run;


title "Top 10 Popular Genres";
footnote;	
proc print data= popgen_sorted(obs=10) label;
run;

ods pdf startpage=now;
data popgen2;	
	set metyear;
	keep genres popularity year_range;
run;


proc sort data=popgen2
	out=popgen2_sort;
	by descending popularity;
run;

%let year=1800s;
title "Popular genres in the year &year";
footnote "Year 1800";
proc print data=popgen2_sort(obs=5) noobs label;
	where year_range = "&year" ;
	var genres popularity;
	format popularity 7.2;
run;
ods pdf startpage=now;

title "Popular genre in the year 1900s";
footnote "Year 1900";
proc print data=popgen2_sort(obs=5) noobs label;
	where year_range="1900s";
	var genres popularity;
		format popularity 7.2;
run;
ods pdf startpage=now;
title "Popular genre in the year 2000s";
footnote "Year 2000";
proc print data=popgen2_sort(obs=5) noobs label;
	where year_range= "2000s";
	var genres popularity;
		format popularity 7.2;
run;

ods pdf startpage=now;
title "Relation between production budget and popularity";
footnote "Production budget and Populariy ";
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=WORK.METKEY;
	reg x=budget y=popularity / nomarkers;
	scatter x=budget y=popularity /;
	xaxis min=10000 grid;
	yaxis max=400 grid;
run;

ods graphics / reset;
ods pdf startpage=now;
data poplang;
	set metkey;
	where spoken_languages is not missing and 
		production_companies is not missing;
	keep popularity spoken_languages production_companies;
	
run;

proc sort data= poplang(obs=10)
	out=poplang_sort;
	where popularity > 100;
	by descending popularity;
	label 	
		spoken_languages="Spoken Languages"
		production_companies="Production Companies"
		popularity="Popularity";
run;

title "Production houses and the most used languages for successful movies";
footnote "Order in descending popularity";
proc freq data= poplang_sort order=freq;
	tables production_companies * spoken_languages/ nofreq nocol norow nocum;
run;

data key_rev;
	set metkey;
	keep keywords revenue;
	where keywords is not missing and revenue>0;
run;

proc sort data=key_rev
	out=key_rev_sort;
	by descending revenue;
run;
ods pdf startpage=now;
title"Top 10 keywords that make the most revenue";
footnote "Top 10";
proc print data=key_rev_sort(obs=10) label;
run;
	
data rev;
	set metkey;
	where zombie =1 or ghost=1;
	keep zombie revenue ghost;
run;
ods pdf startpage=now;
title "Ghost movies make more money than zombie movies";
footnote"Average revenue is the mean";
proc means data = rev maxdec=2 nonobs mean;
	where revenue > 0;
	var revenue;
	class ghost zombie;
	ways  2;
run;
ods pdf startpage=now;

data toy_story;
	set metkey;
	label vote_count = "Ratings"
		tite = "Movie Name";
	where title contains 'Toy Story';
	keep title year vote_count;

run;

title "There has been a decline in the ratings of Toy Story sequels";
footnote "Toy Story sequels over the years";
ods graphics / reset width=6.4in height=4.8in imagemap;
proc sgplot data=WORK.TOY_STORY;
	vbar title / response=vote_count;
	yaxis grid;
run;
ods graphics / reset;

ods pdf startpage=now;
data vote;
	set metkey;
	keep vote_count keywords title;
	label vote_count="Vote count"
		keywords="Keywords"
		title= "Title";
 
run;

proc sort data=vote
	out=vote_sort;
	by descending vote_count;
run;

title "Top 5 movies which contain the keyword death";
footnote;
proc print data=vote_sort(obs=5) label;
	where keywords contains 'death';
	var title vote_count;
run;
ods pdf startpage=now;
title "Top 5 movies which contain the keyword doctor";
footnote;
proc print data=vote_sort(obs=5) label;
	var title vote_count;
	where keywords contains 'doctor'; 
run;
ods pdf startpage=now;
data film_cntry;
	set metkey;
	where film_noir=1 and production_countries is not missing;
	keep film_noir production_countries;
	label production_countries="Country of Production";
run;

title "Film noir movies are usually prouced in USA";
footnote "Production Countries form most to least";
proc freq data= film_cntry order=freq;
	tables production_countries/ nopercent nofreq nocum plots=freqplot;
run;
ods pdf startpage=now;
data prod_count;
	set metkey;
	keep production_countries;
	where production_countries is not missing;
	label production_countries="Country of Production";
run;


title"Production countries for all movies";
footnote "In percentage";
proc template;
	define statgraph SASStudio.Pie;
		begingraph;
		entrytitle "Country where films are produced the most" / textattrs=(size=14);
		layout region;
		piechart category=production_countries / stat=pct;
		endlayout;
		endgraph;
	end;
run;

ods graphics / reset width=6.4in height=4.8in imagemap;
proc sgrender template=SASStudio.Pie data=WORK.PROD_COUNT;
run;
ods graphics / reset;

ods pdf close;
