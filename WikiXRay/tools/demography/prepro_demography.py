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
This module is aimed to execute some SQL statements creating tables
and views, as well as .dat files needed in the execution of subsequent 
scripts

Prior to the execution of this module, the required activity data must
have been retrieved and loaded into a local MySQL database.

@see: quantAnalay_main, dbdump, dbanaly

@authors: Jose Felipe Ortega
@organization: GSyC/Libresoft, Universidad Rey Juan Carlos
@copyright:    Felipe Ortega @ Libresoft, URJC (Madrid, Spain)
@license:      GNU GPL version 2 or any later version
@contact:      jfelipe@libresoft.es
"""

import dbaccess

class Prepro_demography(object):
    """
    The main class executing the SQL statements and creating .dat files

    #FILE tags creation of .dat files
    #VIEW tags creation of MySQL DB views
    #TABLE or #TABLES tags creation of MySQL DB tables
    """
    def __init__(self, dbuser, dbpassw, languages):
        self.languages=languages
        self.dbuser=dbuser
        self.dbpassw=dbpassw

    def trigger(self):
        """
        Function that executes individual sets of scripts in this class
        """
        self.time_range()
        self.core_prepro()
        self.surv_files()
        #self.cox_prop()

    #######################
    ### ACTUAL FUNCTIONS
    #######################

    def time_range(self):
        """
        Creates intermediate tables with time frame of editors activity
        """
        for self.language in self.languages:
            self.dbname="wx_"+self.language+"wiki_research"
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            
            ##### TIME RANGE FOR AUTHORS IN ALL NAMESPACES
            #TABLE: Total no. of revisions made by every logged author
            dbaccess.raw_query_SQL(self.access[1],"CREATE TABLE IF NOT EXISTS user_revs AS "+\
            "SELECT rev_user, count(*) num_revs from revision WHERE rev_user!=0 AND "+\
            "rev_user not in (SELECT ug_user FROM user_groups WHERE ug_group='bot') GROUP BY rev_user")
            dbaccess.raw_query_SQL(self.access[1],"ALTER TABLE user_revs ADD PRIMARY KEY (rev_user)")
            
            print "Created table user_revs for "+self.language+"wiki...\n"
            
            #TABLE: Min and max timestamp for every logged author + total num_revs
            dbaccess.raw_query_SQL(self.access[1],"CREATE TABLE IF NOT EXISTS time_range_authors AS "+\
            "(SELECT x.*, (select num_revs from user_revs d where d.rev_user=x.rev_user) num_revs FROM "+\
            "(SELECT rev_user, min(rev_timestamp) min_ts, max(rev_timestamp) max_ts from revision group by rev_user) x "+\
            "ORDER BY min_ts)")
            
            print "Created table time_range_authors for "+self.language+"wiki...\n"
            
            ##### TIME RANGE FOR AUTHORS IN MAIN ONLY
                print "Processing language "+self.language+"\n"
            #VIEW: Create view for filtering annons and bots
            #Filter from rev_main_nored revisions from logged authors only
            dbaccess.raw_query_SQL(self.access[1],"create or replace view revision_logged as (select * from rev_main_nored "+\
            " where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot') )")
            dbaccess.raw_query_SQL(self.access[1],"drop table if exists time_range_users")
            #TABLE: Intermediate table, storing for each logged author the min and max ts in the system
            dbaccess.raw_query_SQL(self.access[1],"create table time_range_users as (SELECT rev_user, "+\
            "min(rev_timestamp) min_ts, max(rev_timestamp) max_ts from revision_logged group by rev_user)")
            dbaccess.raw_query_SQL(self.access[1],"alter table time_range_users add primary key (rev_user)")
            
            print "Created time_range_users for "+self.language +"\n"

            #Close DB connection
            dbaccess.close_Connection(self.access[0])

    def core_prepro(self):
        """
        Creates intermediate tables with info about core members (by activity
        and by top % of total number of revisions
        """
        for self.language in self.languages:
            self.dbname="wx_"+self.language+"wiki_research"
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)

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
                    #TABLE: Monthly info for users in core (by activity)
                    dbaccess.raw_query_SQL(self.access[1],"drop table if exists users_core_monthly")
                    dbaccess.raw_query_SQL(self.access[1],"create table users_core_monthly as (select "+\
                    "rev_user, min(rev_timestamp) lower_ts_month, max(rev_timestamp) upper_ts_month, "+\
                    "count(*) as num_revs_month from (select rev_user, rev_timestamp from "+\
                    "revision_logged where year(rev_timestamp)="+str(int(adate[0]))+\
                    " and month(rev_timestamp)="+str(int(adate[1]))+")x group by rev_user "+\
                    "order by num_revs_month desc limit "+str(limit_auth)+")" )
                    
                    #TABLE: Monthly info for users in core (by revisions)
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
                    #Insert info in table with monthly info for users in core (by activity)
                    dbaccess.raw_query_SQL(self.access[1],"insert into users_core_monthly (select "+\
                    "rev_user, min(rev_timestamp) lower_ts_month, max(rev_timestamp) upper_ts_month, "+\
                    "count(*) as num_revs_month from (select rev_user, rev_timestamp from "+\
                    "revision_logged where year(rev_timestamp)="+str(int(adate[0]))+\
                    " and month(rev_timestamp)="+str(int(adate[1]))+")x group by rev_user "+\
                    "order by num_revs_month desc limit "+str(limit_auth)+")" )
                    
                    #Insert info in table with monthly info for users in core (by revisions)
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
            
            #TABLE: Users in core by activity (user, min_ts, max_ts, min_ts_core, max_ts_core)
            print "Creating table users_core for "+ self.language+"\n"
            dbaccess.raw_query_SQL(self.access[1],"drop table if exists users_core")
            dbaccess.raw_query_SQL(self.access[1], "create table users_core as (select x.*, "+\
            "(select min_ts from time_range_users r where r.rev_user=x.rev_user) min_ts, (select max_ts from "+\
            "time_range_users s where s.rev_user=x.rev_user) max_ts "+\
            "from (select rev_user, min(lower_ts_month) min_ts_core, "+\
            "max(upper_ts_month) max_ts_core from users_core_monthly group by rev_user) x)")
            
            #TABLE: Users in core by activity (user, min_ts, max_ts, min_ts_core, max_ts_core)
            print "Creating table users_rev_core for "+ self.language+"\n"
            dbaccess.raw_query_SQL(self.access[1],"drop table if exists users_rev_core")
            dbaccess.raw_query_SQL(self.access[1], "create table users_rev_core as (select x.*, "+\
            "(select min_ts from time_range_users r where r.rev_user=x.rev_user) min_ts, (select max_ts from "+\
            "time_range_users s where s.rev_user=x.rev_user) max_ts "+\
            "from (select rev_user, min(lower_ts_month) min_ts_core, "+\
            "max(upper_ts_month) max_ts_core from users_rev_core_monthly group by rev_user) x)")
            
            print "All core_prepro tasks finished for"+ self.language+"\n"

            #Close DB connection
            dbaccess.close_Connection(self.access[0])

    def surv_files(self):
        """
        Creates all data files used as input for demography scripts in GNU R
        """
        #Initialize all files headers
        #FILE: Survival data for all users (including editors out of MAIN)
        f=open("wkp_surv_all.dat",'w')
        f.write("Project,rev_user,min_ts,max_ts\n")
        f.close()
        #FILE: Survival data for all logged users who edited in MAIN
        f=open("wkp_surv_main_all.dat",'w')
        f.write("Project,rev_user,min_ts,max_ts\n")
        f.close()
        #FILE: Survival data for all logged editors until they join the core (activity)
        f=open("wkp_surv_join_core_all.dat",'w')
        f.write("Project,rev_user,min_ts,min_ts_core\n")
        f.close()
        #FILE: Survival data for logged editors since they join the core until they leave it (activity)
        f=open("wkp_surv_in_core_all.dat",'w')
        f.write("Project,rev_user,min_ts_core,max_ts_core\n")
        f.close()
        #FILE: Survival data for loged editors since they leave the core until death (activity)
        f=open("wkp_surv_core_to_max_ts_all.dat",'w')
        f.write("Project,rev_user,max_ts_core,max_ts\n")
        f.close()
        #FILE: Survival data for all logged editors until they join the core (revisions)
        f=open("wkp_surv_join_core_rev_all.dat",'w')
        f.write("Project,rev_user,min_ts,min_ts_core\n")
        f.close()
        #FILE: Survival data for logged editors since they join the core until they leave it (revisions)
        f=open("wkp_surv_in_core_rev_all.dat",'w')
        f.write("Project,rev_user,min_ts_core,max_ts_core\n")
        f.close()
        #FILE: Survival data for loged editors since they leave the core until death (revisions)
        f=open("wkp_surv_core_rev_to_max_ts_all.dat",'w')
        f.write("Project,rev_user,max_ts_core,max_ts\n")
        f.close()
            
        for self.language in self.languages:
            self.dbname="wx_"+self.language+"wiki_research"
        
            print "Starting language "+self.language+"\n"
            ##IN SYSTEM
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            results=dbaccess.raw_query_SQL(self.access[1],"SELECT rev_user, date(min_ts), date(max_ts) from time_range_authors "+\
            " where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot')")
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
            
            print "Finished core users by activity for language "+self.language+"\n"

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
            
            print "Finished all surv_file tasks for "+self.language+"\n"
    
    def cox_prop(self):
        """
        Creates intermediate files and tables for Cox-prop hazards analysis
        """
        #Initialize file header
        f=open("wkp_cox_prop_all.dat",'w')
        f.write("Project,rev_user,min_ts,max_ts,in_talk,in_FAs\n")
        f.close()
        
        for self.language in self.languages:
            self.dbname="wx_"+self.language+"wiki_research"
        
            print "Starting language "+self.language+"\n"
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            
            ##TABLE: Create table of users in talk pages
            dbaccess.raw_query_SQL(self.access[1],"drop table if exists users_in_talk")
            dbaccess.raw_query_SQL(self.access[1],"create table users_in_talk as (select distinct(rev_user) from revision "+\
            "where rev_page in (select page_id from page where page_namespace=1))")
            dbaccess.raw_query_SQL(self.access[1],"alter table users_in_talk add primary key (rev_user)")
            
            ##TABLE: Create table of users in FAs
            dbaccess.raw_query_SQL(self.access[1],"drop table if exists users_in_FAs")
            dbaccess.raw_query_SQL(self.access[1],"create table users_in_FAs as (select distinct(rev_user) from revision_FAs)")
            dbaccess.raw_query_SQL(self.access[1],"alter table users_in_FAs add primary key (rev_user)")
            
            ##TABLE: MIX previous info with time_range_authors --> save result in new table time_range_cox
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
            print "Finished all cox-prop tasks for "+self.language+"\n"
        
#############
##   MAIN
#############
if __name__ == '__main__':
    #languages=["ar","bg", "br", "bs", "ca", "cs", "da", "el", "eo", "et", "eu", "fa", "fi", "fur", "gl", "he", "hr",\
    #"hu", "id", "is", "kk", "ko", "lb", "lt", "lv", "ms", "mt", "new","nn", "no", "ro", "sh", "simple",  "sk", "sl", "sr",\
    #"th", "tr", "uk", "vi", "vo","zh", "sv", "es","pt","it", "nl","pl","ja","fr","de","en"]  
    languages=["sv","ru", "es","pt","it", "nl","pl","ja","fr","de"] ##EN
    dbuser="root"; dbpassw="phoenix"
    process=Prepro_overall(dbuser, dbpassw, languages)
    process.trigger()
        