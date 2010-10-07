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
Generic methods providing access to the MySQL database.

@see: quantAnalay_main

"""

import MySQLdb

def get_Connection(ahost, aport, auser, apasswd, adb="test"):
	""" Create a connection object and create a cursor
	"""
	if adb:
		Con = MySQLdb.Connect(host=ahost, port=aport, user=auser, passwd=apasswd, db=adb)
	else:
		Con = MySQLdb.Connect(host=ahost, port=aport, user=auser, passwd=apasswd)
	Cursor = Con.cursor()
	return (Con, Cursor)

def query_SQL(cursor, select, tables, where='', order='', group='',create='', insert=''):
	"""
	Singleton method to access the database
	Input is the query (given by several parameters)
	Output is a row (of rows)

	@type  select: string 
	@param select: Fields to select
	@type  tables: string
	@param tables: Database tables involved in this query
	@type  where: string
	@param where: Where clause (optional; default: not used)
	@type  order: string
	@param order: Order clause (optional; default: not used)
	@type  group: string
	@param group: Group clause (optional; default: not used)
	"""
	
	if create:
		if order and where and group:
			query = "CREATE TABLE " + create + " SELECT " + select + " FROM " + tables + " WHERE " + where  + " GROUP BY " + group + " ORDER BY " + order
		elif order and where:
			query = "CREATE TABLE " + create + " SELECT " + select + " FROM " + tables + " WHERE " + where + " ORDER BY " + order
		elif order and group:
			query = "CREATE TABLE " + create + " SELECT " + select + " FROM " + tables + " GROUP BY " + group + " ORDER BY " + order		
		elif group and where:
			query = "CREATE TABLE " + create + " SELECT " + select + " FROM " + tables + " WHERE " + where + " GROUP BY " + group
		elif group:
			query = "CREATE TABLE " + create + " SELECT " + select + " FROM " + tables + " GROUP BY " + group
		elif order:
			query = "CREATE TABLE " + create + " SELECT " + select + " FROM " + tables + " ORDER BY " + order
		elif where:
			query = "CREATE TABLE " + create + " SELECT " + select + " FROM " + tables + " WHERE " + where
		else:
			query = "CREATE TABLE " + create + " SELECT " + select + " FROM " + tables
	elif insert:
		if order and where and group:
			query = "INSERT INTO " + insert + " SELECT " + select + " FROM " + tables + " WHERE " + where  + " GROUP BY " + group + " ORDER BY " + order
		elif order and where:
			query = "INSERT INTO " + insert + " SELECT " + select + " FROM " + tables + " WHERE " + where + " ORDER BY " + order
		elif order and group:
			query = "INSERT INTO " + insert + " SELECT " + select + " FROM " + tables + " GROUP BY " + group + " ORDER BY " + order		
		elif group and where:
			query = "INSERT INTO " + insert + " SELECT " + select + " FROM " + tables + " WHERE " + where + " GROUP BY " + group
		elif group:
			query = "INSERT INTO " + insert + " SELECT " + select + " FROM " + tables + " GROUP BY " + group
		elif order:
			query = "INSERT INTO " + insert + " SELECT " + select + " FROM " + tables + " ORDER BY " + order
		elif where:
			query = "INSERT INTO " + insert + " SELECT " + select + " FROM " + tables + " WHERE " + where
		else:
			query = "INSERT INTO " + insert + " SELECT " + select + " FROM " + tables
	elif order and where and group:
		query = "SELECT " + select + " FROM " + tables + " WHERE " + where  + " GROUP BY " + group + " ORDER BY " + order
	elif order and where:
		query = "SELECT " + select + " FROM " + tables + " WHERE " + where + " ORDER BY " + order
	elif order and group:
		query = "SELECT " + select + " FROM " + tables + " GROUP BY " + group + " ORDER BY " + order		
	elif group and where:
		query = "SELECT " + select + " FROM " + tables + " WHERE " + where + " GROUP BY " + group
	elif order:
		query = "SELECT " + select + " FROM " + tables + " ORDER BY " + order
	elif group:
		query = "SELECT " + select + " FROM " + tables + " GROUP BY " + group
	elif where:
		query = "SELECT " + select + " FROM " + tables + " WHERE " + where
	else:
		query = "SELECT " + select + " FROM " + tables
	##print "\n\n"+query+"\n\n"

	# Make SQL string and execute it
	cursor.execute(query)

	# Fetch all results from the cursor into a sequence and close the connection
	results = cursor.fetchall()
	return results
	
def raw_query_SQL(cursor, query):
	cursor.execute(query)
	results = cursor.fetchall()
	return results

def createDB_SQL(cursor,language):
	query = "CREATE DATABASE " + language
	cursor.execute(query)
	results = cursor.fetchall()
	
	return results

def dropTab_SQL(cursor,tab):
	query = "DROP TABLE IF EXISTS "+tab
	cursor.execute(query)

def createView(cursor, view="test_view", columns='', query=''):
    if columns:
        view_query="CREATE OR REPLACE VIEW "+view+" ("+columns+") AS "+query
        print "\n\n"+view_query+"\n\n"
        cursor.execute(view_query)
    else:
        view_query="CREATE OR REPLACE VIEW "+view+" AS "+query
        print "\n\n"+view_query+"\n\n"
        cursor.execute(view_query)

def dropView(cursor, view="test_view"):
    query = "DROP VIEW IF EXISTS "+view
    cursor.execute(query)

def close_Connection (con):
	#Cerramos conexion a BDatos	
	con.close()
