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

"""

import dbaccess

class Prepro_overall(object):
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
        self.general_stats()
        self.prepro_pagelen()
        self.prepro_red_talk()
        self.ratios()
        self.bots()

    def general_stats(self):
        """
        Preprocessing actions for general statistics scripts
        """
        #FILE page_len.dat, with info about length of pages
        self.f=open("overall/data/page_len.dat", 'w')
        self.f.write("page_len\tns\tis_redirect\tis_stub\tis_new\tlang\n")
        self.f.close()
        for self.language in self.languages:
            self.dbname="wx_"+self.language+"wiki_research" 
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            print "Retrieving info from "+self.language+"\n"
            results=dbaccess.raw_query_SQL(self.access[1], "SELECT page_len, page_namespace, page_is_redirect, page_is_stub, "+\
            "page_is_new FROM page")
            print "Updating page_len info file with "+self.language+"\n"
                
            self.f=open("overall/data/page_len.dat", 'a')
            for result in results:
                self.f.write(str(int(result[0]))+"\t"+str(int(result[1]))+"\t"+str(int(result[2]))+"\t"+\
                str(int(result[3]))+"\t"+str(int(result[4]))+"\t"+self.language+"\n")
            self.f.close()
            results=None
            dbaccess.close_Connection(self.access[0])
        
    def prepro_pagelen(self):
        """
        Preprocessing tables for evolution of page length over time
        """
        for self.language in self.languages:
            self.dbname="wx_"+self.language+"wiki_research"   
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            
            #VIEW page_main_nored (pages in main nspace excluding redirects)
            dbaccess.raw_query_SQL(self.access[1], "create or replace view page_main_nored as "+\
            "(select page_id from page where page_namespace=0 and page_is_redirect=0)")

            #VIEW rev_main_nored (revisions in main nspace in all pages, excluding redirects)
            dbaccess.raw_query_SQL(self.access[1], "create or replace view rev_main_nored as ("+\
            "select rev_id, rev_user, rev_page, rev_timestamp, rev_len from revision where rev_page in "+\
            "(select page_id from page_main_nored))")
            
            #TABLES max_rev_YYYY (latest revision for each page in main nspace, up to year YYYY)
            self.minyear=dbaccess.raw_query_SQL(self.access[1],"select min(year(rev_timestamp)) from revision")
            self.years=range(int(self.minyear[0][0])+1, 2009)
            for self.year in self.years:
                dbaccess.raw_query_SQL(self.access[1],"drop table if exists max_rev_"+str(self.year))
                dbaccess.raw_query_SQL(self.access[1],"create table max_rev_"+str(self.year)+\
                " as (select max(rev_id) as max_id, rev_page from rev_main_nored "+\
                "where year(rev_timestamp)<"+str(self.year)+" group by rev_page)")
                dbaccess.raw_query_SQL(self.access[1], "alter table max_rev_"+str(self.year)+" add primary key (max_id)")
                dbaccess.raw_query_SQL(self.access[1], "alter table max_rev_"+str(self.year)+" add index (rev_page)")
                
            dbaccess.close_Connection(self.access[0])
        
    def prepro_red_talk(self):
        """
        Data and evolution for redirects and talk pages
        """
        for self.language in self.languages:
            self.dbname="wx_"+self.language+"wiki_research" 
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)

            #VIEW page_redirect (pages with redirect flag activated)
            dbaccess.raw_query_SQL(self.access[1], "create or replace view page_redirect as "+\
            "(select page_id from page where page_namespace=0 and page_is_redirect=1)")

            #VIEW rev_redirect (revisions corresponding to redirect pages)
            dbaccess.raw_query_SQL(self.access[1], "create or replace view rev_redirect as ("+\
            "select rev_id, rev_user, rev_page, rev_timestamp, rev_len from revision where rev_page in "+\
            "(select page_id from page_redirect))")

            #VIEW page_talk (pages in talk nspace)
            dbaccess.raw_query_SQL(self.access[1], "create or replace view page_talk as "+\
            "(select page_id from page where page_namespace=1)")

            #VIEW rev_talk (revisions corresponding to talk pages)
            dbaccess.raw_query_SQL(self.access[1], "create or replace view rev_talk as ("+\
            "select rev_id, rev_user, rev_page, rev_timestamp, rev_len from revision where rev_page in "+\
            "(select page_id from page_talk))")

            #TABLES max_rev_talk_YYYY (latest revision for each pages in talk nspace, in year YYYY)
            self.minyear=dbaccess.raw_query_SQL(self.access[1],"select min(year(rev_timestamp)) from revision")
            self.years=range(int(self.minyear[0][0])+1, 2009)
            for self.year in self.years:
                dbaccess.raw_query_SQL(self.access[1],"drop table if exists max_rev_talk_"+str(self.year))
                dbaccess.raw_query_SQL(self.access[1],"create table max_rev_talk_"+str(self.year)+\
                " as (select max(rev_id) as max_id, rev_page from rev_talk "+\
                "where year(rev_timestamp)<"+str(self.year)+" group by rev_page)")
                dbaccess.raw_query_SQL(self.access[1], "alter table max_rev_talk_"+str(self.year)+" add primary key (max_id)")
                dbaccess.raw_query_SQL(self.access[1], "alter table max_rev_talk_"+str(self.year)+" add index (rev_page)")
                
            dbaccess.close_Connection(self.access[0])
        
    def ratios(self):
        """
        .dat files showing interesting descriptive ratios
        """
        #FILE author-pages.dat ratio no. logged editors/no. user pages
        file=open("overall/data/editors-userpages.dat",'w')
        file.write("logged_authors\tuser_pages\tratio\tlang\n")
        file.close()
        for self.language in self.languages:
            self.dbname="wx_"+self.language+"wiki_research" 
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            #Obtain number of different logged authors
            self.logged_authors=dbaccess.raw_query_SQL(self.access[1], "select count(distinct(rev_user)) from "+\
            "revision where rev_user!=0")
            #Obtain number of different user pages (nspace =2)
            self.user_pages=dbaccess.raw_query_SQL(self.access[1], "select count(distinct(page_id)) from "+\
            "page where page_namespace=2")
            dbaccess.close_Connection(self.access[0])
            #Writing data to file
            file=open("overall/data/author-pages.dat",'a')
            file.write(str(int(self.logged_authors[0][0]))+"\t"+str(int(self.user_pages[0][0]))+"\t"+\
            str(float(self.user_pages[0][0])/float(self.logged_authors[0][0]))+"\t"+self.language+"\n")
            file.close()
            #print "Completed lang "+self.language+"\n"
    
        #FILE articles-talk-ratio.dat ratio of no. articles/no. talk pages (excluding redirects)
        file=open("overall/data/articles-talk-ratio.dat",'w')
        file.write("articles\ttalk\tratio\tlang\n")
        file.close()
        for self.language in self.languages:
            self.dbname="wx_"+self.language+"wiki_research" 
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            #Obtain number of articles excluding redirects
            self.articles=dbaccess.raw_query_SQL(self.access[1], "select count(distinct(page_id)) from "+\
            "page where page_namespace=0 and page_is_redirect=0")
            #Obtain number of talk pages
            self.talk=dbaccess.raw_query_SQL(self.access[1], "select count(distinct(page_id)) from "+\
            "page where page_namespace=1")
            dbaccess.close_Connection(self.access[0])
            #Writing data to file
            file=open("overall/data/articles-talk-ratio.dat",'a')
            file.write(str(int(self.articles[0][0]))+"\t"+str(int(self.talk[0][0]))+"\t"+\
            str(float(self.talk[0][0])/float(self.articles[0][0]))+"\t"+self.language+"\n")
            file.close()
            #print "Completed lang "+self.language+"\n"
        
    def bots(self):
        """
        Preprocessing actions with bots data
        """
        for self.language in self.languages:
            self.dbname="wx_"+self.language+"wiki_research" 
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            #TABLE revs_bots (revisions made by officially identified bots, by year, month)
            dbaccess.raw_query_SQL(self.access[1],"drop table if exists revs_bots")
            dbaccess.raw_query_SQL(self.access[1], "create table revs_bots as select year(rev_timestamp) "+\
            "theyear, month(rev_timestamp) themonth, count(*) num_revs from revision where rev_user!=0 "+\
            "and rev_user in (select ug_user from user_groups where ug_group='bot') group by "+\
            "year(rev_timestamp), month(rev_timestamp) order by year(rev_timestamp), month(rev_timestamp)")

            #TABLE revs_logged (revisions made by logged authors, by year, month)
            dbaccess.raw_query_SQL(self.access[1],"drop table if exists revs_logged")
            dbaccess.raw_query_SQL(self.access[1],"create table revs_logged as select year(rev_timestamp) "+\
            "theyear, month(rev_timestamp) themonth, count(*) num_revs from revision where rev_user!=0 "+\
            "group by year(rev_timestamp), month(rev_timestamp) order by year(rev_timestamp), month(rev_timestamp)")

            #TABLE revs_all (revisions made by all authors, by year, month)
            dbaccess.raw_query_SQL(self.access[1],"drop table if exists revs_all")
            dbaccess.raw_query_SQL(self.access[1], "create table revs_all as select year(rev_timestamp) "+\
            "theyear, month(rev_timestamp) themonth, count(*) num_revs from revision "+\
            "group by year(rev_timestamp), month(rev_timestamp) order by year(rev_timestamp), month(rev_timestamp)")

            dbaccess.close_Connection(self.access[0])

        #FILE perc-bots-all-revs.dat % of all revisions due to bots
        file=open("overall/data/perc-bots-all-revs.dat",'w')
        file.write("year\tmonth\tperc_revs\tlang\n")
        file.close()
        for self.language in self.languages:
            self.dbname="wx_"+self.language+"wiki_research" 
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            #Obtain % of total no. revs due to bots, by year, month
            self.perc_revs=dbaccess.raw_query_SQL(self.access[1], "select bot.theyear, bot.themonth, "+\
            "(bot.num_revs/tot.num_revs)*100 perc_revs from revs_bots as bot, revs_all as tot "+\
            "where bot.theyear=tot.theyear and bot.themonth=tot.themonth;")
            dbaccess.close_Connection(self.access[0])
            #Writing data to file
            file=open("overall/data/perc-bots-all-revs.dat",'a')
            for item in self.perc_revs:
                file.write(str(int(item[0]))+"\t"+str(int(item[1]))+"\t"+\
                str(float(item[2]))+"\t"+self.language+"\n")
            file.close()

        #file perc-bots-logged-revs.dat % of all revisions due to bots
        file=open("overall/data/perc-bots-logged-revs.dat",'w')
        file.write("year\tmonth\tperc_revs\tlang\n")
        file.close()
        for self.language in self.languages:
            self.dbname="wx_"+self.language+"wiki_research" 
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            #obtain % of no. revs by logged editors due to bots, by year, month
            self.perc_revs=dbaccess.raw_query_sql(self.access[1], "select bot.theyear, bot.themonth, "+\
            "(bot.num_revs/logged.num_revs)*100 perc_logged_revs from revs_bots as bot, "+\
            "revs_logged as logged where bot.theyear=logged.theyear and bot.themonth=logged.themonth;")
            dbaccess.close_connection(self.access[0])
            #writing data to file
            file=open("overall/data/perc-bots-logged-revs.dat",'a')
            for item in self.perc_revs:
                file.write(str(int(item[0]))+"\t"+str(int(item[1]))+"\t"+\
                str(float(item[2]))+"\t"+self.language+"\n")
            file.close()

#############
##   MAIN
#############
if __name__ == '__main__':
    #languages=["ar","bg", "br", "bs", "ca", "cs", "da", "el", "eo", "et", "eu", "fa", "fi", "fur", "gl", "he", "hr",\
    #"hu", "id", "is", "kk", "ko", "lb", "lt", "lv", "ms", "mt", "new","nn", "no", "ro", "sh", "simple",  "sk", "sl", "sr",\
    #"th", "tr", "uk", "vi", "vo","zh", "sv", "es","pt","it", "nl","pl","ja","fr","de","en"]  
    languages=["sv","es","pt","it", "nl","pl","ja","fr","de","en"] ##RU
    dbuser="root"; dbpassw="phoenix"
    process=Prepro_overall(dbuser, dbpassw, languages)
    process.trigger()
        