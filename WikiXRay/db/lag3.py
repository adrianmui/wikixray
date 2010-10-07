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

class lag(object):
    """
    The main class to call each individual script
    """
    def __init__(self, user, passw, language, dumptype):
        self.user=user
        self.passw=passw
        self.language=language
        self.dumptype=dumptype

    def calculate(self):
        self.access = dbaccess.get_Connection("localhost", 3306, self.user,\
        self.passw, "wx_"+self.language+"wiki_"+self.dumptype)
        
	try:
            print "Creating table for logged users..."
            users=dbaccess.raw_query_SQL(self.access[1],"create table lag_info (rev_user INT(10) UNSIGNED NOT NULL,"+\
	    "fecha1 datetime not null, fecha2 datetime not null)")
        except Exception, e:
            print "An exception ocurred, the problem was the following:\n"
            print e
            print "*************\n\n"
	
        try:
            print "Retrieving list of logged users..."
            users=dbaccess.raw_query_SQL(self.access[1],"select distinct(rev_user) from revision where rev_user!=0 "+\
	    "and rev_user not in (select ug_user from user_groups where ug_group='bot')")
        except Exception, e:
            print "An exception ocurred, the problem was the following:\n"
            print e
            print "*************\n\n"
	print "Composing lag info, and inserting in db table...\n"
	for user in users:
	  history=[]
	  try:
	      print "User "+str(int(user[0]))+"..."
	      history=dbaccess.raw_query_SQL(self.access[1],"select rev_user, rev_timestamp from revision "+\
	      "where rev_user="+str(int(user[0]))+" order by rev_timestamp")
	  except Exception, e:
	      print "An exception ocurred in user processing, the problem was the following:\n"
	      print e
	      print "*************\n\n"
	  # It only makes sense to insert information if there are at least 2 editions for a certain user
	  if length(history)>1:
	    j=0
	    result=[]
	    query=""
	    for item in history:
		if (j+1)<len(history):
		    result.append((item[0], item[1], history[j+1][1]))
		    j=j+1
	    k=0
	    for item in result:
		query=query+"("+str(item[0])+",'"+str(item[1])+"','"+str(item[2])+"')"
		if k<len(result)-1:
		    query=query+","
		    k=k+1
	    try:
		print "Inserting info abot user "+str(int(user[0]))+"..."
		#print query
		history=dbaccess.raw_query_SQL(self.access[1],"insert into lag_info values "+query)
	    except Exception, e:
		print "An exception ocurred inserting in the DB, the problem was the following:\n"
		print e
		print "*************\n\n"

        print "Finished lag work for"+"wx_"+self.language+"wiki_"+self.dumptype+"...\n"
        ##Close connection to DB server
        dbaccess.close_Connection(self.access[0])
    
if __name__ == '__main__':

    ##DONE sv, es
    languages=["de", "ca", "cs", "da","eo","es","fi","fr"]

    #Normal languages
    #for lang in languages:
        #new_index=indexes("root","phoenix",lang,"research")
        #new_index.make_indexes()

    for lang in languages:
	alag=lag("root","phoenix",lang,"research")
	alag.calculate()

    #The stub dump for enwiki
    #lag_es=lag("root","phoenix","es","research")
    #lag_es.calculate()

