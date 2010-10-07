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
# of Wikipedia

# Call RMySQL library to connect to DB
# Call survival library for calculations and modelling
# library(RMySQL)
library(survival)

# langs=c("sv","es","pt","it","nl","pl","ja","fr","de","en")
# langs=c("sv")
langs=c("en","de","fr","ja","pl","nl","it","pt","es","sv")
colors=c(1,2,3,4,5,6,"gray10","olivedrab","orange","brown")

###FROM: FIRST EDIT IN THAT LANGUAGE VERSION
###EVENT: LAST EDIT IN THAT LANGUAGE VERSION
postscript("graphics/KM-all.eps", horizontal=T)
#par(mfrow=c(5,2))

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

# Create survival object
wkp_logged=subset(wkp_logged, obstime>0)
wkp_logged_surv=with(wkp_logged, Surv(obstime, dead))

# Obtain survival function S(t) via Kaplan-Meier estimates
wlsfit=with(wkp_logged, survfit(wkp_logged_surv~Project))

sink("traces/table-KM-all.txt")
print(wlsfit, show.rmean=T)
sink()

# Plot S(t) (note that in certain editions, e.g. eswiki, the confident intervals are so closed to the curve
# that they're virtually invisible
plot(wlsfit, xlab="days", ylab="S(t)", col=colors,main="S(t) for logged authors", cex=1.4,
cex.axis=1.5, cex.lab=1.5, cex.main=1.6)
legend("topright", legend=langs, lty=1, col=colors, cex=1.5)
dev.off()

#Zoom to appreciate confident intervals curves{
wkp_logged=subset(wkp_logged, Project=="eswiki")
c=with(wkp_logged, Surv(obstime, dead))
wlsfit=survfit(wkp_logged_surv)	
postscript("graphics/kaplan-meier_wiki_zoom.eps")
plot(wlsfit, xlab="days", ylab="S(t)", main="Zoom in S(t) logged authors (eswiki)", 
xlim=c(200,320), ylim=c(0.35,0.42))
dev.off()
##Free some memory
rm(wkp_logged)
rm(wkp_logged_surv)
rm(wlsfit)


#############
##CORE USERS
#############

###FROM: FIRST EDIT IN THAT LANG VERSION
###EVENT: FIRST EDIT AS A CORE MEMBER
postscript("graphics/KM-join-core-all.eps", horizontal=T)

wkp_logged=read.csv2("wkp_surv_join_core_all.dat", header=T, sep=",")

#Order factor of lang. versions descending
wkp_logged$Project=factor(wkp_logged$Project, levels=langs)

# Tranform dates to Date R format
wkp_logged<-transform(wkp_logged, min_ts=as.Date(min_ts, "%Y-%m-%d"), min_ts_core=as.Date(min_ts_core, "%Y-%m-%d"))

# Create censoring column and censoring boolean indicator
# Censoring date : 2009-5-1
wkp_logged<-transform(wkp_logged, end = pmin(min_ts_core, as.Date("2009-5-1"), na.rm=T),
dead = !is.na(min_ts_core) & min_ts_core<as.Date("2009-5-1"))

# Create column with obstime
wkp_logged<- transform(wkp_logged, obstime = as.numeric(end-min_ts, units = "days"))

# Create survival object
wkp_logged=subset(wkp_logged, obstime>0)
wkp_logged_surv=with(wkp_logged, Surv(obstime, dead))

# Obtain survival function S(t) via Kaplan-Meier estimates
wlsfit=with(wkp_logged, survfit(wkp_logged_surv~Project))

sink("traces/table-KM-join-core-all.txt")
print(wlsfit, show.rmean=T)
sink()

# Plot S(t) (note that in certain editions, e.g. eswiki, the confident intervals are so closed to the curve
# that they're virtually invisible
plot(wlsfit, xlab="days", ylab="S(t)", col=colors,main="S(t) logged auth. to join core", cex=1.4,
cex.axis=1.5, cex.lab=1.5, cex.main=1.6)
legend("topright", legend=langs, lty=1, col=colors, cex=1.5)

dev.off()
##Free some memory
rm(wkp_logged)
rm(wkp_logged_surv)
rm(wlsfit)

