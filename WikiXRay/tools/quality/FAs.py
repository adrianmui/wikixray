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
import re, codecs
import dbaccess

if __name__ == '__main__':
    #de, es, nl, pt
    # OKs pt:
    #fileFA= codecs.open('FAs_es.txt','r','utf_8')
    fileFA= codecs.open('FAs_en_.txt','r','utf_8')
    lines=fileFA.readlines()
    fileFA.close()
    #pattern=r"\[\[.*\]\]"
    pattern=r"\[\[[^\]]+\]\]"
    listFA=[]
    onMain=0
    for line in lines:
        if(line.find("FA/BeenOnMainPage"))!=-1:
        #if(line.find("'''"))!=-1:
            onMain=1
        result=re.findall(pattern,line)
        if len(result)>0:
            listFA.append([result[0].split('|')[0].lstrip('[').rstrip(']').encode('utf_8'),onMain])
        onMain=0
##    for element in listFA:
##        print element[0]+"--"+str(element[1])+"\n"
##    print len(listFA)
    acceso = dbaccess.get_Connection("localhost", 3306, "pepito", "fenix","wx_enwiki_research")
    #listID=[]
    #fileID=open('FAsIDs_pt.txt','w')
    dbaccess.raw_query_SQL(acceso[1], "DROP TABLE IF EXISTS page_FAs")
    dbaccess.raw_query_SQL(acceso[1],\
    "CREATE TABLE page_FAs (page_id int(10) unsigned NOT NULL, page_title varchar(255), in_cover integer(1), PRIMARY KEY page_id(page_id))")
##    dbaccess.raw_query_SQL(acceso[1], "DROP TABLE IF EXISTS page_talk_FAs")
##    dbaccess.raw_query_SQL(acceso[1],\
##    "CREATE TABLE page_talk_FAs (page_id int(10) unsigned NOT NULL, page_title varchar(255), PRIMARY KEY page_id(page_id))")
    
    for element in listFA:
        print "Quering for ---> "+element[0].decode('utf_8')+" \n"
        try:
            dbaccess.raw_query_SQL(acceso[1], "INSERT INTO page_FAs (SELECT page_id, page_title, "+str(element[1])+" FROM page WHERE page_title='"+\
            element[0].replace("'","\\'").replace('"', '\\"')+"')")
##        print "Quering for ---> Discusión:"+element[0].decode('utf_8')+" \n"
##        try:
##            dbaccess.raw_query_SQL(acceso[1], "INSERT INTO page_talk_FAs (SELECT page_id, page_title FROM page WHERE page_title='Discusión:"+\
##            element[0].replace("'","\\'").replace('"', '\\"')+"' and page_namespace=1)")
        except (Exception), e:
            print "Ehhhhh, an exception ocurred..."+str(e)+"\n"
        #if len(result)>0:
            #fileID.write(str(result[0][0])+",")
            #listID.append(str(result[0][0]))
            #print "ID "+str(result[0][0])+"\n"
    #fileID.close()
    dbaccess.close_Connection(acceso[0])
##    for element in listFA:
##        print "--> '"+element[0].decode('utf_8')+"'\n"
##    print '\n'
##    count=0
##    for element in listFA:
##        if element[1]==True:
##            count+=1
##    print count
