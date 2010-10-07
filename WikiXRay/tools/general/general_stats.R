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

library("lattice")
langs=c("ru","es","pt","it","nl","pl","ja","fr","de","en")

dfpage=read.table("data/page_len.dat", header=T)
dfpage_main=subset(dfpage, ns==0)
dfpage_talk=subset(dfpage, ns==1)
dfpage_de=subset(dfpage, lang=="de")
dfpage_en=subset(dfpage, lang=="en")
dfpage_ja=subset(dfpage, lang=="ja")


postscript("graphics/page_len_by_nspace_dewiki.eps")
densityplot(~ log10(page_len) | factor(ns, labels=c("Media","Main","Talk","User","User_talk","Wikipedia","Wkp_talk","Image","Image_talk","Mediawiki","Medw_talk","Template","Temp_talk","Help","Help_talk", "Category","Cat_talk","Portal", "Portal_t")), data=dfpage_de, plot.points=F, ref=T, main="Comaprison of log10(page_len) by nspace (dewiki)")
# print(tf1)
dev.off()

postscript("graphics/page_len_by_nspace_enwiki.eps")
densityplot(~ log10(page_len) | factor(ns, labels=c("Media","Main","Talk","User","User_talk","Wikipedia","Wkp_talk","Image","Image_talk","Mediawiki","Medw_talk","Template","Temp_talk","Help","Help_talk", "Category","Cat_talk","Portal", "Portal_t")), data=dfpage_en, plot.points=F, ref=T, main="Comaprison of log10(page_len) by nspace (enwiki)")
dev.off()

postscript("graphics/page_len_by_nspace_jawiki.eps")
densityplot(~ log10(page_len) | factor(ns, labels=c("Media","Main","Talk","User","User_talk","Wikipedia","Wkp_talk","Image","Image_talk","Mediawiki","Medw_talk","Template","Temp_talk","Help","Help_talk", "Category","Cat_talk","Portal", "Portal_t")), data=dfpage_ja, plot.points=F, ref=T, main="Comaprison of log10(page_len) by nspace (jawiki)")
dev.off()

postscript("graphics/page_len_articles_by_lang.eps")
densityplot(~ log10(page_len) | factor(lang, levels=langs), data=dfpage_main, plot.point=F, ref=T, main="Comaprison of log10(page_len) by language version")
dev.off()

postscript("graphics/page_len_talk_by_lang.eps")
densityplot(~ log10(page_len) | factor(lang, levels=langs), data=dfpage_talk, plot.point=F, ref=T, main="Comaprison of log10(page_len) by language version")
dev.off()