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


###PLOT some graphs for summary data

resume_all=read.table("traces/table-KM-all.txt", header=T)

dresume_all_rm=density(resume_all$rmean)
dresume_all_m=density(resume_all$median)

postscript("graphics/KDE-rmean-median-all.eps")
plot(dresume_all_rm, lty=1, col="red", xlab="time (days)", ylab="Prob. density",
main="KDE of restricted mean and median surv. time", cex=1.4, cex.axis=1.5, cex.lab=1.5,
cex.main=1.6, xlim=c(0,500), ylim=c(0,max(dresume_all_m$y)), lwd=2)
lines(dresume_all_m, lty=2, col="navy", lwd=2)
legend("topright", legend=c("rmean","median"), lty=c(1,2), col=c("red","navy"))
dev.off()

###################
###################
resume_join=read.table("traces/table-KM-join-core-all.txt", header=T)
resume_in=read.table("traces/table-KM-in-core-all.txt", header=T)
# resume_tomax=read.table("traces/table-KM-core-to-max_ts-all.txt", header=T)

dresume_join=density(resume_join$rmean)
dresume_in=density(resume_in$rmean)
# dresume_tomax=density(resume_tomax$rmean)

postscript("graphics/KDE-rmean-core-all.eps")
plot(dresume_join, lty=1, col="red", xlab="time (days)", ylab="Prob. density",
main="KDE of restricted mean surv. time", cex=1.4, cex.axis=1.5, cex.lab=1.5,
cex.main=1.6, xlim=c(0,1000), lwd=2)
lines(dresume_in, lty=2, col="navy", lwd=2)
# lines(dresume_tomax, lty=3, col="brown")
legend("topright", legend=c("to-core","in-core"), lty=c(1,2), col=c("red","navy"))

dresume_join=density(resume_join$median)
dresume_in=density(resume_in$median)
# dresume_tomax=density(resume_tomax$median)

postscript("graphics/KDE-median-core-all.eps")
plot(dresume_join, lty=1, col="red", xlab="time (days)", ylab="Prob. density",
main="KDE of median surv. time", cex=1.4, cex.axis=1.5, cex.lab=1.5,
cex.main=1.6, xlim=c(0,140), lwd=2)
lines(dresume_in, lty=2, col="navy", lwd=2)
# lines(dresume_tomax, lty=3, col="brown")
legend("topright", legend=c("to-core","in-core"), lty=c(1,2), col=c("red","navy"))

####################
####################
resume_rev_join=read.table("traces/table-KM-join-core-rev-all.txt", header=T)
resume_rev_in=read.table("traces/table-KM-in-core-rev-all.txt", header=T)
resume_rev_tomax=read.table("traces/table-KM-core-rev-to-max_ts-all.txt", header=T)

dresume_rev_join=density(resume_rev_join$rmean)
dresume_rev_in=density(resume_rev_in$rmean)
# dresume_rev_tomax=density(resume_rev_tomax$rmean)

postscript("graphics/KDE-rmean-core-rev-all.eps")
plot(dresume_rev_join, lty=1, col="red", xlab="time (days)", ylab="Prob. density",
main="KDE of restricted mean surv. time", cex=1.4, cex.axis=1.5, cex.lab=1.5,
cex.main=1.6, xlim=c(0,450), lwd=2)
lines(dresume_rev_in, lty=2, col="navy", lwd=2)
# lines(dresume_rev_tomax, lty=3, col="brown")
legend("topright", legend=c("to-core","in-core"), lty=c(1,2), col=c("red","navy"))

dresume_rev_join=density(resume_rev_join$median)
dresume_rev_in=density(resume_rev_in$median)
# dresume_rev_tomax=density(resume_rev_tomax$median)

postscript("graphics/KDE-median-core-rev-all.eps")
plot(dresume_rev_join, lty=1, col="red", xlab="time (days)", ylab="Prob. density",
main="KDE of median surv. time", cex=1.4, cex.axis=1.5, cex.lab=1.5,
cex.main=1.6, xlim=c(0,390), ylim=c(0,max(dresume_rev_in$y)), lwd=2)
lines(dresume_rev_in, lty=2, col="navy", lwd=2)
# lines(dresume_rev_tomax, lty=3, col="brown")
legend("topright", legend=c("to-core","in-core"), lty=c(1,2), col=c("red","navy"))