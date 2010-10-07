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
Main module of WikiXRay, responsible for calling the other functional modules.

@see: quantAnalay_main

@authors: Jose Felipe Ortega
@organization: Grupo de Sistemas y Comunicaciones, Universidad Rey Juan Carlos
@copyright:    Universidad Rey Juan Carlos (Madrid, Spain)
@license:      GNU GPL version 2 or any later version
@contact:      jfelipe@gsyc.escet.urjc.es
"""

import os, string, dbaccess

class Process(object):
    """
    A simple class to preprocess tables needed for page length evolution over time
    """
    def __init__(self, dbuser, dbpassw, languages):
        self.languages=languages
        self.dbuser=dbuser
        self.dbpassw=dbpassw
        
    def overall(self):
        """
        Preprocessing tables for evolution of page length over time
        """
        for self.language in self.languages:
            self.dbname="wx_"+self.language+"wiki_research"	
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            dbaccess.raw_query_SQL(self.access[1], "create or replace view page_redirect as "+\
            "(select page_id from page where page_namespace=0 and page_is_redirect=1)")
            dbaccess.raw_query_SQL(self.access[1], "create or replace view rev_redirect as ("+\
            "select rev_id, rev_user, rev_page, rev_timestamp, rev_len from revision where rev_page in "+\
            "(select page_id from page_redirect))")
            dbaccess.raw_query_SQL(self.access[1], "create or replace view page_talk as "+\
            "(select page_id from page where page_namespace=1)")
            dbaccess.raw_query_SQL(self.access[1], "create or replace view rev_talk as ("+\
            "select rev_id, rev_user, rev_page, rev_timestamp, rev_len from revision where rev_page in "+\
            "(select page_id from page_talk))")
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
    
if __name__ == '__main__':
    #languages=["ar","bg", "br", "bs", "ca", "cs", "da", "el", "eo", "et", "eu", "fa", "fi", "fur", "gl", "he", "hr",\
    #"hu", "id", "is", "kk", "ko", "lb", "lt", "lv", "ms", "mt", "new","nn", "no", "ro", "sh", "simple",  "sk", "sl", "sr",\
    #"th", "tr", "uk", "vi", "vo","zh", "sv", "es","pt","it", "nl","pl","ja","fr","de","en"] 
    languages=["sv","es","pt","it","nl","ja","pl","fr","de","en"]
    dbuser="root"; dbpassw="phoenix"
    process=Process(dbuser, dbpassw, languages)
    process.overall()
