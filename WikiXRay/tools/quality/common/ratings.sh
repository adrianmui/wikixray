#! /bin/bash

mysql -u root -pphoenix wx_svwiki_research < query_views.sql
mysql -u root -pphoenix wx_itwiki_research < query_views.sql
mysql -u root -pphoenix wx_jawiki_research < query_views.sql
mysql -u root -pphoenix wx_plwiki_research < query_views.sql
mysql -u root -pphoenix wx_frwiki_research < query_views.sql
mysql -u root -pphoenix wx_dewiki_research < query_views.sql
mysql -u root -pphoenix wx_enwiki_research < query_views.sql


