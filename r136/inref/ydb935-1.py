#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
from flask import Flask, request, jsonify
import json, os, yottadb, time
import sys
import random

app = Flask(__name__)
globals = ['^a', '^b', '^c']
@app.route('/adduser', methods=['POST'])
def adduser():
    if request.method == 'POST':
       request_data = request.get_json()
       name = request_data['name']
       sex = request_data['sex']
       age = request_data['age']
       try:
          id = yottadb.subscript_previous("^PATIENTS", ("",)).decode()
       except yottadb.YDBNodeEnd:
          id=0
       id = int(id) + 1
       yottadb.set("^PATIENTS",(str(id), "name"), str(name))
       yottadb.set("^PATIENTS",(str(id), "sex"), str(sex))
       yottadb.set("^PATIENTS",(str(id), "age"), str(age))
       return('{ "name":"' + str(name) + '","status":"added"}')
    else:
       return('{ "status":"error"}')


@app.route('/users', methods=['GET'])
def users():
    random_global = random.choice(globals)
    json_data = []
    content = {}
    try:
       id = yottadb.subscript_next("^PATIENTS", ("",)).decode()
    except yottadb.YDBNodeEnd:
       content = {}
       content = {'id': "", 'name': "", 'sex': "", 'age': ""}
       json_data.append(content)
       return(jsonify(json_data))
    while True:
       try:
          key=yottadb.Key("^PATIENTS")[id]["age"]
          age = key.get().decode()
          key=yottadb.Key("^PATIENTS")[id]["sex"]
          sex = key.get().decode()
          key=yottadb.Key("^PATIENTS")[id]["name"]
          name = key.get().decode()
          content = {'id': str(id), 'name': str(name), 'sex': str(sex), 'age': str(age)}
          json_data.append(content)
          content = {}
          id = yottadb.subscript_next("^PATIENTS", (id,)).decode()
       except yottadb.YDBNodeEnd:
          break
    return(jsonify(json_data))

@app.route('/random_set', methods=['POST'])
def random_global_set():
    random_global = random.choice(globals)

    if request.method == 'POST':
       request_data = request.get_json()
       name = request_data['name']
       sex = request_data['sex']
       age = request_data['age']
       try:
          id = yottadb.subscript_previous(random_global, ("",)).decode()
       except yottadb.YDBNodeEnd:
          id=0
       id = int(id) + 1
       yottadb.set(random_global,(str(id), "name"), str(name))
       yottadb.set(random_global,(str(id), "sex"), str(sex))
       yottadb.set(random_global,(str(id), "age"), str(age))
       return('{ "name":"' + str(name) + '","status":"added"}')
    else:
       return('{ "status":"error"}')

@app.route('/random_get', methods=['GET'])
def random_global_get():
    random_global = random.choice(globals)
    json_data = []
    content = {}
    try:
       id = yottadb.subscript_next(random_global, ("",)).decode()
    except yottadb.YDBNodeEnd:
       content = {}
       content = {'id': "", 'name': "", 'sex': "", 'age': ""}
       json_data.append(content)
       return(jsonify(json_data))
    while True:
       try:
          key=yottadb.Key(random_global)[id]["age"]
          age = key.get().decode()
          key=yottadb.Key(random_global)[id]["sex"]
          sex = key.get().decode()
          key=yottadb.Key(random_global)[id]["name"]
          name = key.get().decode()
          content = {'id': str(id), 'name': str(name), 'sex': str(sex), 'age': str(age)}
          json_data.append(content)
          content = {}
          id = yottadb.subscript_next(random_global, (id,)).decode()
       except yottadb.YDBNodeEnd:
          break
    return(jsonify(json_data))
