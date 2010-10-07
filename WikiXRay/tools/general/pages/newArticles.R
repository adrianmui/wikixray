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

###SCRIPT EVOLUTION IN TIME OF TOT. NUM OF CONTRIBS
###AND PROPORTIONS:
###STARTING FROM TOT. NUM OF CONTRIBS TO ARTICLES
###PROP OF CONTRIBS LOGGED USERS TO ARTICS
###PROP OF CONTRIBS ANNONS USERS TO ARTICS
###PROP OF CONTRIBS BOTS TO ARTICS

# Cargar archivo con num. total de contribs. en artículos

# yvals<-read.table("./pruebaR.txt",header=T)

library(RMySQL)
# library(lattice)

conenwiki=dbConnect(MySQL(), user="root", password="phoenix", dbname="wx_enwiki_research")
monthlyen=dbGetQuery(conenwiki, "select year(min_ts) theyear, month(min_ts) themonth, count(distinct(rev_page)) 
new_articles from (select min(rev_timestamp) min_ts, rev_page from revision where rev_is_redirect = 0 and 
rev_page in (select page_id from page where page_namespace=0) group by rev_page) x group by theyear, themonth")
dbDisconnect(conenwiki)

condewiki=dbConnect(MySQL(), user="root", password="phoenix", dbname="wx_dewiki_research")
monthlyde=dbGetQuery(condewiki,"select year(min_ts) theyear, month(min_ts) themonth, count(distinct(rev_page)) 
new_articles from (select min(rev_timestamp) min_ts, rev_page from revision where rev_is_redirect = 0 and 
rev_page in (select page_id from page where page_namespace=0) group by rev_page) x group by theyear, themonth")
dbDisconnect(condewiki)

confrwiki=dbConnect(MySQL(), user="root", password="phoenix", dbname="wx_frwiki_research")
monthlyfr=dbGetQuery(confrwiki,"select year(min_ts) theyear, month(min_ts) themonth, count(distinct(rev_page)) 
new_articles from (select min(rev_timestamp) min_ts, rev_page from revision where rev_is_redirect = 0 and 
rev_page in (select page_id from page where page_namespace=0) group by rev_page) x group by theyear, themonth")
dbDisconnect(confrwiki)

conplwiki=dbConnect(MySQL(), user="root", password="phoenix", dbname="wx_plwiki_research")
monthlypl=dbGetQuery(conplwiki,"select year(min_ts) theyear, month(min_ts) themonth, count(distinct(rev_page)) 
new_articles from (select min(rev_timestamp) min_ts, rev_page from revision where rev_is_redirect = 0 and 
rev_page in (select page_id from page where page_namespace=0) group by rev_page) x group by theyear, themonth")
dbDisconnect(conplwiki)

conjawiki=dbConnect(MySQL(), user="root", password="phoenix", dbname="wx_jawiki_research")
monthlyja=dbGetQuery(conjawiki,"select year(min_ts) theyear, month(min_ts) themonth, count(distinct(rev_page)) 
new_articles from (select min(rev_timestamp) min_ts, rev_page from revision where rev_is_redirect = 0 and 
rev_page in (select page_id from page where page_namespace=0) group by rev_page) x group by theyear, themonth")
dbDisconnect(conjawiki)

connlwiki=dbConnect(MySQL(), user="root", password="phoenix", dbname="wx_nlwiki_research")
monthlynl=dbGetQuery(connlwiki,"select year(min_ts) theyear, month(min_ts) themonth, count(distinct(rev_page)) 
new_articles from (select min(rev_timestamp) min_ts, rev_page from revision where rev_is_redirect = 0 and 
rev_page in (select page_id from page where page_namespace=0) group by rev_page) x group by theyear, themonth")
dbDisconnect(connlwiki)

conitwiki=dbConnect(MySQL(), user="root", password="phoenix", dbname="wx_itwiki_research")
monthlyit=dbGetQuery(conitwiki,"select year(min_ts) theyear, month(min_ts) themonth, count(distinct(rev_page)) 
new_articles from (select min(rev_timestamp) min_ts, rev_page from revision where rev_is_redirect = 0 and 
rev_page in (select page_id from page where page_namespace=0) group by rev_page) x group by theyear, themonth")
dbDisconnect(conitwiki)

conptwiki=dbConnect(MySQL(), user="root", password="phoenix", dbname="wx_ptwiki_research")
monthlypt=dbGetQuery(conptwiki,"select year(min_ts) theyear, month(min_ts) themonth, count(distinct(rev_page)) 
new_articles from (select min(rev_timestamp) min_ts, rev_page from revision where rev_is_redirect = 0 and 
rev_page in (select page_id from page where page_namespace=0) group by rev_page) x group by theyear, themonth")
dbDisconnect(conptwiki)

coneswiki=dbConnect(MySQL(), user="root", password="phoenix", dbname="wx_eswiki_research")
monthlyes=dbGetQuery(coneswiki,"select year(min_ts) theyear, month(min_ts) themonth, count(distinct(rev_page)) 
new_articles from (select min(rev_timestamp) min_ts, rev_page from revision where rev_is_redirect = 0 and 
rev_page in (select page_id from page where page_namespace=0) group by rev_page) x group by theyear, themonth")
dbDisconnect(coneswiki)

consvwiki=dbConnect(MySQL(), user="root", password="phoenix", dbname="wx_svwiki_research")
monthlysv=dbGetQuery(consvwiki,"select year(min_ts) theyear, month(min_ts) themonth, count(distinct(rev_page)) 
new_articles from (select min(rev_timestamp) min_ts, rev_page from revision where rev_is_redirect = 0 and 
rev_page in (select page_id from page where page_namespace=0) group by rev_page) x group by theyear, themonth")
dbDisconnect(consvwiki)

enwiki<-ts(monthlyen[,3],start=c(monthlyen[1,1],monthlyen[1,2]),freq=12)
dewiki<-ts(monthlyde[,3],start=c(monthlyde[1,1],monthlyde[1,2]),freq=12)
frwiki<-ts(monthlyfr[,3],start=c(monthlyfr[1,1],monthlyfr[1,2]),freq=12)
plwiki<-ts(monthlypl[,3],start=c(monthlypl[1,1],monthlypl[1,2]),freq=12)
jawiki<-ts(monthlyja[,3],start=c(monthlyja[1,1],monthlyja[1,2]),freq=12)
nlwiki<-ts(monthlynl[,3],start=c(monthlynl[1,1],monthlynl[1,2]),freq=12)
itwiki<-ts(monthlyit[,3],start=c(monthlyit[1,1],monthlyit[1,2]),freq=12)
ptwiki<-ts(monthlypt[,3],start=c(monthlypt[1,1],monthlypt[1,2]),freq=12)
eswiki<-ts(monthlyes[,3],start=c(monthlyes[1,1],monthlyes[1,2]),freq=12)
svwiki<-ts(monthlysv[,3],start=c(monthlysv[1,1],monthlysv[1,2]),freq=12)

postscript("./graphics/newArticles.eps",onefile=FALSE,horizontal=FALSE,height=9,width=15,paper="special")
plot(enwiki,log="xy",type="b",col=1,ylim=range(1,5e+5),xlab="Time",ylab="Num. of new articles", main="Evolution in time of number of new articles",pch=15,lty=1, cex.axis=1.7, cex.lab=1.5, cex.main=1.8)
grid(col=1)
lines(dewiki,type="b",col=2,pch=16)
lines(frwiki,type="b",col=3,pch=17)
lines(jawiki,type="b",col=4,pch=18)
lines(plwiki,type="b",col=5,pch=19)
lines(nlwiki,type="b",col=6,pch=20)
lines(itwiki,type="b",col="gray10",pch=21)
lines(ptwiki,type="b",col="olivedrab",pch=22)
lines(svwiki,type="b",col="orange",pch=23)
lines(eswiki,type="b",col="brown",pch=24)
legend("bottomright",c("EN","DE","FR","JA","PL","NL","IT","PT","SV","ES"),col=c(1,2,3,4,5,6,"gray10","olivedrab","orange","brown"),pch=c(15:24), cex=1.8)
dev.off() 
