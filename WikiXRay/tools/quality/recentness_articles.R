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

con_pt <- dbConnect(dbDriver("MySQL"),dbname="wx_ptwiki_research",user="root",password="phoenix")
con_es <- dbConnect(dbDriver("MySQL"),dbname="wx_eswiki_research",user="root",password="phoenix")
con_nl <- dbConnect(dbDriver("MySQL"),dbname="wx_nlwiki_research",user="root",password="phoenix")
con_de <- dbConnect(dbDriver("MySQL"),dbname="wx_dewiki_research",user="root",password="phoenix")
con_fr <- dbConnect(dbDriver("MySQL"),dbname="wx_frwiki_research",user="root",password="phoenix")
con_ja <- dbConnect(dbDriver("MySQL"),dbname="wx_jawiki_research",user="root",password="phoenix")
con_pl <- dbConnect(dbDriver("MySQL"),dbname="wx_plwiki_research",user="root",password="phoenix")
con_it <- dbConnect(dbDriver("MySQL"),dbname="wx_itwiki_research",user="root",password="phoenix")
con_sv <- dbConnect(dbDriver("MySQL"),dbname="wx_svwiki_research",user="root",password="phoenix")
con_en <- dbConnect(dbDriver("MySQL"),dbname="wx_enwiki_research",user="root",password="phoenix")

#############################
####### RECENTNESS ARTICLES
#############################

##FAs

