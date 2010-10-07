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

library(RMySQL)
library(ineq)

#Names of dbs to analyze
langs=c("sv","es","pt","nl","it","ja","pl","fr","de","en")
colors=c("gray" ,"navy","green", "black", "red", "yellow", "orange", "khaki", "magenta", "brown")
years=2002:2007
months=1:12
#langs=c("es","sv")

postscript("graphics/ginis-evol-all.eps", horizontal=T)
#Loop for each lang
first=T
for (lang in langs){
        #Clear array of Gini coeffs
        coeffs=numeric(0)
	i=which(langs==lang)
        #Loop for each month in each year
        for (year in years) {
        for (month in months) {
	#Get new db conn
	con <- dbConnect(dbDriver("MySQL"),dbname=paste("wx_",lang,"wiki_research",sep=""),user="root",password="phoenix")
	#Revisions per user in each month
        revisions=dbGetQuery(con,paste("select year(rev_timestamp) as year, month(rev_timestamp) as month, rev_user, count(*) as num_revs from (select rev_user, rev_timestamp from rev_main_nored where year(rev_timestamp)=",year," and month(rev_timestamp)=",month," and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot') )x group by year, month, rev_user"))
        #Close DB connection
	dbDisconnect(con)
        #Calculate Gini coeff for this month, then append to vector of coeffs
        if (length(revisions)>0){
            coeff=Gini(revisions$num_revs)
            coeffs=c(coeffs, round(coeff*100.0, digits=2))
        }
        else {
            coeffs=c(coeffs,0)
        }
        }
        }
        #Once completed, create ts object and plot
        sink(paste("traces/ginis_monthly_",lang,".txt"))
        print(coeffs)
        coeffs_ts=ts(coeffs, start=c(2002,1), freq=12)
        print(coeffs_ts)
        sink()
        if (first) {
            plot(coeffs_ts,main="Evol. of monthly Gini coeff.", ylab="Gini coeff (%)", ylim=c(0,90), col=colors[i], lwd=1.3)
            grid()
            first=F
        }
        else {
            lines(coeffs_ts, col=colors[i], lwd=1.3)
        }
}
#Add legend
legend("bottomright", legend=langs, col=colors, lty=1, lwd=1.3)
#Close ps device; generate figure
dev.off()