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
source("aaronc/pareto.R")
source("aaronc/plfit.r")

langs=c("ru","es","sv","pt","nl","it","pl","ja","fr","de","en")

##AUTHORS PER ARTICLE YEARLY --> LOGNORMAL TEND TO PARETO

postscript("CCDF_authors_per_article_all.eps", horizontal=F)
par(mfrow=c(5,2))
for (lang in langs) {
        #Get DB connection
        con=dbConnect(MySQL(), user="root", password="phoenix", dbname=paste("wx_",lang,"wiki_research", sep=""))
        dbGetQuery(con,"create or replace view rev_art AS (select * from revision where rev_page in (select page_id from page where page_namespace=0 and page_is_redirect=0))")
#         authors_per_page= dbGetQuery(con, "select rev_page, count(distinct(rev_user)) as num_authors from (select rev_id, rev_user, rev_page from rev_art where rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")

        authors_per_page_2003= dbGetQuery(con, "select rev_page, count(distinct(rev_user)) as num_authors from (select rev_id, rev_user, rev_page from rev_art where year(rev_timestamp)<2004 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
        authors_per_page_2004= dbGetQuery(con, "select rev_page, count(distinct(rev_user)) as num_authors from (select rev_id, rev_user, rev_page from rev_art where year(rev_timestamp)=2004 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
        authors_per_page_2005= dbGetQuery(con, "select rev_page, count(distinct(rev_user)) as num_authors from (select rev_id, rev_user, rev_page from rev_art where year(rev_timestamp)=2005 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
        authors_per_page_2006= dbGetQuery(con, "select rev_page, count(distinct(rev_user)) as num_authors from (select rev_id, rev_user, rev_page from rev_art where year(rev_timestamp)=2006 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
        authors_per_page_2007= dbGetQuery(con, "select rev_page, count(distinct(rev_user)) as num_authors from (select rev_id, rev_user, rev_page from rev_art where year(rev_timestamp)=2007 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
        dbDisconnect(con)

        Ecdf(authors_per_page_2007$num_authors, "1-F", log="xy", xlab="diff. authors per article", main=paste("Evolution of CCDF diff. authors per article (", lang,"wiki)", sep=""))
        Ecdf(authors_per_page_2006$num_authors, "1-F", log="xy", add=T, col="blue")
        Ecdf(authors_per_page_2005$num_authors, "1-F", log="xy", add=T, col="red")
        Ecdf(authors_per_page_2004$num_authors, "1-F", log="xy", add=T, col="green")
        Ecdf(authors_per_page_2003$num_authors, "1-F", log="xy", add=T, col="orange")
	  legend("bottomleft", legend=c("2007","2006","2005","2004","<2003"), lty=1, col=c("black", "blue","red","green","orange"), cex=0.7)
}
dev.off()


##ARTICLES PER AUTHOR YEARLY --> LOGNORMAL TO TRUNCATED PARETO

postscript("CCDF_articles_per_author.eps")
par(mfrow=c(5,2))
for (lang in langs) {
	#Get DB connection
	con=dbConnect(MySQL(), user="root", password="phoenix", dbname=paste("wx_",lang,"wiki_research", sep=""))
	
# 	authors_per_page= dbGetQuery(con, "select rev_page, count(distinct(rev_user)) as num_authors from (select rev_id, rev_user, rev_page from rev_art where rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_page")
	
	pages_per_auth_2003= dbGetQuery(con, "select rev_user, count(distinct(rev_page)) as num_pages from (select rev_id, rev_user, rev_page from rev_art where year(rev_timestamp)<2004 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")
	pages_per_auth_2004= dbGetQuery(con, "select rev_user, count(distinct(rev_page)) as num_pages from (select rev_id, rev_user, rev_page from rev_art where year(rev_timestamp)=2004 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")
	pages_per_auth_2005= dbGetQuery(con, "select rev_user, count(distinct(rev_page)) as num_pages from (select rev_id, rev_user, rev_page from rev_art where year(rev_timestamp)=2005 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")
	pages_per_auth_2006= dbGetQuery(con, "select rev_user, count(distinct(rev_page)) as num_pages from (select rev_id, rev_user, rev_page from rev_art where year(rev_timestamp)=2006 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")
	pages_per_auth_2007= dbGetQuery(con, "select rev_user, count(distinct(rev_page)) as num_pages from (select rev_id, rev_user, rev_page from rev_art where year(rev_timestamp)=2007 and rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")
	dbDisconnect(con)
	Ecdf(pages_per_auth_2007$num_pages, "1-F", log="xy", xlab="diff. articles per author", 
	main=paste("Evolution of CCDF diff. articles per author (", lang,"wiki)"))
	Ecdf(pages_per_auth_2006$num_pages, "1-F", log="xy", add=T, col="blue")
	Ecdf(pages_per_auth_2005$num_pages, "1-F", log="xy", add=T, col="red")
	Ecdf(pages_per_auth_2004$num_pages, "1-F", log="xy", add=T, col="green")
	Ecdf(pages_per_auth_2003$num_pages, "1-F", log="xy", add=T, col="orange")
	legend("bottomleft", legend=c("2007","2006","2005","2004","<2003"), lty=1, col=c("black", "blue","red","green","orange"), cex=0.7)
}
dev.off()