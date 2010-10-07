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
colors_langs=c(1,2,3,4,5,6,"gray10","olivedrab","orange","brown")
colors=c("red", "orange", "green", "brown", "navy")

##DONE

##Ginis all logged users
postscript("Lorenz-curves-all.eps", paper="special", height=7, width=7)
road=seq(1:10)
first=TRUE
for (i in road) {
	#Get DB connection
        con=dbConnect(MySQL(), user="root", password="phoenix", dbname=paste("wx_",langs[i],"wiki_research", sep=""))
	revs_per_auth= dbGetQuery(con, "select rev_user, count(*) as num_revs from (select rev_id, rev_user from rev_main_nored where  rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")
	dbDisconnect(con)
	if (first) {
		plot(Lc(revs_per_auth$num_revs), main="Lorenz curves for revisions logged authors",col=colors_langs[i],
		lwd=1.5, cex.axis=1.2, cex.lab=1.2, cex.main=1.2)
		first=FALSE
	}
	else {
		lines(Lc(revs_per_auth$num_revs), col=colors_langs[i], lwd=1.5)
	}
	sink(paste("traces/ineq_indexes_",langs[i],".txt", sep=""))
	print("Gini")
	print(Gini(revs_per_auth$num_revs))
	print("RS")
     	print(RS(revs_per_auth$num_revs))
	print("Atkinson")
     	print(Atkinson(revs_per_auth$num_revs, parameter = 0.5))
	print("Theil")
     	print(Theil(revs_per_auth$num_revs, parameter = 0))
	print("Kolm")
     	print(Kolm(revs_per_auth$num_revs, parameter = 1))
	print("Coefficient of variation")
     	print(var.coeff(revs_per_auth$num_revs, square = FALSE))
	print("Squared coeff. var.")
	print(var.coeff(revs_per_auth$num_revs, square = TRUE))
	print("Entropy")
     	print(entropy(revs_per_auth$num_revs, parameter = 0.5))
	sink()
}
legend("topleft", legend=langs, lty=1, col=colors_langs)
dev.off()

##Ginis
##REVISIONS PER AUTHOR EVOL

sink("traces/ginis_evol_all.txt")
postscript("Lorenz-curves-all-evol.eps", horizontal=F)
par(mfrow=c(5,2))
for (lang in langs) {
	#Get DB connection
	con=dbConnect(MySQL(), user="root", password="phoenix", dbname=paste("wx_",lang,"wiki_research", sep=""))
	print("LANG")
	print(lang)
	revs_per_auth_2004= dbGetQuery(con, "select rev_user, count(*) as num_revs from (select rev_id, rev_user from rev_main_nored where year(rev_timestamp)<2004 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")
	print("Gini 2004")
	print(Gini(revs_per_auth_2004$num_revs))
	revs_per_auth_2005= dbGetQuery(con, "select rev_user, count(*) as num_revs from (select rev_id, rev_user from rev_main_nored where year(rev_timestamp)<2005 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")
	print("Gini 2005")
	print(Gini(revs_per_auth_2005$num_revs))
	revs_per_auth_2006= dbGetQuery(con, "select rev_user, count(*) as num_revs from (select rev_id, rev_user from rev_main_nored where year(rev_timestamp)<2006 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")
	print("Gini 2006")
	print(Gini(revs_per_auth_2006$num_revs))
	revs_per_auth_2007= dbGetQuery(con, "select rev_user, count(*) as num_revs from (select rev_id, rev_user from rev_main_nored where year(rev_timestamp)<2007 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")
	print("Gini 2007")
	print(Gini(revs_per_auth_2007$num_revs))
	revs_per_auth_2008= dbGetQuery(con, "select rev_user, count(*) as num_revs from (select rev_id, rev_user from rev_main_nored where year(rev_timestamp)<2008 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")
	print("Gini 2008")
	print(Gini(revs_per_auth_2008$num_revs))
	dbDisconnect(con)
	plot(Lc(revs_per_auth_2008$num_revs), main=paste("Lorenz curve logged authors (", lang,"wiki)", sep=""), col=colors[5])
	lines(Lc(revs_per_auth_2007$num_revs), col=colors[4])
	lines(Lc(revs_per_auth_2006$num_revs), col=colors[3])
	lines(Lc(revs_per_auth_2005$num_revs), col=colors[2])
	lines(Lc(revs_per_auth_2004$num_revs), col=colors[1])
	legend("topleft", legend=c("2004","2005","2006","2007", "2008"), lty=1, col=colors, cex=0.7)
}
dev.off()
sink()

##Ginis YEARLY
##REVISIONS PER AUTHOR

