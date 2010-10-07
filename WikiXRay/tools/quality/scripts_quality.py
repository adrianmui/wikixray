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
This module is aimed to execute R scripts corresponding to the
overall statistics section

Prior to the execution of this module, the required activity data must
have been retrieved and loaded into a local MySQL database.

"""

import os

class Batch(object):
    """
    Representing the task list to be executed in the quality statistics
    section
    """

    def __init__(self):
        pass

    def trigger(self):
        """
        Function to execute the scripts
        They are all R scripts that should work autonomously
        """
        ##TODO: Indentifying independent scripts that can be executed in
        ##parallel, call them on independent lightweight processes

        section_path="overall/"
        filelist=os.listdir(section_path)

        for item in filelist:
            if (item.find(".R")!=-1 and item.find(".R~")==-1):
                os.system("R --vanilla <"+section_path+item)

        ##Section social-structure
        section_path="social-structure/"
        filelist=os.listdir(section_path)
        ##TODO: Insert code for section quality
        for item in filelist:
            if (item.find(".R")!=-1 and item.find(".R~")==-1 and\
            item.find("pareto")==-1 and item.find("plfit.r")==-1):
                os.system("R --vanilla <"+section_path+item)
        

if __name__ == '__main__':
    process=Batch()
    process.trigger()
        