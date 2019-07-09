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
	"lang.yottadb.com/go/yottadb"
	"strconv"
)

type HistRecord struct {
	Cid     int
	HistSeq int

	Comment string
	Amt     int
	Endbal  int
	User    string
}

const histGlobal = "^ZHIST"

func (h *HistRecord) Save(tptoken uint64, key *yottadb.KeyT, data *yottadb.BufferT, errStr *yottadb.BufferT) error {
	var err error

	// set key
	err = setHistKey(tptoken, h.Cid, h.HistSeq, key, errStr)
	if err != nil {
		return err
	}
	// prepare data
	stringData := h.getTextData()
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

func (h *HistRecord) getTextData() string {
	return h.Comment + "|" + strconv.Itoa(h.Amt) + "|" + strconv.Itoa(h.Endbal) + "|" + h.User
}

func setHistKey(tptoken uint64, cid, histSeq int, key *yottadb.KeyT, errStr *yottadb.BufferT) error {
	var err error
	err = key.Varnm.SetValStr(tptoken, errStr, histGlobal)
	if err != nil {
		return err
	}
	err = key.Subary.SetElemUsed(tptoken, errStr, 2)
	if err != nil {
		return err
	}
	err = key.Subary.SetValStr(tptoken, errStr, 0, strconv.Itoa(cid))
	if err != nil {
		return err
	}
	err = key.Subary.SetValStr(tptoken, errStr, 1, strconv.Itoa(histSeq))
	if err != nil {
		return err
	}
	return nil
}
