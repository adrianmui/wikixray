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

# langs=c("ru","es","sv","pt","nl","it","pl","ja","fr","de","en")
langs=c("en","de","fr","ja","pl","it","nl","pt","es","ru")
colours=c("black","red", "navy", "yellow", "brown", "magenta", "green", "pink", "grey", "orange", "aquamarine")

postscript("./graphics/bots_shares_logged.eps")

first=TRUE
i=1
point=15
for (lang in langs) {
	# Get DB connection
	con=dbConnect(MySQL(), user="root", password="phoenix", dbname=paste("wx_",lang,"wiki_research", sep=""))
	
	# Get results for logged authors
	share_logged=dbGetQuery(con, "select bot.theyear, bot.themonth, (bot.num_revs/logged.num_revs)*100 perc_logged_revs from revs_bots as bot, revision_logged as logged where bot.theyear=logged.theyear and bot.themonth=logged.themonth")

	ts_logged=ts(share_logged$perc_logged_revs, start=c(share_logged$theyear[1], share_logged$themonth[1]), frequency=12)
	dbDisconnect(con)
	if(first) {
		plot(ts_logged, xlab="time", ylab="% of tot. num. of edits", main="Bot share of total num. of edits by logged users",
		ylim=c(0,75), xlim=c(2002.9,2008.3), col=colours[i], pch=point)
		first=FALSE
	}
	lines(ts_logged, type="b",col=colours[i], pch=point)
	i=i+1
	point=point+1
}
legend("topright", legend=langs, col=colours, pch=c(15:25))
dev.off()

postscript("/graphics/bots_shares_total.eps")

first=TRUE
i=1
point=15
for (lang in langs) {

	# Get DB connection
	con=dbConnect(MySQL(), user="root", password="phoenix", dbname=paste("wx_",lang,"wiki_research", sep=""))
	
	# Get results for logged authors
	share_total=dbGetQuery(con,"select bot.theyear, bot.themonth, (bot.num_revs/tot.num_revs)*100 perc_revs from revs_bots as bot, revs_all as tot where bot.theyear=tot.theyear and bot.themonth=tot.themonth")

	ts_total=ts(share_total$perc_revs, start=c(share_total$theyear[1], share_total$themonth[1]), frequency=12)
	dbDisconnect(con)
	if(first) {
		plot(ts_logged, xlab="time", ylab="% of tot. num. of edits", main="Bot share of total num. of edits",
		ylim=c(0,75), xlim=c(2002.9,2008.3), col=colours[i], pch=point)
		first=FALSE
	}
	lines(ts_total, type="b",col=colours[i], pch=point)
	i=i+1
	point=point+1
}
legend("topright", legend=langs, col=colours, pch=c(15:25))
dev.off()