sink("traces/ginis_evol_yearly_all.txt")
postscript("Lorenz-curves-all-yearly.eps", horizontal=F)
par(mfrow=c(5,2))
for (lang in langs) {
	con=dbConnect(MySQL(), user="root", password="phoenix", dbname=paste("wx_",lang,"wiki_research", sep=""))
	print("LANG")
	print(lang)
	revs_per_auth_2004= dbGetQuery(con, "select rev_user, count(*) as num_revs from (select rev_id, rev_user from rev_main_nored where year(rev_timestamp)=2004 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")
	print("Gini 2004")
	print(Gini(revs_per_auth_2004$num_revs))
	revs_per_auth_2005= dbGetQuery(con, "select rev_user, count(*) as num_revs from (select rev_id, rev_user from rev_main_nored where year(rev_timestamp)=2005 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")
	print("Gini 2005")
	print(Gini(revs_per_auth_2005$num_revs))
	revs_per_auth_2006= dbGetQuery(con, "select rev_user, count(*) as num_revs from (select rev_id, rev_user from rev_main_nored where year(rev_timestamp)=2006 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")
	print("Gini 2006")
	print(Gini(revs_per_auth_2006$num_revs))
	revs_per_auth_2007= dbGetQuery(con, "select rev_user, count(*) as num_revs from (select rev_id, rev_user from rev_main_nored where year(rev_timestamp)=2007 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")
	print("Gini 2007")
	print(Gini(revs_per_auth_2007$num_revs))
	revs_per_auth_2008= dbGetQuery(con, "select rev_user, count(*) as num_revs from (select rev_id, rev_user from rev_main_nored where year(rev_timestamp)=2008 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")
	print("Gini 2008")
	print(Gini(revs_per_auth_2008$num_revs))
	dbDisconnect(con)
	plot(Lc(revs_per_auth_2008$num_revs), main=paste("Lorenz curve logged authors (", lang,"wiki)", sep=""), col=colors[5])
	lines(Lc(revs_per_auth_2007$num_revs), col=colors[4])
	lines(Lc(revs_per_auth_2006$num_revs), col=colors[3])
	lines(Lc(revs_per_auth_2005$num_revs), col=colors[2])
	lines(Lc(revs_per_auth_2004$num_revs), col=colors[1])
	legend("topleft", legend=c("2004","2005","2006","2007", "2008"), lty=1, col=colors, cex=0.7)
}
dev.off()
sink()

################
###2ND ROUND ACTIVATE LATER
################

