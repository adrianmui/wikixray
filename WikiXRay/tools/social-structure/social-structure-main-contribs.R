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

library("RMySQL")
library("MASS")
library("Hmisc")
#library("rmutil")
source("aaronc/pareto.R")
source("aaronc/plfit.r") #Already loads VGAM, for truncated Pareto

langs=c("sv","es","pt","it","nl","pl","ja","fr","de","en")

## REVISIONS PER AUTHOR

postscript("graphics/authors_w_equal_num_revs.eps", horizontal=F)
par(mfrow=c(5,2))
postscript("graphics/CCDF_revs_per_author_fit.eps", horizontal=F)
par(mfrow=c(5,2))
postscript("graphics/revs_per_author.eps", horizontal=F)
par(mfrow=c(5,2))
for (lang in langs) {
	
	#Num. of authors with same number of revisions
	#Bots and annons ruled out
	con <- dbConnect(dbDriver("MySQL"),dbname=paste("wx_",lang,"wiki_research", sep=""),user="root",password="phoenix")
	rev_per_author=dbGetQuery(con,"select revs, count(distinct(rev_user)) as num_users from (SELECT rev_user, COUNT(*) as revs from (select rev_id, rev_user, rev_page from rev_main_nored where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user) x group by revs order by revs")
	dbDisconnect(con)
	
	dev.set(dev.list()[1])
	Ecdf(rev_per_author$num_users, "1-F", log="xy", xlab="Authors with same #revisions",
	ylab="CCP",main=paste("CCDF Authors with same #revisions (",lang,"wiki)", sep=""))
	fit_numusers=plfit(rev_per_author$num_users)
	Ecdf(rpareto(50000, fit_numusers$xmin, fit_numusers$alpha), "1-F", log="xy", add=T, col="red")
	##PRINT RESULTS OF FIT TO A FILE
	sink(paste("traces/rev_per_user_",lang,".txt", sep=""))
	print(fit_numusers)
	print(fit_numusers$xmin)
	print(fit_numusers$alpha)
	print(fit_numusers$D)
	sink()
	
	con <- dbConnect(dbDriver("MySQL"),dbname=paste("wx_",lang,"wiki_research", sep=""),user="root",password="phoenix")
	rev_per_user=dbGetQuery(con,"SELECT rev_user, COUNT(*) as num_revs from (select rev_id, rev_user, rev_page from rev_main_nored where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")
	dbDisconnect(con)

	dev.set(dev.list()[2])
	Ecdf(rev_per_user$num_revs, "1-F", log="xy", xlab="Num. revisions per author",
	ylab="Comp. cumulative prob. density",main=paste("CCDF Num. revisions per author (",lang,"wiki)", sep=""))
	
    ###
    ##REVS PER AUTHOR
    ###
	##FIT AN UPPER TRUNCATED PARETO DISTRIBUTION

	##THERE EXIST CERTAIN PROBLEMS WITH THE FITS OF SOME VERSIONS
	##UNIDENTIFIED BOTS LEVERAGE THE CURVES AND THE FIT IS NOT THE MOST PRECISE ONE
	##E.G BlueBot in ENWIKI with more than 200k diff pages revised
	##FOR THOSE VERSIONS, WE FIRST FILTER OUT THOSE UNIDENTIFIED BOTS, THEN FIT

	if(lang=="en") {
		rev_per_user=rev_per_user[rev_per_user$num_revs<277606,]
	}
	lower=1; upper=max(rev_per_user$num_revs)+1
	y=rev_per_user$num_revs[rev_per_user$num_revs>1]
	rev_per_user_fit= vglm(y ~ 1, tpareto1(lower, upper), trace=TRUE, cri="c")
	k=Coef(rev_per_user_fit)
# 	Ecdf(rtpareto(100000, lower, upper, k), "1-F", log="xy", add=T, col="red")
	sink(paste("traces/CCDF_revs_per_author_fit_",lang,".txt",sep=""))
	print(summary(rev_per_user_fit))
	print("COEFFICIENT")
	print(k)
    print("Lower limit")
    print(lower)
    print("Upper limit")
    print(upper)
	sink()

	dev.set(dev.list()[3])
	with(rev_per_author, plot(revs, num_users, type="p", xlab="Num. revisions", ylab="Num. of authors",
	main=paste("#Authors with same #revisions",lang),log="xy"))
	abline(log10(rev_per_author$num_users[1]), -(k+1), lwd=1.8, col="red")
}
dev.off()
dev.off()
dev.off()

#####################################
##ACTIVATE LATER (2nd ROUND)
#####################################

