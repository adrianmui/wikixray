#!/usr/bin/Rscript
#
# WikiXRay: A tool for quantitative analysis of Wikipedia                       
#
# <http://projects.libresoft.es/projects/show/wikixray/>
# <http://gitorious.org/wikixray>
#
# Copyright (c) 2006-2010 Felipe Ortega     
#
# This program is free software: you can redistribute it and/or modify it 
# under the terms of the GNU General Public License as published by 
# the Free Software Foundation, either version 3 of the License, or 
# (at your option) any later version. This program is distributed in the 
# hope that it will be useful, but WITHOUT ANY WARRANTY; without 
# even the implied warranty of MERCHANTABILITY or FITNESS FOR 
# A PARTICULAR PURPOSE. See the GNU General Public License 
# for more details. You should have received a copy of the GNU General Public 
# License along with this program. If not, see <http://www.gnu.org/licenses/>
#
# Author: Felipe Ortega
#


#Call RMySQL library
library(RMySQL)

#Names of dbs to analyze
langs=c("es","sv","pt","nl","it","ja","pl","fr","de","en")
#langs=c("es","sv")

postscript("graphics/births-deaths-all.eps", horizontal=F)
par(mfrow=c(5,2))
#Loop for each lang
for (lang in langs){
	
	#Get new db conn
	con <- dbConnect(dbDriver("MySQL"),dbname=paste("wx_",lang,"wiki_research",sep=""),user="root",password="phoenix")
	
	#Births in each month
	# Prevent in where clause plotting beyond the deadline of our data sample

    ## Special case of langugaes PT IT and DE
    if (lang=="pt" | lang=="it" | lang=="de") {
#     births=dbGetQuery(con,"select year(min_ts) as year, month(min_ts) as month, count(*) births from (select x.* from (select rev_user, min(rev_timestamp) min_ts,  max(rev_timestamp) max_ts from rev_main_nored where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot') group by rev_user having min_ts<'2009-07-01' and min_ts>'2003-12-31') x) y group by year, month order by year, month")
    births=dbGetQuery(con,"select year(min_ts) as year, month(min_ts) as month, count(*) births from time_range_users where min_ts<'2009-05-01' and min_ts>'2003-12-31' group by year, month order by year,month")

	#Deaths in each month
	# We can count as sure deaths only until one month before the deadline of our data sample
# 	deaths=dbGetQuery(con,"select year(max_ts) as year, month(max_ts) as month, count(*) deaths from (select x.* from (select rev_user, min(rev_timestamp) min_ts,  max(rev_timestamp) max_ts from rev_main_nored where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot') group by rev_user having max_ts<'2009-06-01' and max_ts>'2003-12-31') x) y group by year, month order by year, month")
    deaths=dbGetQuery(con,"select year(max_ts) as year, month(max_ts) as month, count(*) deaths from time_range_users where max_ts<'2009-04-01' and max_ts>'2003-12-31' group by year, month order by year, month")
    }

    ## Rest of languages
    else {
# 	births=dbGetQuery(con,"select year(min_ts) as year, month(min_ts) as month, count(*) births from (select x.* from (select rev_user, min(rev_timestamp) min_ts,  max(rev_timestamp) max_ts from rev_main_nored where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot') group by rev_user having min_ts<'2009-07-01') x) y group by year, month order by year, month")
    births=dbGetQuery(con,"select year(min_ts) as year, month(min_ts) as month, count(*) births from time_range_users where min_ts<'2009-05-01' group by year, month order by year,month")

	#Deaths in each month
	# We can count as sure deaths only until one month before the deadline of our data sample
# 	deaths=dbGetQuery(con,"select year(max_ts) as year, month(max_ts) as month, count(*) deaths from (select x.* from (select rev_user, min(rev_timestamp) min_ts,  max(rev_timestamp) max_ts from rev_main_nored where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot') group by rev_user having max_ts<'2009-06-01') x) y group by year, month order by year, month")
    deaths=dbGetQuery(con,"select year(max_ts) as year, month(max_ts) as month, count(*) deaths from time_range_users where max_ts<'2009-04-01' group by year, month order by year, month")
    }
	#Close DB connection
	dbDisconnect(con)

    #Save numerical data about births and deaths
    sink(paste("traces/births-",lang,".dat", sep=''))
    print(births)
    sink(paste("traces/deaths-",lang,".dat", sep=''))
    print(deaths)
    sink()

	births_ts=ts(births$births, start=c(births$year[1], births$month[1]), freq=12)
	deaths_ts=ts(deaths$deaths, start=c(deaths$year[1], deaths$month[1]), freq=12)
	min_births=min(births$births)
	min_deaths=min(deaths$deaths)
	max_births=max(births$births)
	max_deaths=max(deaths$deaths)
	plot(births_ts, log="xy", ylab="Births and deads", main=paste("Births and deaths in ",lang,"wiki", sep=""), 
	ylim=c(min(min_births, min_deaths), max(max_births,max_deaths)), col="navy")
	lines(deaths_ts, log="xy", col="red")

	#Add legend
	legend("bottomright", legend=c("births (log10)", "deaths (log10)"), col=c("navy","red"), lty=1)
}
#Close ps device; generate figure
dev.off()

