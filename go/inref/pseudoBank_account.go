//////////////////////////////////////////////////////////////////
//								//
// Copyright (c) 2019 T.N. Incorporation Ltd (TNI) and/or	//
// its subsidiaries. All rights reserved.			//
//								//
// Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	//
// All rights reserved.						//
//								//
//	This source code contains the intellectual property	//
//	of its copyright holder(s), and is made available	//
//	under a license.  If you do not know the terms of	//
//	the license, please stop and do not read further.	//
//								//
//////////////////////////////////////////////////////////////////

package dataObject

import (
	// "errors"
	"lang.yottadb.com/go/yottadb"
	"strconv"
	"strings"
	// "unicode"
)

const accountGlobal = "^ZACN"

type Account struct {
	Cid     int
	Bal     int
	HistSeq int
}

func (a *Account) Load(tptoken uint64, cid int, key *yottadb.KeyT, data *yottadb.BufferT, errStr *yottadb.BufferT) error {
	var err error
	var val1 string

	// get account information from database and set it to account
	err = setAccountKey(tptoken, cid, key, errStr)
	if err != nil {
		return err
	}
	data.Alloc(64)

	// get data
	err = key.ValST(tptoken, errStr, data)
	if err != nil {
		return err
	}
	val1, err = data.ValStr(tptoken, errStr)
	values := strings.Split(val1, "|")

	a.Cid = cid
	a.HistSeq, _ = strconv.Atoi(values[0])
	a.Bal, _ = strconv.Atoi(values[1])

	return nil
}

func (a *Account) Save(tptoken uint64, key *yottadb.KeyT, data *yottadb.BufferT, errStr *yottadb.BufferT) error {
	var err error

	// set key
	err = setAccountKey(tptoken, a.Cid, key, errStr)
	if err != nil {
		return err
	}
	// prepare data
	stringData := a.getTextData()
	data.Alloc(64)

	// set value
	err = data.SetValStr(tptoken, errStr, stringData)
	if err != nil {
		return err
	}
	// set data into database
	err = key.SetValST(tptoken, errStr, data)
	if err != nil {
		return err
	}
	return nil
}

func (a *Account) getTextData() string {
	return strconv.Itoa(a.HistSeq) + "|" + strconv.Itoa(a.Bal)
}

func setAccountKey(tptoken uint64, cid int, key *yottadb.KeyT, errStr *yottadb.BufferT) error {
	var err error
	err = key.Varnm.SetValStr(tptoken, errStr, accountGlobal)
	if err != nil {
		return err
	}
	err = key.Subary.SetElemUsed(tptoken, errStr, 1)
	if err != nil {
		return err
	}
	err = key.Subary.SetValStr(tptoken, errStr, 0, strconv.Itoa(cid))
	if err != nil {
		return err
	}
	return nil
}