postscript("graphics/art_w_equal_num_revs.eps", horizontal=F)
par(mfrow=c(5,2))
postscript("graphics/CCDF_revs_per_art_fit.eps", horizontal=F)
par(mfrow=c(5,2))
postscript("graphics/revs_per_article.eps", horizontal=F)
par(mfrow=c(5,2))

for (lang in langs) {
	con <- dbConnect(dbDriver("MySQL"),dbname=paste("wx_",lang,"wiki_research", sep=""),user="root",password="phoenix")
	revs_per_article=dbGetQuery(con,"select revs, count(distinct(rev_page)) as num_pages from (SELECT rev_page, COUNT(*) as revs from (select rev_id, rev_user, rev_page from rev_main_nored where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page) x group by revs order by revs")
	dbDisconnect(con)
	
	dev.set(dev.list()[1])
	Ecdf(revs_per_article$num_pages, "1-F", log="xy", xlab="Articles with same #revs",
	ylab="CCP",main=paste("CCDF #arts with same #revisions (",lang,"wiki)", sep=""))
	
	##FIT AN UPPER TRUNCATED PARETO DISTRIBUTION
########CODE NOT VALID ##############
# 	fit_numart= plfit(revs_per_article$num_pages)
# 	Ecdf(rpareto(50000, fit_numart$xmin, fit_numart$alpha), "1-F", log="xy", add=T, col="red")
# 	sink(paste("revs_per_article_",lang,".txt", sep=""))
# 	summary(fit_numart)
# 	sink()
########CODE NOT VALID ##############

	lower=1; upper=max(revs_per_article$num_pages)+1
	y=revs_per_article$num_pages[revs_per_article$num_pages>1]
	fit_revs_per_page=vglm(y ~ 1, tpareto1(lower, upper), trace=TRUE, cri="c")
	k=Coef(fit_revs_per_page)
# 	Ecdf(rtpareto(50000, lower, upper, k), "1-F", log="xy", add=T, col="red")
# 	Ecdf(rpareto(50000, fit_revs_per_page$xmin, fit_revs_per_page$alpha),
#  	"1-F", log="xy", add=T, col="red")
	sink(paste("traces/rev_per_article_",lang,".txt",sep=""))
	print(summary(fit_revs_per_page))
	print("COEFFICIENT")
	print(k)
    print("Lower limit")
    print(lower)
    print("Upper limit")
    print(upper)
	sink()
	
	con <- dbConnect(dbDriver("MySQL"),dbname=paste("wx_",lang,"wiki_research", sep=""),user="root",password="phoenix")
	revs_per_page= dbGetQuery(con, "select rev_page, count(*) as num_revs from (select rev_id, rev_user, rev_page from rev_main_nored where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
	dbDisconnect(con)
	
	dev.set(dev.list()[2])
	Ecdf(revs_per_page$num_revs, "1-F", log="xy", xlab="Num. revs per article",
	ylab="Comp. cumulative prob. density",main=paste("CCDF Num. revisions per article (",lang,"wiki)", sep=""))
	
    ###
    ##REVS. PER ARTICLE
    ###
	##FIT LOGNORMAL DISTRIBUTION
##########CODE NOT VALID ###############
	#lower=1; upper=max(revs_per_page$num_revs)+1
	#y=revs_per_page$num_revs[revs_per_page$num_revs>1]
	#fit_revs_per_page=vglm(y ~ 1, tpareto1(lower, upper), trace=TRUE, cri="c")
	#k=coef(fit_revs_per_page, matrix=TRUE)[1]
	#Ecdf(rtpareto(50000, lower, upper, -k), "1-F", log="xy", add=T, col="red")
##########CODE NOT VALID ###############
	fit_revs_per_page=fitdistr(revs_per_page$num_revs, "lognormal")
	Ecdf(rlnorm(50000, fit_revs_per_page$estimate[1], fit_revs_per_page$estimate[2]),
 	"1-F", log="xy", add=T, col="red")
	sink(paste("traces/CCDF_revs_per_page_fit_",lang,".txt",sep=""))
	print(fit_revs_per_page)
    print("LOGLIK. VALUE")
    print(fit_revs_per_page$loglik)
	sink()

	dev.set(dev.list()[3])
	with(revs_per_article, plot(revs, num_pages, type="p", log="xy", xlab="Num. revisions", ylab="Num. of articles",
	main=paste("#Articles with same #revisions",lang)))
# 	abline(log10(revs_per_article$num_pages[1]), k-1, lwd=1.8, col="red")
	#with(revs_per_article, lines(lowess(num_pages~revs), col="red", lwd=1.8))
}
dev.off()
dev.off()
dev.off()

###############################################################################
