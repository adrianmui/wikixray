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


# Obtain the hazard function h(t) for logged users in a certain language edition
# of Wikipedia

# Call RMySQL library to connect to DB
# Call survival library for calculations and modelling
library(RMySQL)
# library(survival)
library(muhaz)

langs=c("en","de","fr","ja","pl","nl","it","pt","es","sv")
colors=c(1,2,3,4,5,6,"gray10","olivedrab","orange","brown")

###CALCULATE h(t) for 1)time in system 2)time in core

##TIME IN SYSTEM
wkp_logged=read.csv2("wkp_surv_all.dat", header=T, sep=",")
#Order factor of lang. versions descending
wkp_logged$Project=factor(wkp_logged$Project, levels=langs)

# Tranform dates to Date R format
wkp_logged<-transform(wkp_logged, min_ts=as.Date(min_ts, "%Y-%m-%d"), max_ts=as.Date(max_ts, "%Y-%m-%d"))

# Create censoring column and censoring boolean indicator
# Censoring date : 2009-5-1
wkp_logged<-transform(wkp_logged, end = pmin(max_ts, as.Date("2009-5-1"), na.rm=T),
dead = !is.na(max_ts) & max_ts<as.Date("2009-5-1"))

# Create column with obstime
wkp_logged<- transform(wkp_logged, obstime = as.numeric(end-min_ts, units = "days"))

#Filter out authors with obstime==0
wkp_logged=subset(wkp_logged, obstime>0)

postscript("graphics/hazard-all.eps", horizontal=T)
first=T
for (lang in langs) {
	i=which(langs==lang)
	#bw.method=global, same bw for all grid points
        target=subset(wkp_logged, Project==lang)
	haz_logged=with(target, muhaz(obstime, dead, min.time=1,
        max.time=sort(target$obstime, dec=T)[10],bw.method="l"))
        sink(paste("traces/summary-hazard-",lang,".txt",sep=""))
        print(summary(haz_logged))
        sink()
	if (first) {
		plot(haz_logged,
                main="H(t) logged authors", col=colors[i])
		first=F
	}
	else {
		lines(haz_logged,col=colors[i])
	}
}
legend("topright", legend=langs, lty=1, col=colors)
dev.off()

postscript("graphics/hazard-log-all.eps", horizontal=T)
first=T
for (lang in langs) {
	i=which(langs==lang)
	#bw.method=global, same bw for all grid points
        target=subset(wkp_logged, Project==lang)
	haz_logged=with(target, muhaz(obstime, dead, min.time=1,
        max.time=sort(target$obstime, dec=T)[10],bw.method="l"))
	if (first) {
		plot(haz_logged, log="x",
                main="H(t) logged authors", col=colors[i])
		first=F
	}
	else {
		lines(haz_logged, log="x",col=colors[i])
	}
}
legend("topright", legend=langs, lty=1, col=colors)
dev.off()

for (lang in langs) {
	i=which(langs==lang)
	#bw.method=global, same bw for all grid points
        target=subset(wkp_logged, Project==lang)
	haz_logged=with(target, muhaz(obstime, dead, min.time=1,
        max.time=sort(target$obstime, dec=T)[10],bw.method="l"))
        postscript(paste("graphics/hazard-log-",lang,".eps",sep=""), horizontal=T)
        plot(haz_logged, log="x",
        main="H(t) logged authors", col=colors[i])
        dev.off()
}

##Free some memory
rm(wkp_logged)

##TIME IN CORE

wkp_logged=read.csv2("wkp_surv_in_core_all.dat", header=T, sep=",")
#Order factor of lang. versions descending
wkp_logged$Project=factor(wkp_logged$Project, levels=langs)

# Tranform dates to Date R format
wkp_logged<-transform(wkp_logged, min_ts_core=as.Date(min_ts_core, "%Y-%m-%d"), max_ts_core=as.Date(max_ts_core, "%Y-%m-%d"))

# Create censoring column and censoring boolean indicator
# Censoring date : 2009-5-1
wkp_logged<-transform(wkp_logged, end = pmin(max_ts_core, as.Date("2009-5-1"), na.rm=T),
dead = !is.na(max_ts_core) & max_ts_core<as.Date("2009-5-1"))

# Create column with obstime
wkp_logged<- transform(wkp_logged, obstime = as.numeric(end-min_ts_core, units = "days"))

wkp_logged=subset(wkp_logged, obstime>0)