results_pt <- dbGetQuery(con_pt,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page in (select page_id from page_FAs) having recentness>0")
results_de <- dbGetQuery(con_de,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page in (select page_id from page_FAs) having recentness>0")
results_es <- dbGetQuery(con_es,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page in (select page_id from page_FAs) having recentness>0")
results_nl <- dbGetQuery(con_nl,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page in (select page_id from page_FAs) having recentness>0")
results_fr <- dbGetQuery(con_fr,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page in (select page_id from page_FAs) having recentness>0")
results_ja <- dbGetQuery(con_ja,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page in (select page_id from page_FAs) having recentness>0")
results_pl <- dbGetQuery(con_pl,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page in (select page_id from page_FAs) having recentness>0")
results_it <- dbGetQuery(con_it,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page in (select page_id from page_FAs) having recentness>0")
results_sv <- dbGetQuery(con_sv,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page in (select page_id from page_FAs) having recentness>0")
results_en <- dbGetQuery(con_en,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page in (select page_id from page_FAs) having recentness>0")

recentness_en=log10(results_en[,1])
recentness_de=log10(results_de[,1])
recentness_fr=log10(results_fr[,1])
recentness_pl=log10(results_pl[,1])
recentness_ja=log10(results_ja[,1])
recentness_nl=log10(results_nl[,1])
recentness_it=log10(results_it[,1])
recentness_pt=log10(results_pt[,1])
recentness_es=log10(results_es[,1])
recentness_sv=log10(results_sv[,1])

linedens_en=density(recentness_en)
linedens_de=density(recentness_de)
linedens_fr=density(recentness_fr)
linedens_pl=density(recentness_pl)
linedens_ja=density(recentness_ja)
linedens_nl=density(recentness_nl)
linedens_it=density(recentness_it)
linedens_pt=density(recentness_pt)
linedens_es=density(recentness_es)
linedens_sv=density(recentness_sv)

postscript("graphics/hist_recentness_LOG10DAYS_FAs.eps")

plot(linedens_en, col="gray", type="l",lty=1, lwd=1.5, ylim=c(0,max(c(linedens_pt$y, linedens_es$y, linedens_nl$y, linedens_de$y, linedens_en$y, linedens_fr$y, linedens_it$y, linedens_pl$y, linedens_ja$y, linedens_sv$y))), xlab="log10(recentness of FAs (days))", ylab="prob. density", main="KDE recentness of FAs")
lines(linedens_de, type="l",col="navy", lty=1, lwd=1.5)
lines(linedens_fr, type="l",col="green", lty=1, lwd=1.5)
lines(linedens_pl, type="l",col="black", lty=1, lwd=1.5)
lines(linedens_ja, type="l",col="red", lty=1, lwd=1.5)
lines(linedens_it, type="l",col="yellow", lty=1, lwd=1.5)
lines(linedens_nl, type="l",col="orange", lty=1, lwd=1.5)
lines(linedens_pt, type="l",col="khaki", lty=1, lwd=1.5)
lines(linedens_es, type="l",col="magenta", lty=1, lwd=1.5)
lines(linedens_sv, type="l",col="brown", lty=1, lwd=1.5)

legend(x="topleft", legend=c("enwiki","dewiki", "frwiki", "plwiki", "jawiki", "itwiki", "nlwiki", "ptwiki", "eswiki", "svwiki"), col=c("gray" ,"navy","green", "black", "red", "yellow", "orange", "khaki", "magenta", "brown"), lty=1, lwd=1.5)

dev.off()

#######################################

##non-FAs

results_pt <- dbGetQuery(con_pt,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page not in (select page_id from page_FAs) having recentness>0")
results_de <- dbGetQuery(con_de,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page not in (select page_id from page_FAs) having recentness>0")
results_es <- dbGetQuery(con_es,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page not in (select page_id from page_FAs) having recentness>0")
results_nl <- dbGetQuery(con_nl,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page not in (select page_id from page_FAs) having recentness>0")
results_fr <- dbGetQuery(con_fr,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page not in (select page_id from page_FAs) having recentness>0")
results_ja <- dbGetQuery(con_ja,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page not in (select page_id from page_FAs) having recentness>0")
results_pl <- dbGetQuery(con_pl,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page not in (select page_id from page_FAs) having recentness>0")
results_it <- dbGetQuery(con_it,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page not in (select page_id from page_FAs) having recentness>0")
results_sv <- dbGetQuery(con_sv,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page not in (select page_id from page_FAs) having recentness>0")
results_en <- dbGetQuery(con_en,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles where rev_page not in (select page_id from page_FAs) having recentness>0")

recentness_en=log10(results_en[,1])
recentness_de=log10(results_de[,1])
recentness_fr=log10(results_fr[,1])
recentness_pl=log10(results_pl[,1])
recentness_ja=log10(results_ja[,1])
recentness_nl=log10(results_nl[,1])
recentness_it=log10(results_it[,1])
recentness_pt=log10(results_pt[,1])
recentness_es=log10(results_es[,1])
recentness_sv=log10(results_sv[,1])

linedens_en=density(recentness_en)
linedens_de=density(recentness_de)
linedens_fr=density(recentness_fr)
linedens_pl=density(recentness_pl)
linedens_ja=density(recentness_ja)
linedens_nl=density(recentness_nl)
linedens_it=density(recentness_it)
linedens_pt=density(recentness_pt)
linedens_es=density(recentness_es)
linedens_sv=density(recentness_sv)

postscript("graphics/hist_recentness_LOG10DAYS_non-FAs.eps")

plot(linedens_en, col="gray", type="l",lty=1, lwd=1.5, ylim=c(0,max(c(linedens_pt$y, linedens_es$y, linedens_nl$y, linedens_de$y, linedens_en$y, linedens_fr$y, linedens_it$y, linedens_pl$y, linedens_ja$y, linedens_sv$y))), xlab="log10(recentness of non-FAs (days))", ylab="prob. density", main="KDE recentness of non-FAs")
lines(linedens_de, type="l",col="navy", lty=1, lwd=1.5)
lines(linedens_fr, type="l",col="green", lty=1, lwd=1.5)
lines(linedens_pl, type="l",col="black", lty=1, lwd=1.5)
lines(linedens_ja, type="l",col="red", lty=1, lwd=1.5)
lines(linedens_it, type="l",col="yellow", lty=1, lwd=1.5)
lines(linedens_nl, type="l",col="orange", lty=1, lwd=1.5)
lines(linedens_pt, type="l",col="khaki", lty=1, lwd=1.5)
lines(linedens_es, type="l",col="magenta", lty=1, lwd=1.5)
lines(linedens_sv, type="l",col="brown", lty=1, lwd=1.5)

legend(x="topleft", legend=c("enwiki","dewiki", "frwiki", "plwiki", "jawiki", "itwiki", "nlwiki", "ptwiki", "eswiki", "svwiki"), col=c("gray" ,"navy","green", "black", "red", "yellow", "orange", "khaki", "magenta", "brown"), lty=1, lwd=1.5)

dev.off()

#######################################

##ALL ARTICLES

results_pt <- dbGetQuery(con_pt,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles having recentness>0")
results_de <- dbGetQuery(con_de,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles having recentness>0")
results_es <- dbGetQuery(con_es,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles having recentness>0")
results_nl <- dbGetQuery(con_nl,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles having recentness>0")
results_fr <- dbGetQuery(con_fr,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles having recentness>0")
results_ja <- dbGetQuery(con_ja,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles having recentness>0")
results_pl <- dbGetQuery(con_pl,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles having recentness>0")
results_it <- dbGetQuery(con_it,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles having recentness>0")
results_sv <- dbGetQuery(con_sv,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles having recentness>0")
results_en <- dbGetQuery(con_en,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_articles having recentness>0")

recentness_en=log10(results_en[,1])
recentness_de=log10(results_de[,1])
recentness_fr=log10(results_fr[,1])
recentness_pl=log10(results_pl[,1])
recentness_ja=log10(results_ja[,1])
recentness_nl=log10(results_nl[,1])
recentness_it=log10(results_it[,1])
recentness_pt=log10(results_pt[,1])
recentness_es=log10(results_es[,1])
recentness_sv=log10(results_sv[,1])

linedens_en=density(recentness_en)
linedens_de=density(recentness_de)
linedens_fr=density(recentness_fr)
linedens_pl=density(recentness_pl)
linedens_ja=density(recentness_ja)
linedens_nl=density(recentness_nl)
linedens_it=density(recentness_it)
linedens_pt=density(recentness_pt)
linedens_es=density(recentness_es)
linedens_sv=density(recentness_sv)

postscript("graphics/hist_recentness_LOG10DAYS_articles.eps")

plot(linedens_en, col="gray", type="l",lty=1, lwd=1.5, ylim=c(0,max(c(linedens_pt$y, linedens_es$y, linedens_nl$y, linedens_de$y, linedens_en$y, linedens_fr$y, linedens_it$y, linedens_pl$y, linedens_ja$y, linedens_sv$y))), xlab="log10(recentness of articles (days))", ylab="prob. density", main="KDE recentness of all articles")
lines(linedens_de, type="l",col="navy", lty=1, lwd=1.5)
lines(linedens_fr, type="l",col="green", lty=1, lwd=1.5)
lines(linedens_pl, type="l",col="black", lty=1, lwd=1.5)
lines(linedens_ja, type="l",col="red", lty=1, lwd=1.5)
lines(linedens_it, type="l",col="yellow", lty=1, lwd=1.5)
lines(linedens_nl, type="l",col="orange", lty=1, lwd=1.5)
lines(linedens_pt, type="l",col="khaki", lty=1, lwd=1.5)
lines(linedens_es, type="l",col="magenta", lty=1, lwd=1.5)
lines(linedens_sv, type="l",col="brown", lty=1, lwd=1.5)

legend(x="topleft", legend=c("enwiki","dewiki", "frwiki", "plwiki", "jawiki", "itwiki", "nlwiki", "ptwiki", "eswiki", "svwiki"), col=c("gray" ,"navy","green", "black", "red", "yellow", "orange", "khaki", "magenta", "brown"), lty=1, lwd=1.5)

dev.off()

#############################
####### RECENTNESS AUTHORS
#############################

##AUTHORS IN FAs
results_pt <- dbGetQuery(con_pt,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user in (select distinct(rev_user) from revision_FAs) having recentness>0")
results_de <- dbGetQuery(con_de,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user in (select distinct(rev_user) from revision_FAs) having recentness>0")
results_es <- dbGetQuery(con_es,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user in (select distinct(rev_user) from revision_FAs) having recentness>0")
results_nl <- dbGetQuery(con_nl,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user in (select distinct(rev_user) from revision_FAs) having recentness>0")
results_fr <- dbGetQuery(con_fr,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user in (select distinct(rev_user) from revision_FAs) having recentness>0")
results_ja <- dbGetQuery(con_ja,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user in (select distinct(rev_user) from revision_FAs) having recentness>0")
results_pl <- dbGetQuery(con_pl,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user in (select distinct(rev_user) from revision_FAs) having recentness>0")
results_it <- dbGetQuery(con_it,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user in (select distinct(rev_user) from revision_FAs) having recentness>0")
results_sv <- dbGetQuery(con_sv,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user in (select distinct(rev_user) from revision_FAs) having recentness>0")
results_en <- dbGetQuery(con_en,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user in (select distinct(rev_user) from revision_FAs) having recentness>0")

recentness_en=log10(results_en[,1])
recentness_de=log10(results_de[,1])
recentness_fr=log10(results_fr[,1])
recentness_pl=log10(results_pl[,1])
recentness_ja=log10(results_ja[,1])
recentness_nl=log10(results_nl[,1])
recentness_it=log10(results_it[,1])
recentness_pt=log10(results_pt[,1])
recentness_es=log10(results_es[,1])
recentness_sv=log10(results_sv[,1])

linedens_en=density(recentness_en)
linedens_de=density(recentness_de)
linedens_fr=density(recentness_fr)
linedens_pl=density(recentness_pl)
linedens_ja=density(recentness_ja)
linedens_nl=density(recentness_nl)
linedens_it=density(recentness_it)
linedens_pt=density(recentness_pt)
linedens_es=density(recentness_es)
linedens_sv=density(recentness_sv)

postscript("graphics/hist_recentness_LOG10DAYS_authors_FAs.eps")

    plot(linedens_en, col="gray", type="l",lty=1, lwd=1.5, ylim=c(0,max(c(linedens_pt$y, linedens_es$y, linedens_nl$y, linedens_de$y, linedens_en$y, linedens_fr$y, linedens_it$y, linedens_pl$y, linedens_ja$y, linedens_sv$y))), xlab="log10(recentness auth. in FAs (days))", ylab="prob. density", main="KDE recentness of authors in FAs")
lines(linedens_de, type="l",col="navy", lty=1, lwd=1.5)
lines(linedens_fr, type="l",col="green", lty=1, lwd=1.5)
lines(linedens_pl, type="l",col="black", lty=1, lwd=1.5)
lines(linedens_ja, type="l",col="red", lty=1, lwd=1.5)
lines(linedens_it, type="l",col="yellow", lty=1, lwd=1.5)
lines(linedens_nl, type="l",col="orange", lty=1, lwd=1.5)
lines(linedens_pt, type="l",col="khaki", lty=1, lwd=1.5)
lines(linedens_es, type="l",col="magenta", lty=1, lwd=1.5)
lines(linedens_sv, type="l",col="brown", lty=1, lwd=1.5)

legend(x="topleft", legend=c("enwiki","dewiki", "frwiki", "plwiki", "jawiki", "itwiki", "nlwiki", "ptwiki", "eswiki", "svwiki"), col=c("gray" ,"navy","green", "black", "red", "yellow", "orange", "khaki", "magenta", "brown"), lty=1, lwd=1.5)

dev.off()

##AUTHORS IN non-FAs

results_pt <- dbGetQuery(con_pt,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user not in (select distinct(rev_user) from revision_FAs) having recentness>0")
results_de <- dbGetQuery(con_de,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user not in (select distinct(rev_user) from revision_FAs) having recentness>0")
results_es <- dbGetQuery(con_es,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user not in (select distinct(rev_user) from revision_FAs) having recentness>0")
results_nl <- dbGetQuery(con_nl,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user not in (select distinct(rev_user) from revision_FAs) having recentness>0")
results_fr <- dbGetQuery(con_fr,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user not in (select distinct(rev_user) from revision_FAs) having recentness>0")
results_ja <- dbGetQuery(con_ja,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user not in (select distinct(rev_user) from revision_FAs) having recentness>0")
results_pl <- dbGetQuery(con_pl,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user not in (select distinct(rev_user) from revision_FAs) having recentness>0")
results_it <- dbGetQuery(con_it,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user not in (select distinct(rev_user) from revision_FAs) having recentness>0")
results_sv <- dbGetQuery(con_sv,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user not in (select distinct(rev_user) from revision_FAs) having recentness>0")
results_en <- dbGetQuery(con_en,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors where rev_user not in (select distinct(rev_user) from revision_FAs) having recentness>0")

recentness_en=log10(results_en[,1])
recentness_de=log10(results_de[,1])
recentness_fr=log10(results_fr[,1])
recentness_pl=log10(results_pl[,1])
recentness_ja=log10(results_ja[,1])
recentness_nl=log10(results_nl[,1])
recentness_it=log10(results_it[,1])
recentness_pt=log10(results_pt[,1])
recentness_es=log10(results_es[,1])
recentness_sv=log10(results_sv[,1])

linedens_en=density(recentness_en)
linedens_de=density(recentness_de)
linedens_fr=density(recentness_fr)
linedens_pl=density(recentness_pl)
linedens_ja=density(recentness_ja)
linedens_nl=density(recentness_nl)
linedens_it=density(recentness_it)
linedens_pt=density(recentness_pt)
linedens_es=density(recentness_es)
linedens_sv=density(recentness_sv)

postscript("graphics/hist_recentness_LOG10DAYS_authors_non-FAs.eps")

plot(linedens_en, col="gray", type="l",lty=1, lwd=1.5, ylim=c(0,max(c(linedens_pt$y, linedens_es$y, linedens_nl$y, linedens_de$y, linedens_en$y, linedens_fr$y, linedens_it$y, linedens_pl$y, linedens_ja$y, linedens_sv$y))), xlab="log10(recentness auth. in non-FAs (days))", ylab="prob. density", main="KDE recentness of authors in non-FAs")
lines(linedens_de, type="l",col="navy", lty=1, lwd=1.5)
lines(linedens_fr, type="l",col="green", lty=1, lwd=1.5)
lines(linedens_pl, type="l",col="black", lty=1, lwd=1.5)
lines(linedens_ja, type="l",col="red", lty=1, lwd=1.5)
lines(linedens_it, type="l",col="yellow", lty=1, lwd=1.5)
lines(linedens_nl, type="l",col="orange", lty=1, lwd=1.5)
lines(linedens_pt, type="l",col="khaki", lty=1, lwd=1.5)
lines(linedens_es, type="l",col="magenta", lty=1, lwd=1.5)
lines(linedens_sv, type="l",col="brown", lty=1, lwd=1.5)

legend(x="topleft", legend=c("enwiki","dewiki", "frwiki", "plwiki", "jawiki", "itwiki", "nlwiki", "ptwiki", "eswiki", "svwiki"), col=c("gray" ,"navy","green", "black", "red", "yellow", "orange", "khaki", "magenta", "brown"), lty=1, lwd=1.5)

dev.off()

##AUTHORS IN ALL ARTICLES

results_pt <- dbGetQuery(con_pt,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors having recentness>0")
results_de <- dbGetQuery(con_de,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors having recentness>0")
results_es <- dbGetQuery(con_es,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors having recentness>0")
results_nl <- dbGetQuery(con_nl,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors having recentness>0")
results_fr <- dbGetQuery(con_fr,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors having recentness>0")
results_ja <- dbGetQuery(con_ja,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors having recentness>0")
results_pl <- dbGetQuery(con_pl,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors having recentness>0")
results_it <- dbGetQuery(con_it,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors having recentness>0")
results_sv <- dbGetQuery(con_sv,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors having recentness>0")
results_en <- dbGetQuery(con_en,"SELECT TIMESTAMPDIFF(DAY, max_ts, '2008-01-01 00:00:00') as recentness FROM time_range_authors having recentness>0")

recentness_en=log10(results_en[,1])
recentness_de=log10(results_de[,1])
recentness_fr=log10(results_fr[,1])
recentness_pl=log10(results_pl[,1])
recentness_ja=log10(results_ja[,1])
recentness_nl=log10(results_nl[,1])
recentness_it=log10(results_it[,1])
recentness_pt=log10(results_pt[,1])
recentness_es=log10(results_es[,1])
recentness_sv=log10(results_sv[,1])

linedens_en=density(recentness_en)
linedens_de=density(recentness_de)
linedens_fr=density(recentness_fr)
linedens_pl=density(recentness_pl)
linedens_ja=density(recentness_ja)
linedens_nl=density(recentness_nl)
linedens_it=density(recentness_it)
linedens_pt=density(recentness_pt)
linedens_es=density(recentness_es)
linedens_sv=density(recentness_sv)

postscript("graphics/hist_recentness_LOG10DAYS_authors_all_arts.eps")

plot(linedens_en, col="gray", type="l",lty=1, lwd=1.5, ylim=c(0,max(c(linedens_pt$y, linedens_es$y, linedens_nl$y, linedens_de$y, linedens_en$y, linedens_fr$y, linedens_it$y, linedens_pl$y, linedens_ja$y, linedens_sv$y))), xlab="log10(recentness auth. in articles (days))", ylab="prob. density", main="KDE recentness of authors in all articles")
lines(linedens_de, type="l",col="navy", lty=1, lwd=1.5)
lines(linedens_fr, type="l",col="green", lty=1, lwd=1.5)
lines(linedens_pl, type="l",col="black", lty=1, lwd=1.5)
lines(linedens_ja, type="l",col="red", lty=1, lwd=1.5)
lines(linedens_it, type="l",col="yellow", lty=1, lwd=1.5)
lines(linedens_nl, type="l",col="orange", lty=1, lwd=1.5)
lines(linedens_pt, type="l",col="khaki", lty=1, lwd=1.5)
lines(linedens_es, type="l",col="magenta", lty=1, lwd=1.5)
lines(linedens_sv, type="l",col="brown", lty=1, lwd=1.5)

legend(x="topleft", legend=c("enwiki","dewiki", "frwiki", "plwiki", "jawiki", "itwiki", "nlwiki", "ptwiki", "eswiki", "svwiki"), col=c("gray" ,"navy","green", "black", "red", "yellow", "orange", "khaki", "magenta", "brown"), lty=1, lwd=1.5)

dev.off()

#Disconnect from the DB
dbDisconnect(con_pt)
dbDisconnect(con_es)
dbDisconnect(con_nl)
dbDisconnect(con_de)
dbDisconnect(con_fr)
dbDisconnect(con_ja)
dbDisconnect(con_pl)
dbDisconnect(con_it)
dbDisconnect(con_sv)
dbDisconnect(con_en)