##Ginis all articles
postscript("Lorenz-curves-arts-all.eps", paper="special", height=6, width=6)
road=seq(1:10)
first=TRUE
for (i in road) {
	#Get DB connection
        con=dbConnect(MySQL(), user="root", password="phoenix", dbname=paste("wx_",langs[i],"wiki_research", sep=""))
	revs_per_art= dbGetQuery(con, "select rev_page, count(*) as num_revs from (select rev_id, rev_page from rev_main_nored where  rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
	dbDisconnect(con)
	if (first) {
		plot(Lc(revs_per_art$num_revs), main="Lorenz curves for revisions in articles",col=colors_langs[i],
		lwd=1.5, cex.axis=1.2, cex.main=1.2, cex.lab=1.2)
		first=FALSE
	}
	else {
		lines(Lc(revs_per_art$num_revs), col=colors_langs[i], lwd=1.5)
	}
	sink(paste("traces/ineq_arts_indexes_",langs[i],".txt", sep=""))
	print("Gini")
	print(Gini(revs_per_art$num_revs))
	print("RS")
     	print(RS(revs_per_art$num_revs))
	print("Atkinson")
     	print(Atkinson(revs_per_art$num_revs, parameter = 0.5))
	print("Theil")
     	print(Theil(revs_per_art$num_revs, parameter = 0))
	print("Kolm")
     	print(Kolm(revs_per_art$num_revs, parameter = 1))
	print("Coefficient of variation")
     	print(var.coeff(revs_per_art$num_revs, square = FALSE))
	print("Squared coeff. var.")
	print(var.coeff(revs_per_art$num_revs, square = TRUE))
	print("Entropy")
     	print(entropy(revs_per_art$num_revs, parameter = 0.5))
	sink()
}
legend("topleft", legend=langs, lty=1, col=colors_langs)
dev.off()

##Ginis
##REVISIONS PER ARTICLE EVOL

sink("traces/ginis_art_evol_all.txt")
postscript("Lorenz-curves-arts-all-evol.eps", horizontal=F)
par(mfrow=c(5,2))
for (lang in langs) {
        #Get DB connection
        con=dbConnect(MySQL(), user="root", password="phoenix", dbname=paste("wx_",lang,"wiki_research", sep=""))

	print("LANG")
	print(lang)
        revs_per_page_2004= dbGetQuery(con, "select rev_page, count(*) as num_revs from (select rev_id, rev_page from rev_main_nored where year(rev_timestamp)<2004 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
	print("Gini 2004")
	print(Gini(revs_per_page_2004$num_revs))
        revs_per_page_2005= dbGetQuery(con, "select rev_page, count(*) as num_revs from (select rev_id, rev_page from rev_main_nored where year(rev_timestamp)<2005 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
	print("Gini 2005")
	print(Gini(revs_per_page_2005$num_revs))
        revs_per_page_2006= dbGetQuery(con, "select rev_page, count(*) as num_revs from (select rev_id, rev_page from rev_main_nored where year(rev_timestamp)<2006 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
	print("Gini 2006")
	print(Gini(revs_per_page_2006$num_revs))
        revs_per_page_2007= dbGetQuery(con, "select rev_page, count(*) as num_revs from (select rev_id, rev_page from rev_main_nored where year(rev_timestamp)<2007 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
	print("Gini 2007")
	print(Gini(revs_per_page_2007$num_revs))
	revs_per_page_2008= dbGetQuery(con, "select rev_page, count(*) as num_revs from (select rev_id, rev_page from rev_main_nored where year(rev_timestamp)<2008 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
	print("Gini 2008")
	print(Gini(revs_per_page_2008$num_revs))
        dbDisconnect(con)

        plot(Lc(revs_per_page_2008$num_revs), main=paste("Lorenz curve articles (", lang,"wiki)", sep=""), col=colors[5])
	lines(Lc(revs_per_page_2007$num_revs), col=colors[4])
	lines(Lc(revs_per_page_2006$num_revs), col=colors[3])
	lines(Lc(revs_per_page_2005$num_revs), col=colors[2])
	lines(Lc(revs_per_page_2004$num_revs), col=colors[1])
	legend("topleft", legend=c("2004","2005","2006","2007", "2008"), lty=1, col=colors, cex=0.7)
}
dev.off()
sink()

##Ginis YEARLY
##REVISIONS PER ARTICLE

sink("traces/ginis_art_evol_yearly_all.txt")
postscript("Lorenz-curves-arts-all-evol-yearly.eps", horizontal=F)
par(mfrow=c(5,2))
for (lang in langs) {
        #Get DB connection
        con=dbConnect(MySQL(), user="root", password="phoenix", dbname=paste("wx_",lang,"wiki_research", sep=""))

	print("LANG")
	print(lang)
        revs_per_page_2004= dbGetQuery(con, "select rev_page, count(*) as num_revs from (select rev_id, rev_page from rev_main_nored where year(rev_timestamp)=2004 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
	print("Gini 2004")
	print(Gini(revs_per_page_2004$num_revs))
        revs_per_page_2005= dbGetQuery(con, "select rev_page, count(*) as num_revs from (select rev_id, rev_page from rev_main_nored where year(rev_timestamp)=2005 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
	print("Gini 2005")
	print(Gini(revs_per_page_2005$num_revs))
        revs_per_page_2006= dbGetQuery(con, "select rev_page, count(*) as num_revs from (select rev_id, rev_page from rev_main_nored where year(rev_timestamp)=2006 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
	print("Gini 2006")
	print(Gini(revs_per_page_2006$num_revs))
        revs_per_page_2007= dbGetQuery(con, "select rev_page, count(*) as num_revs from (select rev_id, rev_page from rev_main_nored where year(rev_timestamp)=2007 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
	print("Gini 2007")
	print(Gini(revs_per_page_2007$num_revs))
	revs_per_page_2008= dbGetQuery(con, "select rev_page, count(*) as num_revs from (select rev_id, rev_page from rev_main_nored where year(rev_timestamp)=2008 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
	print("Gini 2008")
	print(Gini(revs_per_page_2008$num_revs))
        dbDisconnect(con)

        plot(Lc(revs_per_page_2008$num_revs), main=paste("Lorenz curve articles (", lang,"wiki)", sep=""), col=colors[5])
	lines(Lc(revs_per_page_2007$num_revs), col=colors[4])
	lines(Lc(revs_per_page_2006$num_revs), col=colors[3])
	lines(Lc(revs_per_page_2005$num_revs), col=colors[2])
	lines(Lc(revs_per_page_2004$num_revs), col=colors[1])
	legend("topleft", legend=c("2004","2005","2006","2007", "2008"), lty=1, col=colors, cex=0.7)
}
dev.off()
sink()