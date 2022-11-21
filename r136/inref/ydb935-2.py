#!/usr/bin/env python3
#################################################################
#                                                               #
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#   This source code contains the intellectual property         #
#   of its copyright holder(s), and is made available           #
#   under a license.  If you do not know the terms of           #
#   the license, please stop and do not read further.           #
#                                                               #
#################################################################

from threading import Thread
import yottadb
from time import sleep

def set_thread():
        for x in range(5):
            set(str(x))
            sleep(1)

def get_thread():
        get()

def set(x):
        yottadb.set("^a", value=x)
        yottadb.set("^b", value=x)
        yottadb.set("^c", value=x)

def get():
        yottadb.get("^a")
        yottadb.get("^b")
        yottadb.get("^c")

if __name__ =="__main__":
        t1 = Thread(target=set_thread)
        t2 = Thread(target=get_thread)

        t1.start()
        t1.join() # End first thread
        t2.start()
        t2.join() # End second thread
