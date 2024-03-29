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
        file=open("author-pages.dat",'w')
        file.write("logged_authors\tuser_pages\tratio\tlang\n")
        file.close()
        for self.language in self.languages:
            self.dbname="wx_"+self.language+"wiki_research"	
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            self.logged_authors=dbaccess.raw_query_SQL(self.access[1], "select count(distinct(rev_user)) from "+\
            "revision where rev_user!=0")
            self.user_pages=dbaccess.raw_query_SQL(self.access[1], "select count(distinct(page_id)) from "+\
            "page where page_namespace=2")
            dbaccess.close_Connection(self.access[0])
            file=open("author-pages.dat",'a')
            file.write(str(int(self.logged_authors[0][0]))+"\t"+str(int(self.user_pages[0][0]))+"\t"+\
            str(float(self.user_pages[0][0])/float(self.logged_authors[0][0]))+"\t"+self.language+"\n")
            file.close()
            print "Completed lang "+self.language+"\n"
        
        file=open("articles-talk-ratio.dat",'w')
        file.write("articles\ttalk\tratio\tlang\n")
        file.close()
        for self.language in self.languages:
            self.dbname="wx_"+self.language+"wiki_research"	
            self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
            self.articles=dbaccess.raw_query_SQL(self.access[1], "select count(distinct(page_id)) from "+\
            "page where page_namespace=0 and page_is_redirect=0")
            self.talk=dbaccess.raw_query_SQL(self.access[1], "select count(distinct(page_id)) from "+\
            "page where page_namespace=1")
            dbaccess.close_Connection(self.access[0])
            file=open("articles-talk-ratio.dat",'a')
            file.write(str(int(self.articles[0][0]))+"\t"+str(int(self.talk[0][0]))+"\t"+\
            str(float(self.talk[0][0])/float(self.articles[0][0]))+"\t"+self.language+"\n")
            file.close()
            print "Completed lang "+self.language+"\n"
    
if __name__ == '__main__':
    #languages=["ar","bg", "br", "bs", "ca", "cs", "da", "el", "eo", "et", "eu", "fa", "fi", "fur", "gl", "he", "hr",\
    #"hu", "id", "is", "kk", "ko", "lb", "lt", "lv", "ms", "mt", "new","nn", "no", "ro", "sh", "simple",  "sk", "sl", "sr",\
    #"th", "tr", "uk", "vi", "vo","zh", "sv", "es","pt","it", "nl","pl","ja","fr","de","en"] 
    languages=["sv","es","pt","it","nl","ja","pl","fr","de","en"]
    dbuser="root"; dbpassw="phoenix"
    process=Process(dbuser, dbpassw, languages)
    process.overall()
