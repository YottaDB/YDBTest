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
	"time"
)

type TrnLog struct {
	Guid string
	Tseq int

	Comment   string
	TDateTime time.Time
	Cid       int
	Amt       int
	Endbal    int
	User      string
}

const trnLogGlobal = "^ZTRNLOG"

func (t *TrnLog) Save(tptoken uint64, key *yottadb.KeyT, data *yottadb.BufferT, errStr *yottadb.BufferT) error {
	var err error

	// set key
	err = setTrnLogKey(tptoken, t.Guid, t.Tseq, key, errStr)
	if err != nil {
		return err
	}
	// prepare data
	stringData := t.getTextData()
	data.Alloc(128)

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

func (t *TrnLog) getTextData() string {
	dt := t.TDateTime.Format(time.RFC3339)
	return t.Comment + "|" + dt + "|" + strconv.Itoa(t.Cid) + "|" + strconv.Itoa(t.Amt) + "|" + strconv.Itoa(t.Endbal) + "|" + t.User
}

func setTrnLogKey(tptoken uint64, guid string, tseq int, key *yottadb.KeyT, errStr *yottadb.BufferT) error {
	var err error
	err = key.Varnm.SetValStr(tptoken, errStr, trnLogGlobal)
	if err != nil {
		return err
	}
	err = key.Subary.SetElemUsed(tptoken, errStr, 2)
	if err != nil {
		return err
	}
	err = key.Subary.SetValStr(tptoken, errStr, 0, guid)
	if err != nil {
		return err
	}
	err = key.Subary.SetValStr(tptoken, errStr, 1, strconv.Itoa(tseq))
	if err != nil {
		return err
	}
	return nil
}
