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
	    
            #No. of revisions made by every logged author
            dbaccess.raw_query_SQL(self.access[1],"CREATE TABLE IF NOT EXISTS user_revs AS "+\
            "SELECT rev_user, count(*) num_revs from revision WHERE rev_user!=0 AND "+\
            "rev_user not in (SELECT ug_user FROM user_groups WHERE ug_group='bot') GROUP BY rev_user")
            dbaccess.raw_query_SQL(self.access[1],"ALTER TABLE user_revs ADD PRIMARY KEY (rev_user)")
            
            print "Created table user_revs for "+self.language+"wiki...\n"
            
            #Min and max timestamp for every logged author + total num_revs
            dbaccess.raw_query_SQL(self.access[1],"CREATE TABLE IF NOT EXISTS time_range_authors AS "+\
            "(SELECT x.*, (select num_revs from user_revs d where d.rev_user=x.rev_user) num_revs FROM "+\
            "(SELECT rev_user, min(rev_timestamp) min_ts, max(rev_timestamp) max_ts from revision group by rev_user) x "+\
            "ORDER BY min_ts)")
            
            print "Created table time_range_authors for "+self.language+"wiki...\n"
                
            #Close DB connection
            dbaccess.close_Connection(self.access[0])


if __name__ == '__main__':
##  languages=["ar","bg", "br", "bs", "ca", "cs", "da", "el", "eo", "et", "eu", "fa", "fi", "fur", "gl", "he", "hr",\
##  "hu", "id", "is", "kk", "ko", "lb", "lt", "lv", "ms", "mt", "new","nn", "no", "ro", "sh", "simple",  "sk", "sl", "sr",\
##  "th", "tr", "uk", "vi", "vo"] 
##    languages=["zh", "sv", "es", "pt"] 1)
    languages=["es","sv","pt","it","nl","pl","ja","fr","de","en"]
    #languages=["ru"]
    dbuser="root"; dbpassw="phoenix"
    process=Process(dbuser, dbpassw, languages)
    process.analyze()
    
