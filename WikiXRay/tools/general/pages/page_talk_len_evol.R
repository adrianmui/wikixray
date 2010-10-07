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
	
	for (ayear in years) {
		# Get results for evolution of page_len in this language
		page_len_ayear=dbGetQuery(con,
		paste("select rev_id, rev_len from rev_talk where rev_id in (select max_id from 
		max_rev_talk_",ayear,")", sep=""))
		page_len_ayear=transform(page_len_ayear, year=ayear)
		page_len_ayear=transform(page_len_ayear, lang=alang)
		page_len_tot=merge(page_len_tot, page_len_ayear, all=T)
	}
	dbDisconnect(con)
}
page_len_tot$year=factor(page_len_tot$year)
page_len_tot$lang=factor(page_len_tot$lang, langs)

# Draw yearly evolution of page length by language with lattice

postscript("./graphics/page-talk-len-evol.eps", horizontal=F)
tpagelen=densityplot(~ log10(rev_len) | lang, data= page_len_tot, groups=year, xlab="log10(page length) (bytes)", ylab="Prob. density",
plot.points=F,auto.key=list(title="year"))
plot(tpagelen)
dev.off()

##############################################

## create table max_rev_YYYY as (select max(rev_id) as max_id, rev_page from revision where year(rev_timestamp)<2003 group by rev_page);
## alter table max_rev_YYYY add primary key (max_id);
## select rev_id, rev_page, rev_len from revision where rev_id in (select max_id from max_rev_YYYY);