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
# source("aaronc/pareto.R") #Apparently, not needed any more, supported by VGAM
source("dubroca/plfit.r") #Already loads VGAM, for truncated Pareto

langs=c("sv","es","pt","it","nl","pl","ja","fr","de","en")

##DONE

postscript("graphics/authors_w_equal_num_diff_art_edited.eps", horizontal=F)
par(mfrow=c(5,2))
postscript("graphics/CCDF_articles_per_author_fit.eps", horizontal=F)
par(mfrow=c(5,2))
postscript("graphics/articles_per_author.eps", horizontal=F)
par(mfrow=c(5,2))
for (lang in langs) {
	#create or replace view rev_main_nored AS (select * from revision where rev_page in 
	#(select page_id from page where page_namespace=0 and page_is_redirect=0));
	
	#Num. of authors with same number of diff articles edited
	#Bots and annons ruled out
	con <- dbConnect(dbDriver("MySQL"),dbname=paste("wx_",lang,"wiki_research", sep=""),user="root",password="phoenix")
	articles_per_author=dbGetQuery(con,"select pages, count(distinct(rev_user)) as num_users from (SELECT rev_user, COUNT(DISTINCT rev_page) as pages from (select rev_id, rev_user, rev_page from rev_main_nored where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user) x group by pages order by pages")
	dbDisconnect(con)
	
	dev.set(dev.list()[1])
	Ecdf(articles_per_author$num_users, "1-F", log="xy", xlab="Authors with same #diff. articles",
	ylab="CCP",main=paste("CCDF Authors with same #diff. articles (",lang,"wiki)", sep=""))
	fit_numusers=plfit(articles_per_author$num_users)
	Ecdf(rpareto(50000, fit_numusers$xmin, fit_numusers$alpha), "1-F", log="xy", add=T, col="red")
	##PRINT RESULTS OF FIT TO A FILE
	sink(paste("traces/articles_per_user_",lang,".txt", sep=""))
	print(summary(fit_numusers))
	print(fit_numusers$xmin)
	print(fit_numusers$alpha)
	print(fit_numusers$D)
	sink()
	
    #####
    ##NUMBER OF DIFF ARTICLES PER AUTHOR
    #####
	con <- dbConnect(dbDriver("MySQL"),dbname=paste("wx_",lang,"wiki_research", sep=""),user="root",password="phoenix")
	articles_per_user=dbGetQuery(con,"SELECT rev_user, COUNT(DISTINCT rev_page) as num_pages from (select rev_id, rev_user, rev_page from rev_main_nored where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")
	dbDisconnect(con)

	dev.set(dev.list()[2])
	Ecdf(articles_per_user$num_pages, "1-F", log="xy", xlab="Num. diff. articles per author",
	ylab="Comp. cumulative prob. density",main=paste("CCDF Num. diff. articles per author (",lang,"wiki)", sep=""))
	
	##FIT AN UPPER TRUNCATED PARETO DISTRIBUTION

	##THERE EXIST CERTAIN PROBLEMS WITH THE FITS OF SOME VERSIONS
	##UNIDENTIFIED BOTS LEVERAGE THE CURVES AND THE FIT IS NOT THE MOST PRECISE ONE
	##E.G BlueBot in ENWIKI with more than 200k diff pages revised
	##FOR THOSE VERSIONS, WE FIRST FILTER OUT THOSE UNIDENTIFIED BOTS, THEN FIT

	if(lang=="en") {
		articles_per_user=articles_per_user[articles_per_user$num_pages<277606,]
	}
	lower=1; upper=max(articles_per_user$num_pages)+1
	y=articles_per_user$num_pages[articles_per_user$num_pages>1]
	articles_per_user_fit= vglm(y ~ 1, tpareto1(lower, upper), trace=TRUE, cri="c")
	k=Coef(articles_per_user_fit)
	Ecdf(rtpareto(50000, lower, upper, k), "1-F", log="xy", add=T, col="red")
	sink(paste("traces/CCDF_arts_per_author_fit_",lang,".txt",sep=""))
	print(summary(articles_per_user_fit))
	print("COEFFICIENT")
	print(k)
    print("LOWER LIMIT")
    print(lower)
    print("UPPER LIMIT")
    print(upper)
	sink()

	dev.set(dev.list()[3])
	with(articles_per_author, plot(pages, num_users, type="p", xlab="Num. diff revised articles", ylab="Num. of authors",
	main=paste("#Authors with same #diff articles",lang),log="xy"))
	abline(log10(articles_per_author$num_users[1]), -(k+1), lwd=1.8, col="red")
}
dev.off()
dev.off()
dev.off()