postscript("graphics/hazard-core-all.eps", horizontal=T)
first=T
for (lang in langs) {
	i=which(langs==lang)
	#bw.method=global, same bw for all grid points
	target=subset(wkp_logged, Project==lang)
	haz_logged=with(target, muhaz(obstime, dead, min.time=1,
        max.time=sort(target$obstime, dec=T)[10],bw.method="l"))
        sink(paste("traces/summary-hazard-core-",lang,".txt",sep=""))
        print(summary(haz_logged))
        sink()
	if (first) {
		plot(haz_logged, main="H(t) authors in core", col=colors[i])
		first=F
	}
	else {
		lines(haz_logged, col=colors[i])
	}
}
legend("topright", legend=langs, lty=1, col=colors)
dev.off()

postscript("graphics/hazard-log-core-all.eps", horizontal=T)
first=T
for (lang in langs) {
	i=which(langs==lang)
	#bw.method=global, same bw for all grid points
	target=subset(wkp_logged, Project==lang)
	haz_logged=with(target, muhaz(obstime, dead, min.time=1,
        max.time=sort(target$obstime, dec=T)[10],bw.method="l"))
	if (first) {
		plot(haz_logged, log="x",main="H(t) authors in core", col=colors[i])
		first=F
	}
	else {
		lines(haz_logged, log="x",col=colors[i])
	}
}
legend("topright", legend=langs, lty=1, col=colors)
dev.off()


first=T
for (lang in langs) {
	i=which(langs==lang)
	#bw.method=global, same bw for all grid points
	target=subset(wkp_logged, Project==lang)
	haz_logged=with(target, muhaz(obstime, dead, min.time=1,
        max.time=sort(target$obstime, dec=T)[10],bw.method="l"))
        postscript(paste("graphics/hazard-log-core-",lang,".eps",sep=""), horizontal=T)
        plot(haz_logged, log="x",main="H(t) authors in core", col=colors[i])
        dev.off()
}

##Free some memory
rm(wkp_logged)

###########
wkp_logged=read.csv2("wkp_surv_in_core_rev_all.dat", header=T, sep=",")
#Order factor of lang. versions descending
wkp_logged$Project=factor(wkp_logged$Project, levels=langs)

# Tranform dates to Date R format
wkp_logged<-transform(wkp_logged, min_ts_core=as.Date(min_ts_core, "%Y-%m-%d"), max_ts_core=as.Date(max_ts_core, "%Y-%m-%d"))

# Create censoring column and censoring boolean indicator
# Censoring date : 2009-5-1
wkp_logged<-transform(wkp_logged, end = pmin(max_ts_core, as.Date("2009-5-1"), na.rm=T),
dead = !is.na(max_ts_core) & max_ts_core<as.Date("2009-5-1"))

# Create column with obstime
wkp_logged<- transform(wkp_logged, obstime = as.numeric(end-min_ts_core, units = "days"))

wkp_logged=subset(wkp_logged, obstime>0)

postscript("graphics/hazard-core-rev-all.eps", horizontal=T)
first=T
for (lang in langs) {
	i=which(langs==lang)
	#bw.method=global, same bw for all grid points
	target=subset(wkp_logged, Project==lang)
	haz_logged=with(target, muhaz(obstime, dead, min.time=1,
        max.time=sort(target$obstime, dec=T)[10],bw.method="l"))
        sink(paste("traces/summary-hazard-core-rev-",lang,".txt",sep=""))
        print(summary(haz_logged))
        sink()
	if (first) {
		plot(haz_logged, main="H(t) authors in core (by revs.)", col=colors[i])
		first=F
	}
	else {
		lines(haz_logged, col=colors[i])
	}
}
legend("topright", legend=langs, lty=1, col=colors)
dev.off()

postscript("graphics/hazard-log-core-rev-all.eps", horizontal=T)
first=T
for (lang in langs) {
	i=which(langs==lang)
	#bw.method=global, same bw for all grid points
	target=subset(wkp_logged, Project==lang)
	haz_logged=with(target, muhaz(obstime, dead, min.time=1,
        max.time=sort(target$obstime, dec=T)[10],bw.method="l"))
	if (first) {
		plot(haz_logged, log="x",main="H(t) authors in core (by revs.)", col=colors[i])
		first=F
	}
	else {
		lines(haz_logged, log="x",col=colors[i])
	}
}
legend("topright", legend=langs, lty=1, col=colors)
dev.off()

first=T
for (lang in langs) {
	i=which(langs==lang)
	#bw.method=global, same bw for all grid points
	target=subset(wkp_logged, Project==lang)
	haz_logged=with(target, muhaz(obstime, dead, min.time=1,
        max.time=sort(target$obstime, dec=T)[10],bw.method="l"))
        postscript(paste("graphics/hazard-log-core-rev-all-",lang,".eps", sep=""), horizontal=T)
        plot(haz_logged, log="x",main="H(t) authors in core (by revs.)", col=colors[i])
        dev.off()
}

##Free some memory
rm(wkp_logged)
