# -*- coding: utf-8 -*-
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
"""
"""

import os, string, dbaccess

class Process(object):
    """
    CREATE .dat FILES FOR OUR SURVIVAL SCRIPTS
    """
    def __init__(self, dbuser, dbpassw, languages):
        self.languages=languages
        self.dbuser=dbuser
        self.dbpassw=dbpassw
    
    def analyze(self):
        #Initialize all files headers
        #Survival data for all users (including editors out of MAIN)
        f=open("wkp_surv_all.dat",'w')
        f.write("Project,rev_user,min_ts,max_ts\n")
        f.close()
        #Survival data for all logged users who edited in MAIN
        f=open("wkp_surv_main_all.dat",'w')
        f.write("Project,rev_user,min_ts,max_ts\n")
        f.close()
        f=open("wkp_surv_join_core_all.dat",'w')
        f.write("Project,rev_user,min_ts,min_ts_core\n")
        f.close()
        f=open("wkp_surv_in_core_all.dat",'w')
        f.write("Project,rev_user,min_ts_core,max_ts_core\n")
        f.close()
        f=open("wkp_surv_core_to_max_ts_all.dat",'w')
        f.write("Project,rev_user,max_ts_core,max_ts\n")
        f.close()
        f=open("wkp_surv_join_core_rev_all.dat",'w')
        f.write("Project,rev_user,min_ts,min_ts_core\n")
        f.close()
        f=open("wkp_surv_in_core_rev_all.dat",'w')
        f.write("Project,rev_user,min_ts_core,max_ts_core\n")
        f.close()
        f=open("wkp_surv_core_rev_to_max_ts_all.dat",'w')
        f.write("Project,rev_user,max_ts_core,max_ts\n")
        f.close()
            
        for self.language in self.languages:
            self.dbname="wx_"+self.language+"wiki_research"
	    
            print "Starting language "+self.language+"\n"
            ##IN SYSTEM
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            results=dbaccess.raw_query_SQL(self.access[1],"SELECT rev_user, date(min_ts), date(max_ts) from time_range_authors "+\
            "where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot')")
            #Close DB connection
            dbaccess.close_Connection(self.access[0])
            
            f=open("wkp_surv_all.dat",'a')
            for result in results:
                f.write(self.language+","+str(int(result[0]))+",\""+str(result[1])+"\",\""+str(result[2])+"\""+"\n")
            f.close()

            ##IN MAIN
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            results=dbaccess.raw_query_SQL(self.access[1],"SELECT rev_user, date(min_ts), date(max_ts) from time_range_users ")
            #Close DB connection
            dbaccess.close_Connection(self.access[0])
            
            f=open("wkp_surv_main_all.dat",'a')
            for result in results:
                f.write(self.language+","+str(int(result[0]))+",\""+str(result[1])+"\",\""+str(result[2])+"\""+"\n")
            f.close()
            
            ##CORE
            ##JOIN CORE
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            results=dbaccess.raw_query_SQL(self.access[1],"SELECT rev_user, date(min_ts), date(min_ts_core) from users_core")
            #Close DB connection
            dbaccess.close_Connection(self.access[0])
            
            f=open("wkp_surv_join_core_all.dat",'a')
            for result in results:
                f.write(self.language+","+str(int(result[0]))+",\""+str(result[1])+"\",\""+str(result[2])+"\""+"\n")
            f.close()
            
            ##IN CORE
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            results=dbaccess.raw_query_SQL(self.access[1],"SELECT rev_user, date(min_ts_core), date(max_ts_core) from users_core")
            #Close DB connection
            dbaccess.close_Connection(self.access[0])
            
            f=open("wkp_surv_in_core_all.dat",'a')
            for result in results:
                f.write(self.language+","+str(int(result[0]))+",\""+str(result[1])+"\",\""+str(result[2])+"\""+"\n")
            f.close()
            
            ##CORE TO DEATH
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            results=dbaccess.raw_query_SQL(self.access[1],"SELECT rev_user, date(max_ts_core), date(max_ts) from users_core")
            #Close DB connection
            dbaccess.close_Connection(self.access[0])
            
            f=open("wkp_surv_core_to_max_ts_all.dat",'a')
            for result in results:
                f.write(self.language+","+str(int(result[0]))+",\""+str(result[1])+"\",\""+str(result[2])+"\""+"\n")
            f.close()
            
            print "Finished core users for language "+self.language+"\n"
            ###########################
            ##REV CORE
            ##JOIN CORE
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            results=dbaccess.raw_query_SQL(self.access[1],"SELECT rev_user, date(min_ts), date(min_ts_core) from users_rev_core")
            #Close DB connection
            dbaccess.close_Connection(self.access[0])
            
            f=open("wkp_surv_join_core_rev_all.dat",'a')
            for result in results:
                f.write(self.language+","+str(int(result[0]))+",\""+str(result[1])+"\",\""+str(result[2])+"\""+"\n")
            f.close()
            
            ##IN CORE
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            results=dbaccess.raw_query_SQL(self.access[1],"SELECT rev_user, date(min_ts_core), date(max_ts_core) from users_rev_core")
            #Close DB connection
            dbaccess.close_Connection(self.access[0])
            
            f=open("wkp_surv_in_core_rev_all.dat",'a')
            for result in results:
                f.write(self.language+","+str(int(result[0]))+",\""+str(result[1])+"\",\""+str(result[2])+"\""+"\n")
            f.close()
            
            ##CORE TO DEATH
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            results=dbaccess.raw_query_SQL(self.access[1],"SELECT rev_user, date(max_ts_core), date(max_ts) from users_rev_core")
            #Close DB connection
            dbaccess.close_Connection(self.access[0])
            
            f=open("wkp_surv_core_rev_to_max_ts_all.dat",'a')
            for result in results:
                f.write(self.language+","+str(int(result[0]))+",\""+str(result[1])+"\",\""+str(result[2])+"\""+"\n")
            f.close()
            
            print "Finished all tasks for "+self.language+"\n"

if __name__ == '__main__':
##  languages=["ar","bg", "br", "bs", "ca", "cs", "da", "el", "eo", "et", "eu", "fa", "fi", "fur", "gl", "he", "hr",\
##  "hu", "id", "is", "kk", "ko", "lb", "lt", "lv", "ms", "mt", "new","nn", "no", "ro", "sh", "simple",  "sk", "sl", "sr",\
##  "th", "tr", "uk", "vi", "vo"] 
##    languages=["zh", "sv", "es", "pt"] 1)
    languages=["sv","es","pt","it","nl","pl","ja","fr","de","en"]
    #languages=["es"]
    dbuser="root"; dbpassw="phoenix"
    process=Process(dbuser, dbpassw, languages)
    process.analyze()
    