##FROM: FIRST EDIT AS A CORE MEMBER
##EVENT: LAST EDIT AS A CORE MEMBER
postscript("graphics/KM-in-core-all.eps", horizontal=T)

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

# Create survival object
wkp_logged=subset(wkp_logged, obstime>0)
wkp_logged_surv=with(wkp_logged, Surv(obstime, dead))

# Obtain survival function S(t) via Kaplan-Meier estimates
wlsfit=with(wkp_logged, survfit(wkp_logged_surv~Project))

sink("traces/table-KM-in-core-all.txt")
print(wlsfit, show.rmean=T)
sink()

# Plot S(t) (note that in certain editions, e.g. eswiki, the confident intervals are so closed to the curve
# that they're virtually invisible
plot(wlsfit, xlab="days", ylab="S(t)", col=colors,main="S(t) S(t) logged auth. in core", cex=1.4,
cex.axis=1.5, cex.lab=1.5, cex.main=1.6)
legend("topright", legend=langs, lty=1, col=colors, cex=1.5)

dev.off()
##Free some memory
rm(wkp_logged)
rm(wkp_logged_surv)
rm(wlsfit)

##FROM: LAST EDIT AS A CORE MEMBER
##EVENT: LAST EDIT IN THAT LANG VERSION
postscript("graphics/KM-core-to-max_ts-all.eps", horizontal=T)

wkp_logged=read.csv2("wkp_surv_core_to_max_ts_all.dat", header=T, sep=",")

#Order factor of lang. versions descending
wkp_logged$Project=factor(wkp_logged$Project, levels=langs)

# Tranform dates to Date R format
wkp_logged<-transform(wkp_logged, max_ts_core=as.Date(max_ts_core, "%Y-%m-%d"), max_ts=as.Date(max_ts, "%Y-%m-%d"))

# Create censoring column and censoring boolean indicator
# Censoring date : 2009-5-1
wkp_logged<-transform(wkp_logged, end = pmin(max_ts, as.Date("2009-5-1"), na.rm=T),
dead = !is.na(max_ts) & max_ts<as.Date("2009-5-1"))

# Create column with obstime
wkp_logged<- transform(wkp_logged, obstime = as.numeric(end-max_ts_core, units = "days"))

# Create survival object
wkp_logged=subset(wkp_logged, obstime>0)
wkp_logged_surv=with(wkp_logged, Surv(obstime, dead))

# Obtain survival function S(t) via Kaplan-Meier estimates
wlsfit=with(wkp_logged, survfit(wkp_logged_surv~Project))

sink("traces/table-KM-core-to-max_ts-all.txt")
print(wlsfit, show.rmean=T)
sink()

# Plot S(t) (note that in certain editions, e.g. eswiki, the confident intervals are so closed to the curve
# that they're virtually invisible
plot(wlsfit, xlab="days", ylab="S(t)", col=colors,main="S(t) log. auth. core to max_ts", cex=1.4,
cex.axis=1.5, cex.lab=1.5, cex.main=1.6)
legend("topright", legend=langs, lty=1, col=colors, cex=1.5)

dev.off()
##Free some memory
rm(wkp_logged)
rm(wkp_logged_surv)
rm(wlsfit)

#############
##CORE REV USERS
#############

###FROM: FIRST EDIT IN THAT LANG VERSION
###EVENT: FIRST EDIT AS A CORE MEMBER
postscript("graphics/KM-join-core-rev-all.eps", horizontal=T)

wkp_logged=read.csv2("wkp_surv_join_core_rev_all.dat", header=T, sep=",")

#Order factor of lang. versions descending
wkp_logged$Project=factor(wkp_logged$Project, levels=langs)

# Tranform dates to Date R format
wkp_logged<-transform(wkp_logged, min_ts=as.Date(min_ts, "%Y-%m-%d"), min_ts_core=as.Date(min_ts_core, "%Y-%m-%d"))

# Create censoring column and censoring boolean indicator
# Censoring date : 2009-5-1
wkp_logged<-transform(wkp_logged, end = pmin(min_ts_core, as.Date("2009-5-1"), na.rm=T),
dead = !is.na(min_ts_core) & min_ts_core<as.Date("2009-5-1"))

# Create column with obstime
wkp_logged<- transform(wkp_logged, obstime = as.numeric(end-min_ts, units = "days"))

