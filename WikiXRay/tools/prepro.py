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

import dbaccess, prepro_overall, prepro_demography

class Prepro(object):
    """
    The main class executing the SQL statements and creating .dat files
    """
    def __init__(self, dbuser, dbpassw, languages):
        #self.languages=languages
        #self.dbuser=dbuser
        #self.dbpassw=dbpassw

        # Scripts for overall
        self.pre_overall=Prepro_overall(dbuser, dbpassw, languages)
        self.pre_demography=Prepro_demography(dbuser, dbpassw, languages)

    def trigger(self):
        """
        Function that executes individual sets of scripts in this class
        """
        self.pre_overall.trigger()
        self.pre_demography.trigger()
    
######################
##  MAIN ZONE
######################
        
if __name__ == '__main__':
    #languages=["ar","bg", "br", "bs", "ca", "cs", "da", "el", "eo", "et", "eu", "fa", "fi", "fur", "gl", "he", "hr",\
    #"hu", "id", "is", "kk", "ko", "lb", "lt", "lv", "ms", "mt", "new","nn", "no", "ro", "sh", "simple",  "sk", "sl", "sr",\
    #"th", "tr", "uk", "vi", "vo","zh", "sv", "es","pt","it", "nl","pl","ja","fr","de","en"] 
    ###########################
    ### NOT DONE FOR ALL!!!
    ###########################
    languages=["sv","es","pt","it", "nl","pl","ja","fr","de","en"] #ATTENTION!! REMAINING RU!!!!!!!!
    dbuser="root"; dbpassw="phoenix"
    process=Prepro(dbuser, dbpassw, languages)
    process.trigger()
        