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
    A simple class implementing our analyses for article on HICSS 42
    """
    def __init__(self, dbuser, dbpassw, languages):
        self.languages=languages
        self.dbuser=dbuser
        self.dbpassw=dbpassw
        
    def analyze(self):

        for self.language in self.languages:
            self.dbname="wx_"+self.language+"wiki_research"
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
	    
            print "Processing language "+self.language+"\n"
            #Create view for filtering annons and bots
            #Filter from rev_main_nored revisions from logged authors only
            dbaccess.raw_query_SQL(self.access[1],"create or replace view revision_logged as (select * from rev_main_nored "+\
            " where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot') )")
            dbaccess.raw_query_SQL(self.access[1],"drop table if exists time_range_users")
            #Intermediate table, storing for each logged author the min and max ts in the system
            dbaccess.raw_query_SQL(self.access[1],"create table time_range_users as (SELECT rev_user, "+\
            "min(rev_timestamp) min_ts, max(rev_timestamp) max_ts from revision_logged group by rev_user)")
            dbaccess.raw_query_SQL(self.access[1],"alter table time_range_users add primary key (rev_user)")
            
            print "Created time_range_users for "+self.language +"\n"
            
            #Obtain the list of years and months, with total num. of revisions and total num of logged users
            dbaccess.raw_query_SQL(self.access[1],"drop table if exists core_limits_monthly")
            dbaccess.raw_query_SQL(self.access[1],"create table core_limits_monthly as "+\
            "(select year(rev_timestamp) as year, month(rev_timestamp) as month, "+\
            "count(distinct(rev_user)) num_users, count(*) num_revs from revision_logged group by year, month "+\
            "order by year, month)")
            
            print "Created table core_limits_monthly "+self.language+"\n"
            
            date_range=dbaccess.raw_query_SQL(self.access[1],"select * from core_limits_monthly "+\
            "order by year, month")
            
            #Core users: top-10% of total number of authors in that month
            #Core users with top-10% of total number of revisions in that month
            
            #Loop for each month
            need_create=True
            #LOOP FOR EACH MONTH IN LANG
            for adate in date_range:
                print "Processing year "+str(adate[0])+" month "+str(adate[1])+"\n"
                total_users=adate[2] #Total number of authors in that month
                total_revs=adate[3] #Total number of revisions in that month
                # To take the core of top-10% most active authors in that month
                limit_auth=int(round(total_users*0.1))+1
                # To take the core of authors responsible for top-10% of tot num.revs in that month
                limit_revs=int(round(total_revs*0.1))
                count_users=0
                count_revs=0
                insert_users=True
                insert_revs=True
                    
                #Get the list of active logged users for that month (descendent order!)
                ##IMPORTANT NOTE: FIRST APPLY SUBQUERY TO FILTER ALL REVISIONS IN THIS MONTH
                ##THEN APPLY THE GROUP AND ORDER CLAUSES ON THAT SUBQUERY
                ##THIS WAY, WE SAVE **A LOT** OF TIME DURING THIS PREPROCESSING STAGE
                month_users=dbaccess.raw_query_SQL(self.access[1],"select rev_user, count(*) num_revs_month from "+\
                "(select rev_user, rev_timestamp from revision_logged where "+\
                "year(rev_timestamp)="+str(int(adate[0]))+" and month(rev_timestamp)="+str(int(adate[1]))+")x group by rev_user "+\
                "order by num_revs_month desc" )
                
                #Calculate num. of authors accumulating top-10% of revs in that month
                for auser in month_users:
                    count_revs=count_revs+int(auser[1])
                    count_users=count_users+1
                    if (count_revs>limit_revs):
                        break
                    
                if (need_create):
                        
                    dbaccess.raw_query_SQL(self.access[1],"drop table if exists users_core_monthly")
                    dbaccess.raw_query_SQL(self.access[1],"create table users_core_monthly as (select "+\
                    "rev_user, min(rev_timestamp) lower_ts_month, max(rev_timestamp) upper_ts_month, "+\
                    "count(*) as num_revs_month from (select rev_user, rev_timestamp from "+\
                    "revision_logged where year(rev_timestamp)="+str(int(adate[0]))+\
                    " and month(rev_timestamp)="+str(int(adate[1]))+")x group by rev_user "+\
                    "order by num_revs_month desc limit "+str(limit_auth)+")" )
                            
                    dbaccess.raw_query_SQL(self.access[1],"drop table if exists users_rev_core_monthly")
                    dbaccess.raw_query_SQL(self.access[1],"create table users_rev_core_monthly as (select "+\
                    "rev_user, min(rev_timestamp) lower_ts_month, max(rev_timestamp) upper_ts_month, "+\
                    "count(*) as num_revs_month from (select rev_user, rev_timestamp from "+\
                    "revision_logged where year(rev_timestamp)="+str(int(adate[0]))+\
                    " and month(rev_timestamp)="+str(int(adate[1]))+")x group by rev_user "+\
                    "order by num_revs_month desc limit "+str(count_users)+")" )
                            
                    print "Created tables monthly data for "+self.language+"\n"
                    need_create=False
                
                else:
                    dbaccess.raw_query_SQL(self.access[1],"insert into users_core_monthly (select "+\
                    "rev_user, min(rev_timestamp) lower_ts_month, max(rev_timestamp) upper_ts_month, "+\
                    "count(*) as num_revs_month from (select rev_user, rev_timestamp from "+\
                    "revision_logged where year(rev_timestamp)="+str(int(adate[0]))+\
                    " and month(rev_timestamp)="+str(int(adate[1]))+")x group by rev_user "+\
                    "order by num_revs_month desc limit "+str(limit_auth)+")" )
                        
                    dbaccess.raw_query_SQL(self.access[1],"insert into users_rev_core_monthly (select "+\
                    "rev_user, min(rev_timestamp) lower_ts_month, max(rev_timestamp) upper_ts_month, "+\
                    "count(*) as num_revs_month from (select rev_user, rev_timestamp from "+\
                    "revision_logged where year(rev_timestamp)="+str(int(adate[0]))+\
                    " and month(rev_timestamp)="+str(int(adate[1]))+")x group by rev_user "+\
                    "order by num_revs_month desc limit "+str(count_users)+")" )
                    
                print "Inserted monthly data for "+self.language+"\n"
                ####NOTE: WE ARE SUPPOSING THAT USERS DOES NOT LEAVE THE CORE SUBSEQUENTLY, TO COME BACK AGAIN, i.e.
                ####ONCE THEY JOIN THE CORE, WE ASSUME THAT THE DEFINITELY LEAVE IT AT max_ts_core
                ####BY THE MOMENT, WE WILL STICK TO THIS ASSUMPTION. LATER ON, WE CAN SEE HOW TO IDENTIFY BLANK PERIODS
                
            #Insert in table of core users values
            #users_core = top-10% most active authors in each month
            #users_rev_core = authors accumulating top-10% of tot. num. of revs. in that month
        
            print "Creating table users_core for "+ self.language+"\n"
            dbaccess.raw_query_SQL(self.access[1],"drop table if exists users_core")
            dbaccess.raw_query_SQL(self.access[1], "create table users_core as (select x.*, "+\
            "(select min_ts from time_range_users r where r.rev_user=x.rev_user) min_ts, (select max_ts from "+\
            "time_range_users s where s.rev_user=x.rev_user) max_ts "+\
            "from (select rev_user, min(lower_ts_month) min_ts_core, "+\
            "max(upper_ts_month) max_ts_core from users_core_monthly group by rev_user) x)")
            
            print "Creating table users_rev_core for "+ self.language+"\n"
            dbaccess.raw_query_SQL(self.access[1],"drop table if exists users_rev_core")
            dbaccess.raw_query_SQL(self.access[1], "create table users_rev_core as (select x.*, "+\
            "(select min_ts from time_range_users r where r.rev_user=x.rev_user) min_ts, (select max_ts from "+\
            "time_range_users s where s.rev_user=x.rev_user) max_ts "+\
            "from (select rev_user, min(lower_ts_month) min_ts_core, "+\
            "max(upper_ts_month) max_ts_core from users_rev_core_monthly group by rev_user) x)")
            
            print "All work finished for"+ self.language+"\n"
                
                    
                #Close DB connection
                dbaccess.close_Connection(self.access[0])

if __name__ == '__main__':
##  languages=["ar","bg", "br", "bs", "ca", "cs", "da", "el", "eo", "et", "eu", "fa", "fi", "fur", "gl", "he", "hr",\
##  "hu", "id", "is", "kk", "ko", "lb", "lt", "lv", "ms", "mt", "new","nn", "no", "ro", "sh", "simple",  "sk", "sl", "sr",\
##  "th", "tr", "uk", "vi", "vo"] 
##    languages=["zh", "sv", "es", "pt"] 1)
	
    ##########UNCOMMENT THE FOLLOWING LINE TO RUN
    languages=["sv","es","pt","it","nl","pl","ja","fr","de","en"]
    ##########UNCOMMENT THE FOLLOWING LINE TO TEST
    #languages=["fr"]
    dbuser="root"; dbpassw="phoenix"
    process=Process(dbuser, dbpassw, languages)
    process.analyze()
    
