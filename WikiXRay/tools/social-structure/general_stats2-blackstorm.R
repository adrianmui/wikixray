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

con <- dbConnect(dbDriver("MySQL"),dbname="wx_eswiki_research",user="root",password="phoenix")

users_pages=dbGetQuery(con,"select pages, count(distinct(rev_user)) as num_users from (SELECT rev_user, COUNT(DISTINCT rev_page) as pages from (select rev_id, rev_user, rev_page from revision_articles where rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user) x group by pages order by pages")

pages_per_user=dbGetQuery(con,"SELECT rev_user, COUNT(DISTINCT rev_page) as pages from (select rev_id, rev_user, rev_page from revision_articles where rev_user not in (select ug_user from user_groups where ug_group='bot'))y GROUP BY rev_user")

postscript("graphics/users_per_page.eps")
with(users_pages, plot(pages, num_users, type="p", col="grey", log="xy"))
dev.off()

postscript("graphics/ranked_users_by_num_distinct_pages.eps")
pages_per_user_ranked=rev(sort(pages_per_user$pages))
ranking=c(1:length(pages_per_user_ranked))
plot(ranking, pages_per_user_ranked, type="p", main="ranked users by their #distinct pages revised", xlab="rank", ylab="num_distinct_pages_revised", log="xy")
fit=lm(log10(pages_per_user_ranked)~log10(c(1:length(pages_per_user_ranked))))
abline(fit, col=red)
text(8000,9000, paste("slope b=", round(fit$coefficients[2],4)))
dev.off()

postscript("graphics/CECDF_num_distinct_pags_per_user.eps")
# pags=pages_per_user$pages[pages_per_user$pages<5000]
# cecdf_fit=fitdistr(pags, dpareto, start=list(m=1,s=1.01), lower=1.01)
# fit_m=cecdf_fit$estimate[1]
# fit_s=cecdf_fit$estimate[2]
# sd_m=cecdf_fit$sd[1]
# sd_s=cecdf_fit$sd[2]
# fit_loglik=cecdf_fit$loglik

# Ecdf(pages_per_user$pages, "1-F", log="xy", xlab="x=num pages", main="Fit of Pareto CCDF to distinct pages revised per user")
Ecdf(pages_per_user$pages, "1-F", log="xy", xlab="x=num pages", main="Fit of Pareto CCDF to distinct pages revised per user")
# Ecdf(rpareto(100000, fit_m, fit_s), "1-F", add=T,log="xy", col="red")
# text(70,0.1, paste("m=",round(fit_m,3),"(sd(m)=", round(sd_m,3),")"))
# text(70,0.05, paste("s=",round(fit_s,3),"(sd(s)=", round(sd_s,3), ")"))
# text(70,0.03, paste("loglik=", round(fit_loglik,3)))

dev.off()

#Close DB connection
dbDisconnect(con)

#######################
##LA VERSION BUENA CON EL PAPER DE LA TESIS DE ISRA
#######################

##CARGAR pareto.R antes de continuar
#source("pareto.R")
postscript("num_authors_w_equal_num_dif_arts_edited.eps")
plot.survival.loglog(users_pages$num_users)
plot.survival.loglog(rpareto(10000, 0.5,1.656449), lty=2, add=T, col="red")
text(500,0.5, paste("Pareto fit"))
text(500,0.35, paste("xmin~0.5"))
text(500,0.15, paste("shape(a.k.a. exponent)~1.572577"))
dev.off()

###NOTA: HAY QUE HACER IDEM PARA LOS DEMAS IDIOMAS, METER EN SCRIPT
