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
    CREATE .dat FILES FOR COX proportional hazard model script
    """
    def __init__(self, dbuser, dbpassw, languages):
        self.languages=languages
        self.dbuser=dbuser
        self.dbpassw=dbpassw
        
    def analyze(self):
        #Initialize file header
        f=open("wkp_cox_prop_all.dat",'w')
        f.write("Project,rev_user,min_ts,max_ts,in_talk,in_FAs\n")
        f.close()
        
        for self.language in self.languages:
            self.dbname="wx_"+self.language+"wiki_research"
	    
            print "Starting language "+self.language+"\n"
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            ##Create table of users in talk pages
            
            dbaccess.raw_query_SQL(self.access[1],"drop table if exists users_in_talk")
            dbaccess.raw_query_SQL(self.access[1],"create table users_in_talk as (select distinct(rev_user) from revision "+\
            "where rev_page in (select page_id from page where page_namespace=1))")
            dbaccess.raw_query_SQL(self.access[1],"alter table users_in_talk add primary key (rev_user)")
            
            ##Create table of users in FAs
            dbaccess.raw_query_SQL(self.access[1],"drop table if exists users_in_FAs")
            dbaccess.raw_query_SQL(self.access[1],"create table users_in_FAs as (select distinct(rev_user) from revision_FAs)")
            dbaccess.raw_query_SQL(self.access[1],"alter table users_in_FAs add primary key (rev_user)")
            
            ##MIX previous info with time_range_authors --> save result in new table time_range_cox
            dbaccess.raw_query_SQL(self.access[1],"drop table if exists time_range_cox")
            dbaccess.raw_query_SQL(self.access[1],"create table time_range_cox as (select rev_user, "+\
            "date(min_ts) as min_ts, date(max_ts) as max_ts, "+\
            "case when rev_user in (select rev_user from users_in_talk) then 1 else 0 end as in_talk, "+\
            "case when rev_user in (select rev_user from users_in_FAs) then 1 else 0 end as in_FAs "+\
            "from time_range_authors)")
	    
            ##IN SYSTEM
            print "Interm. tables created proceeding to write out data..."+self.language+"\n"
            results=dbaccess.raw_query_SQL(self.access[1],"SELECT rev_user, min_ts, max_ts, in_talk, in_FAs "+\
            "from time_range_cox "+\
            " where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot')")
            #Close DB connection
            dbaccess.close_Connection(self.access[0])
	    
            f=open("wkp_cox_prop_all.dat",'a')
            for result in results:
                f.write(self.language+","+str(int(result[0]))+",\""+str(result[1])+"\",\""+str(result[2])+"\","+\
                str(int(result[3]))+","+str(int(result[4]))+"\n")
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
    