#####################################
##ACTIVATE LATER (2nd ROUND)
#####################################

postscript("graphics/art_w_equal_num_diff_authors.eps", horizontal=F)
par(mfrow=c(5,2))
postscript("graphics/CCDF_authors_per_art_fit.eps", horizontal=F)
par(mfrow=c(5,2))
postscript("graphics/authors_per_article.eps", horizontal=F)
par(mfrow=c(5,2))

    ####
    ##ARTS SAME NUM. OF AUTHORS
    ####
for (lang in langs) {
	con <- dbConnect(dbDriver("MySQL"),dbname=paste("wx_",lang,"wiki_research", sep=""),user="root",password="phoenix")
	users_per_article=dbGetQuery(con,"select users, count(distinct(rev_page)) as num_pages from (SELECT rev_page, COUNT(DISTINCT rev_user) as users from (select rev_id, rev_user, rev_page from rev_main_nored where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page) x group by users order by users")
	dbDisconnect(con)
	
	dev.set(dev.list()[1])
	Ecdf(users_per_article$num_pages, "1-F", log="xy", xlab="Articles with same #diff. authors",
	ylab="CCP",main=paste("CCDF #arts with same #diff. authors (",lang,"wiki)", sep=""))
	
	##FIT AN UPPER TRUNCATED PARETO DISTRIBUTION
	lower=1; upper=max(users_per_article$num_pages)+1
	y=users_per_article$num_pages[users_per_article$num_pages>1]
	fit_authors_per_page=vglm(y ~ 1, tpareto1(lower, upper), trace=TRUE, cri="c")
	k=Coef(fit_authors_per_page)
	Ecdf(rtpareto(50000, lower, upper, k), "1-F", log="xy", add=T, col="red")
	sink(paste("traces/users_per_article_",lang,".txt", sep=""))
	print(summary(fit_authors_per_page))
	print("COEFFICIENT")
	print(k)
    print("LOWER LIMIT")
    print(lower)
    print("UPPER LIMIT")
    print(upper)
	sink()
	
	con <- dbConnect(dbDriver("MySQL"),dbname=paste("wx_",lang,"wiki_research", sep=""),user="root",password="phoenix")
	authors_per_page= dbGetQuery(con, "select rev_page, count(distinct(rev_user)) as num_authors from (select rev_id, rev_user, rev_page from rev_main_nored where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
	dbDisconnect(con)
	
	dev.set(dev.list()[2])
	Ecdf(authors_per_page$num_authors, "1-F", log="xy", xlab="Num. diff. authors per article",
	ylab="Comp. cumulative prob. density",main=paste("CCDF Num. diff. authors per article (",lang,"wiki)", sep=""))
	
    ####
    ##AUTHORS PER ARTICLE
    ####
	##LOGNORMAL
######
#####CODE NOT VALID #######
# 	lower=1; upper=max(authors_per_page$num_authors)+1
# 	y=authors_per_page$num_authors[authors_per_page$num_authors>1]
# 	fit_authors_per_page=vglm(y ~ 1, tpareto1(lower, upper), trace=TRUE, cri="c")
# 	k=coef(articles_per_user_fit, matrix=TRUE)[1]
# 	Ecdf(rtpareto(50000, lower, upper, -k), "1-F", log="xy", add=T, col="red")
#####CODE NOT VALID #######
	fit_authors_per_page=fitdistr(authors_per_page$num_authors, "lognormal")
	Ecdf(rlnorm(50000, fit_authors_per_page$estimate[1], fit_authors_per_page$estimate[2]),
 	"1-F", log="xy", add=T, col="red")
	sink(paste("traces/CCDF_authors_per_page_fit_",lang,".txt",sep=""))
	print(fit_authors_per_page)
    print("LOGLIK. VALUE")
    print(fit_authors_per_page$loglik)
	sink()

	dev.set(dev.list()[3])
	with(users_per_article, plot(users, num_pages, type="p", log="xy", xlab="Num. diff. authors", ylab="Num. of articles",
	main=paste("#Articles with same #diff. authors",lang)))
# 	abline(log10(users_per_article$num_pages[1]), k-1, lwd=1.8, col="red")
# 	with(users_per_article, lowess(num_pages~users), col="red", lwd=1.8)
}
dev.off()
dev.off()
dev.off()

###############################################################################