#!/bin/bash

# mysql -u root -pphoenix wx_svwiki_research < index_recent.sql
# echo "SV finished\n"
# mysql -u root -pphoenix wx_eswiki_research < index_recent.sql
# echo "ES finished\n"
# mysql -u root -pphoenix wx_ptwiki_research < index_recent.sql
# echo "PT finished\n"
# mysql -u root -pphoenix wx_itwiki_research < index_recent.sql
# echo "IT finished\n"
# mysql -u root -pphoenix wx_nlwiki_research < index_recent.sql
# echo "NL finished\n"
# mysql -u root -pphoenix wx_plwiki_research < index_recent.sql
# echo "PL finished\n"
mysql -u root -pphoenix wx_jawiki_research < index_recent.sql
echo "JA finished\n"
mysql -u root -pphoenix wx_frwiki_research < index_recent.sql
echo "FR finished\n"
mysql -u root -pphoenix wx_dewiki_research < index_recent.sql
echo "DE finished\n"
mysql -u root -pphoenix wx_enwiki_research < index_recent.sql
echo "EN finished\n"