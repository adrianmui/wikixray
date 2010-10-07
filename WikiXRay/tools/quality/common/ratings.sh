#! /bin/bash

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

mysql -u root -pphoenix wx_svwiki_research < query_views.sql
mysql -u root -pphoenix wx_itwiki_research < query_views.sql
mysql -u root -pphoenix wx_jawiki_research < query_views.sql
mysql -u root -pphoenix wx_plwiki_research < query_views.sql
mysql -u root -pphoenix wx_frwiki_research < query_views.sql
mysql -u root -pphoenix wx_dewiki_research < query_views.sql
mysql -u root -pphoenix wx_enwiki_research < query_views.sql


