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


# Obtain the survival function S(t) for logged users in a certain language edition
# Depending on distinct covariates usin Cox proportional hazards model
# of Wikipedia

# Selected covariates are:
# Edited in FA
# Edited in Talk Pages

# Call RMySQL library to connect to DB
# Call survival library for calculations and modelling
library(RMySQL)
library(survival)

langs=c("en","de","fr","ja","pl","nl","it","pt","es","sv")
colors=c(1,2,3,4)

#ONLY FOR STANDARD USERS IN THE SYSTEM
wkp_logged=read.csv2("wkp_cox_prop_all.dat", header=T, sep=",")

wkp_logged$Project=factor(wkp_logged$Project, levels=langs)

# Tranform dates to Date R format
wkp_logged<-transform(wkp_logged, min_ts=as.Date(min_ts, "%Y-%m-%d"), max_ts=as.Date(max_ts, "%Y-%m-%d"))

# Create censoring column and censoring boolean indicator
# Censoring date : 2009-5-1
wkp_logged<-transform(wkp_logged, end = pmin(max_ts, as.Date("2009-5-1"), na.rm=T),
dead = !is.na(max_ts) & max_ts<as.Date("2009-5-1"))

# Create column with obstime
wkp_logged<- transform(wkp_logged, obstime = as.numeric(end-min_ts, units = "days"))

wkp_logged=subset(wkp_logged, obstime>0)
wkp_logged$in_talk=factor(wkp_logged$in_talk, labels=c("in-talk","not-in-talk"))
wkp_logged$in_FAs=factor(wkp_logged$in_FAs, labels=c("in-FAs","not-in-FAs"))

postscript(paste("graphics/cox-prop-hazard-all.eps"), horizontal=F)
par(mfrow=c(5,2))
for (lang in langs) {
	i=which(langs==lang)
    target=subset(wkp_logged, Project==lang)
    survival=with(target, Surv(obstime, dead))
    cox_fit=with(target, survfit(coxph(survival~in_talk+in_FAs)))

    sink(paste("traces/cox_summary",lang,".txt",sep=""))
	print(summary(coxph(survival~in_talk+in_FAs, data=target)))
    sink()

    new=data.frame(in_talk=c(0,1,0,1), in_FAs=c(0,0,1,1))
    cox_fit=with(target, survfit(coxph(survival~in_talk+in_FAs), newdata=new))
	plot(cox_fit, main=paste("H(t) logged authors (",lang,"wiki)",sep=""), col=colors)
}
dev.off()
##Free some memory
rm(wkp_logged)