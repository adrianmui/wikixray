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
library(lattice)

langs=c("sv","es","pt","nl","it","pl","ja","fr","de","en")
years=c(2003,2004,2005,2006,2007,2008)
page_len_tot=data.frame(rev_id=numeric(0), rev_len=numeric(0), year=numeric(0), lang=character(0))
for (alang in langs) {
	# Get DB connection
	con=dbConnect(MySQL(), user="root", password="phoenix", dbname=paste("wx_",alang,"wiki_research", sep=""))
	
	# Get results for number of pages in each nspace by lang
	page_ns_alang=dbGetQuery(con,"select page_namespace, count(distinct(page_id)) pages from page group by page_namespace")
	page_ns_alang=transform(page_ns_alang, lang=alang)
	page_ns_tot=merge(page_len_tot, page_len_ayear, all=T)
	dbDisconnect(con)
}
page_ns_tot$lang=factor(page_ns_tot$lang, langs)

# Draw stack graph of number of pages in each namespace, by langugae.

postscript("./graphics/page-ns-stack.eps", horizontal=F)
tpagens=barchart(prop.table(pages, margin=1), xlab="Porportion of tot. num. pages", auto.key=list(adj=1))
plot(tpagens)
dev.off()
save(tpagens, file="tpagens")

##############################################

## create table max_rev_YYYY as (select max(rev_id) as max_id, rev_page from revision where year(rev_timestamp)<2003 group by rev_page);
## alter table max_rev_YYYY add primary key (max_id);
## select rev_id, rev_page, rev_len from revision where rev_id in (select max_id from max_rev_YYYY);