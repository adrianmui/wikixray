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
This module is aimed to execute the set of scripts currently deveolped
for automating the analysis of any Wikipedia.

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

class indexes(object):
    """
    The main class to call each individual script
    """
    def __init__(self, user, passw, language, dumptype):
        self.user=user
        self.passw=passw
        self.language=language
        self.dumptype=dumptype

    def make_indexes(self):
        self.access = dbaccess.get_Connection("localhost", 3306, self.user,\
        self.passw, "wx_"+self.language+"wiki_"+self.dumptype)
        #Generate adequate indexes and keys in tables page and revision
        #try:
            #print "Generating index for page_len...\n"
            #dbaccess.raw_query_SQL(self.access[1],"ALTER TABLE page ADD INDEX page_len(page_len)")
        #except Exception, e:
            #print "An exception ocurred, the problem was the following:\n"
            #print e
            #print "*************\n\n"
        try:
            print "Creating index for rev_timestamp"
            dbaccess.raw_query_SQL(self.access[1],"ALTER TABLE revision ADD INDEX timestamp(rev_timestamp)")
        except Exception, e:
            print "An exception ocurred, the problem was the following:\n"
            print e
            print "*************\n\n"
        try:
            print "Generating index for rev_page and rev_timestamp...\n"
            dbaccess.raw_query_SQL(self.access[1],"ALTER TABLE revision ADD INDEX page_timestamp(rev_page, rev_timestamp)")
        except Exception, e:
            print "An exception ocurred, the problem was the following:\n"
            print e
            print "*************\n\n"
        try:
            print "Generating index for rev_user and rev_timestamp...\n"
            dbaccess.raw_query_SQL(self.access[1],"ALTER TABLE revision ADD INDEX user_timestamp(rev_user, rev_timestamp)")
        except Exception, e:
            print "An exception ocurred, the problem was the following:\n"
            print e
            print "*************\n\n"
        #try:
            #print "Generating index for rev_user_text and timestamp...\n"
            #dbaccess.raw_query_SQL(self.access[1],"ALTER TABLE revision ADD INDEX usertext_timestamp(rev_user_text(15), rev_timestamp)")
        #except Exception, e:
            #print "An exception ocurred, the problem was the following:\n"
            #print e
            #print "*************\n\n"
        print "Database"+"wx_"+self.language+"wiki_"+self.dumptype+" ready for quantitative analysis...\n"
        ##Close connection to DB server
        dbaccess.close_Connection(self.access[0])
    
if __name__ == '__main__':

    languages=["pt","it","nl","ja","pl","fr","de"]

    #Normal languages
    for lang in languages:
        new_index=indexes("root","phoenix",lang,"research")
        new_index.make_indexes()

    #The stub dump for enwiki
    #index_english=indexes("root","phoenix","en","stub_research")
    #index_english.make_indexes()

