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

con_fr <- dbConnect(dbDriver("MySQL"),dbname="wx_frwiki_research",user="root",password="phoenix")

results_fr <- dbGetQuery(con_fr, "SELECT a.num_authors, b.rat_ab FROM (select rev_page, COUNT(DISTINCT(rev_user)) as num_authors FROM revision_articles GROUP BY rev_page) as a, rating_ab AS b WHERE a.rev_page=b.rev_page")

postscript("corr_num_authors_rating.eps")
plot(results_fr[,1], results_fr[,2], col="navy", xlab="#distinct authors per article", ylab="rat_ab(p)", main="Corr. between #distinct authors per article and rat_ab(p)", cex.lab=1.5, cex.main=1.5, cex.axis=1.5)

fit<-lm(results_fr[,2]~results_fr[,1])

abline(fit, col="orange")

legend(x="topleft", legend=paste("r=", signif(cor(results_fr[,1],results_fr[,2]),digits=4)), cex=1.5)
dev.off()

