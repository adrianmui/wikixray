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

if __name__ == '__main__':
    
    fileFA= codecs.open('FAs_ru_3.txt','r','utf_8')
    fileFA_out=codecs.open('FAs_ru_out.txt','w','utf_8')
    lines=fileFA.readlines()
    fileFA.close()
    
    for line in lines:
        line=line.replace("****","\n")
        fileFA_out.write(line)
    fileFA_out.close()
