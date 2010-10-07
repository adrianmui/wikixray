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
        
    def overall(self):
        """
        Retrieve page_len for each wiki_page and other info
        """
        self.f=open("data/page_len.dat", 'w')
	    self.f.write("page_len\tns\tis_redirect\tis_stub\tis_new\tlang\n")
	    self.f.close()
        for self.language in self.languages:
          self.dbname="wx_"+self.language+"wiki_research"	
          self.access=dbaccess.get_Connection("localhost", 3306, self.dbuser, self.dbpassw, self.dbname)
          print "Retrieving info from "+self.language+"\n"
          #dbaccess.raw_query_SQL(self.access[1], "DROP TABLE IF EXISTS admin_revision_main")
          results=dbaccess.raw_query_SQL(self.access[1], "SELECT page_len, page_namespace, page_is_redirect, page_is_stub, "+\
          "page_is_new FROM page")
          print "Updating page_len info file with "+self.language+"\n"
            
          self.f=open("data/page_len.dat", 'a')
          for result in results:
            self.f.write(str(int(result[0]))+"\t"+str(int(result[1]))+"\t"+str(int(result[2]))+"\t"+\
            str(int(result[3]))+"\t"+str(int(result[4]))+"\t"+self.language+"\n")
          self.f.close()
          results=None
          dbaccess.close_Connection(self.access[0])
    
if __name__ == '__main__':
   languages=["ru", "es","pt","it", "nl","pl","ja","fr","de","en"]

   dbuser="root"; dbpassw="phoenix"
   process=Process(dbuser, dbpassw, languages)
   process.overall()
