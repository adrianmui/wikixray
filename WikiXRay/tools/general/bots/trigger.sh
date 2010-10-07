#!/bin/bash
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

echo "Preparing enwiki tables...\n"
mysql -u root -pphoenix wx_enwiki_research < ../../../../db/spells_bots.sql > out_enbots.txt
echo "Preparing dewiki tables...\n"
mysql -u root -pphoenix wx_dewiki_research < ../../../../db/spells_bots.sql > out_debots.txt
echo "Preparing frwiki tables...\n"
mysql -u root -pphoenix wx_frwiki_research < ../../../../db/spells_bots.sql > out_frbots.txt
echo "Preparing plwiki tables...\n"
mysql -u root -pphoenix wx_plwiki_research < ../../../../db/spells_bots.sql > out_plbots.txt
echo "Preparing jawiki tables...\n"
mysql -u root -pphoenix wx_jawiki_research < ../../../../db/spells_bots.sql > out_jabots.txt
echo "Preparing nlwiki tables...\n"
mysql -u root -pphoenix wx_nlwiki_research < ../../../../db/spells_bots.sql > out_nlbots.txt
echo "Preparing itwiki tables...\n"
mysql -u root -pphoenix wx_itwiki_research < ../../../../db/spells_bots.sql > out_itbots.txt
echo "Preparing ptwiki tables...\n"
mysql -u root -pphoenix wx_ptwiki_research < ../../../../db/spells_bots.sql > out_ptbots.txt
echo "Preparing svwiki tables...\n"
mysql -u root -pphoenix wx_svwiki_research < ../../../../db/spells_bots.sql > out_svbots.txt
echo "Preparing eswiki tables...\n"
mysql -u root -pphoenix wx_eswiki_research < ../../../../db/spells_bots.sql > out_esbots.txt
echo "Preparing ruwiki tables...\n"
mysql -u root -pphoenix wx_ruwiki_research < ../../../../db/spells_bots.sql > out_rubots.txt
echo "Catapun chin pun!\n"