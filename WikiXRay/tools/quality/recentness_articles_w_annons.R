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

#mysql> CREATE OR REPLACE VIEW time_max_articles AS select rev_user, rev_timestamp from revision where rev_id IN (select page_latest FROM page where page_namespace=0);

#mysql> CREATE OR REPLACE VIEW time_max_FAs AS select rev_user, rev_timestamp from revision where rev_id IN (select page_latest FROM page where page_id IN (SELECT page_id from page_FAs));

#mysql> CREATE OR REPLACE VIEW time_max_non_FAs AS select rev_user, rev_timestamp from revision where rev_id IN (select page_latest FROM page where page_namespace=0 and page_id NOT IN (SELECT page_id from page_FAs));

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


results_pt <- dbGetQuery(con_pt,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_FAs WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot') HAVING recentness >0")

results_de <- dbGetQuery(con_de,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot') HAVING recentness >0")

results_es <- dbGetQuery(con_es,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot') HAVING recentness >0")

results_nl <- dbGetQuery(con_nl,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot') HAVING recentness >0")

results_fr <- dbGetQuery(con_fr,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot') HAVING recentness >0")

results_ja <- dbGetQuery(con_ja,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot') HAVING recentness >0")

results_pl <- dbGetQuery(con_pl,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot') HAVING recentness >0")

results_it <- dbGetQuery(con_it,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot') HAVING recentness >0")

results_sv <- dbGetQuery(con_sv,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot') HAVING recentness >0")

results_en <- dbGetQuery(con_en,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

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

postscript("hist_recentness_LOG10DAYS_FAs.eps")

plot(linedens_en, col="gray", type="b",lty=1, lwd=1, ylim=c(0,max(c(linedens_pt$y, linedens_es$y, linedens_nl$y, linedens_de$y, linedens_en$y, linedens_fr$y, linedens_it$y, linedens_pl$y, linedens_ja$y, linedens_sv$y))), xlab="log10(age of authors in FAs (days))", ylab="prob. density", main="Hist. and KDE of recentness of FAs (top-ten lang. eds.)", pch=1)
lines(linedens_de, type="b",col="navy", lty=1, lwd=1, pch=2)
lines(linedens_fr, type="b",col="green", lty=1, lwd=1, pch=3)
lines(linedens_pl, type="b",col="black", lty=1, lwd=1, pch=4)
lines(linedens_ja, type="b",col="red", lty=1, lwd=1, pch=5)
lines(linedens_it, type="b",col="yellow", lty=1, lwd=1, pch=6)
lines(linedens_nl, type="b",col="orange", lty=1, lwd=1, pch=7)
lines(linedens_pt, type="b",col="khaki", lty=1, lwd=1, pch=8)
lines(linedens_es, type="b",col="magenta", lty=1, lwd=1, pch=9)
lines(linedens_sv, type="b",col="brown", lty=1, lwd=1, pch=10)

legend(x="topleft", legend=c("enwiki","dewiki", "frwiki", "plwiki", "jawiki", "itwiki", "nlwiki", "ptwiki", "eswiki", "svwiki"), col=c("gray" ,"navy","green", "black", "red", "yellow", "orange", "khaki", "magenta", "brown"), lty=1, pch=c(1,2,3,4,5,6,7,8,9,10))

dev.off()

#######################################

results_pt <- dbGetQuery(con_pt,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_non_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')   HAVING recentness >0")

results_de <- dbGetQuery(con_de,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_non_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

results_es <- dbGetQuery(con_es,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_non_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

results_nl <- dbGetQuery(con_nl,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_non_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

results_fr <- dbGetQuery(con_fr,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_non_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

results_ja <- dbGetQuery(con_ja,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_non_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

results_it <- dbGetQuery(con_it,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_non_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

results_pl <- dbGetQuery(con_pl,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_non_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

results_sv <- dbGetQuery(con_sv,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_non_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

results_en <- dbGetQuery(con_en,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_non_FAs as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

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

postscript("hist_recentness_LOG10DAYS_non-FAs.eps")

plot(linedens_en, col="gray", type="b",lty=1, lwd=1, ylim=c(0,max(c(linedens_pt$y, linedens_es$y, linedens_nl$y, linedens_de$y, linedens_en$y, linedens_fr$y, linedens_it$y, linedens_pl$y, linedens_ja$y, linedens_sv$y))), xlab="log10(age of authors in articles (days))", ylab="prob. density", main="Hist. and KDE of recentness of non-FAs (top-ten lang. ed.)", pch=1)
lines(linedens_de, type="b",col="navy", lty=1, lwd=1, pch=2)
lines(linedens_fr, type="b",col="green", lty=1, lwd=1, pch=3)
lines(linedens_pl, type="b",col="black", lty=1, lwd=1, pch=4)
lines(linedens_ja, type="b",col="red", lty=1, lwd=1, pch=5)
lines(linedens_it, type="b",col="yellow", lty=1, lwd=1, pch=6)
lines(linedens_nl, type="b",col="orange", lty=1, lwd=1, pch=7)
lines(linedens_pt, type="b",col="khaki", lty=1, lwd=1, pch=8)
lines(linedens_es, type="b",col="magenta", lty=1, lwd=1, pch=9)
lines(linedens_sv, type="b",col="brown", lty=1, lwd=1, pch=10)

legend(x="topleft", legend=c("enwiki","dewiki", "frwiki", "plwiki", "jawiki", "itwiki", "nlwiki", "ptwiki", "eswiki", "svwiki"), col=c("gray" ,"navy","green", "black", "red", "yellow", "orange", "khaki", "magenta", "brown"), lty=1, pch=c(1,2,3,4,5,6,7,8,9,10))

dev.off()

#######################################

#######################################

results_pt <- dbGetQuery(con_pt,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_articles as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

results_de <- dbGetQuery(con_de,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_articles as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

results_es <- dbGetQuery(con_es,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_articles as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

results_nl <- dbGetQuery(con_nl,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_articles as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

results_fr <- dbGetQuery(con_fr,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_articles as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

results_ja <- dbGetQuery(con_ja,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_articles as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

results_it <- dbGetQuery(con_it,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_articles as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

results_pl <- dbGetQuery(con_pl,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_articles as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

results_sv <- dbGetQuery(con_sv,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_articles as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

results_en <- dbGetQuery(con_en,"SELECT TIMESTAMPDIFF(DAY, a.rev_timestamp, b.max_global_ts) as recentness FROM time_max_articles as a, (SELECT MAX(rev_timestamp) AS max_global_ts FROM revision) as b WHERE rev_user!=0  AND rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group='bot')  HAVING recentness >0")

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

postscript("hist_recentness_LOG10DAYS_articles.eps")

plot(linedens_en, col="gray", type="b",lty=1, lwd=1, ylim=c(0,max(c(linedens_pt$y, linedens_es$y, linedens_nl$y, linedens_de$y, linedens_en$y, linedens_fr$y, linedens_it$y, linedens_pl$y, linedens_ja$y, linedens_sv$y))), xlab="log10(age of authors in articles (days))", ylab="prob. density", main="Hist. and KDE of recentness of articles (top-ten lang. ed.)", pch=1)
lines(linedens_de, type="b",col="navy", lty=1, lwd=1, pch=2)
lines(linedens_fr, type="b",col="green", lty=1, lwd=1, pch=3)
lines(linedens_pl, type="b",col="black", lty=1, lwd=1, pch=4)
lines(linedens_ja, type="b",col="red", lty=1, lwd=1, pch=5)
lines(linedens_it, type="b",col="yellow", lty=1, lwd=1, pch=6)
lines(linedens_nl, type="b",col="orange", lty=1, lwd=1, pch=7)
lines(linedens_pt, type="b",col="khaki", lty=1, lwd=1, pch=8)
lines(linedens_es, type="b",col="magenta", lty=1, lwd=1, pch=9)
lines(linedens_sv, type="b",col="brown", lty=1, lwd=1, pch=10)

legend(x="topleft", legend=c("enwiki","dewiki", "frwiki", "plwiki", "jawiki", "itwiki", "nlwiki", "ptwiki", "eswiki", "svwiki"), col=c("gray" ,"navy","green", "black", "red", "yellow", "orange", "khaki", "magenta", "brown"), lty=1, pch=c(1,2,3,4,5,6,7,8,9,10))

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
