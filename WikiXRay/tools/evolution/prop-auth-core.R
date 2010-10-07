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

langs=c("sv","es","pt","nl","it","pl","ja","fr","de","en")
colors=c(1,2,3,4,5,6,"gray","olivedrab","orange","brown")

##Ginis YEARLY
##REVISIONS PER ARTICLE

#sink("traces/.txt")
postscript("auth-in-core-all.eps", horizontal=T)
#par(mfrow=c(5,2))
first=T
for (lang in langs) {
	i=which(langs==lang)
	con=dbConnect(MySQL(), user="root", password="phoenix", dbname=paste("wx_",lang,"wiki_research", sep=""))
        #Get DB connection
	if (lang=="pt" | lang=="it" | lang=="de") {
	auth_core= dbGetQuery(con, "select year(upper_ts_month) year, month(upper_ts_month) month, count(*) as num_users from users_core_monthly where upper_ts_month>'2003-12-31' and upper_ts_month<'2008-01-01' group by year, month order by year, month")
	}
	else {
	auth_core= dbGetQuery(con, "select year(upper_ts_month) year, month(upper_ts_month) month, count(*) as num_users from users_core_monthly where upper_ts_month<'2008-01-01' group by year, month order by year, month")
	}
        dbDisconnect(con)
	ts_auth_core=ts(log10(auth_core[,3]), start=c(auth_core$year[1], auth_core$month[1]), freq=12)
	if (first) {
	plot(ts_auth_core, type="b", col=colors[i], ylab="Monthly number of authors in core", main="Evolution of #authors in core",
	ylim=c(0.1,5))
	first=F
	}
	else {
	lines(ts_auth_core, type="b", col=colors[i])
	}
	legend("topleft", legend=langs, lty=1, col=colors, cex=0.7)
}
dev.off()
#sink()