# Create survival object
wkp_logged=subset(wkp_logged, obstime>0)
wkp_logged_surv=with(wkp_logged, Surv(obstime, dead))

# Obtain survival function S(t) via Kaplan-Meier estimates
wlsfit=with(wkp_logged, survfit(wkp_logged_surv~Project))

sink("traces/table-KM-join-core-rev-all.txt")
print(wlsfit, show.rmean=T)
sink()

# Plot S(t) (note that in certain editions, e.g. eswiki, the confident intervals are so closed to the curve
# that they're virtually invisible
plot(wlsfit, xlab="days", ylab="S(t)", col=colors,main="S(t) logged auth. to join core", cex=1.4,
cex.axis=1.5, cex.lab=1.5, cex.main=1.6)
legend("topright", legend=langs, lty=1, col=colors, cex=1.5)

dev.off()
##Free some memory
rm(wkp_logged)
rm(wkp_logged_surv)
rm(wlsfit)

##FROM: FIRST EDIT AS A CORE MEMBER
##EVENT: LAST EDIT AS A CORE MEMBER
postscript("graphics/KM-in-core-rev-all.eps", horizontal=T)

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

# Create survival object
wkp_logged=subset(wkp_logged, obstime>0)
wkp_logged_surv=with(wkp_logged, Surv(obstime, dead))

# Obtain survival function S(t) via Kaplan-Meier estimates
wlsfit=with(wkp_logged, survfit(wkp_logged_surv~Project))

sink("traces/table-KM-in-core-rev-all.txt")
print(wlsfit, show.rmean=T)
sink()

# Plot S(t) (note that in certain editions, e.g. eswiki, the confident intervals are so closed to the curve
# that they're virtually invisible
plot(wlsfit, xlab="days", ylab="S(t)", col=colors,main="S(t) logged auth. in core", cex=1.4,
cex.axis=1.5, cex.lab=1.5, cex.main=1.6)
legend("topright", legend=langs, lty=1, col=colors, cex=1.5)

dev.off()
##Free some memory
rm(wkp_logged)
rm(wkp_logged_surv)
rm(wlsfit)

##FROM: LAST EDIT AS A CORE MEMBER
##EVENT: LAST EDIT IN THAT LANG VERSION
postscript("graphics/KM-core-rev-to-max_ts-all.eps", horizontal=T)

wkp_logged=read.csv2("wkp_surv_core_rev_to_max_ts_all.dat", header=T, sep=",")

#Order factor of lang. versions descending
wkp_logged$Project=factor(wkp_logged$Project, levels=langs)

# Tranform dates to Date R format
wkp_logged<-transform(wkp_logged, max_ts_core=as.Date(max_ts_core, "%Y-%m-%d"), max_ts=as.Date(max_ts, "%Y-%m-%d"))

# Create censoring column and censoring boolean indicator
# Censoring date : 2009-5-1
wkp_logged<-transform(wkp_logged, end = pmin(max_ts, as.Date("2009-5-1"), na.rm=T),
dead = !is.na(max_ts) & max_ts<as.Date("2009-5-1"))

# Create column with obstime
wkp_logged<- transform(wkp_logged, obstime = as.numeric(end-max_ts_core, units = "days"))

# Create survival object
wkp_logged=subset(wkp_logged, obstime>0)
wkp_logged_surv=with(wkp_logged, Surv(obstime, dead))

# Obtain survival function S(t) via Kaplan-Meier estimates
wlsfit=with(wkp_logged, survfit(wkp_logged_surv~Project))

sink("traces/table-KM-core-rev-to-max_ts-all.txt")
print(wlsfit, show.rmean=T)
sink()

# Plot S(t) (note that in certain editions, e.g. eswiki, the confident intervals are so closed to the curve
# that they're virtually invisible
plot(wlsfit, xlab="days", ylab="S(t)", col=colors,main="S(t) log. auth. core to max_ts", cex=1.4,
cex.axis=1.5, cex.lab=1.5, cex.main=1.6)
legend("topright", legend=langs, lty=1, col=colors, cex=1.5)

dev.off()
##Free some memory
rm(wkp_logged)
rm(wkp_logged_surv)
rm(wlsfit)

##############################
# END
##############################


