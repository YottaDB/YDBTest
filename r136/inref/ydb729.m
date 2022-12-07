;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Helper M program used by r136/u_inref/ydb729.csh
; Based on test.m from https://gitlab.com/YottaDB/DB/YDB/-/issues/729#note_1200129315
;

ydb729	;
	set $ztrap="goto incrtrap^incrtrap"
        do func1(1)
        do func1(12,34)
        do func1(123,456,789)
        do func1(1234,5678,9012,3456)
        do func2(1)
        do func2(12,34)
        do func2(123,456,789)
        do func2(1234,5678,9012,3456)
        do func3(1)
        do func3(12,34)
        do func3(123,456,789)
        do func3(1234,5678,9012,3456)
        do lab1
        do lab1(1)
        do lab1(1,2)
        do lab2
        do lab2(1)
        do lab2(1,2)
        if $$func1(1)
        if $$func1(12,34)
        if $$func1(123,456,789)
        if $$func1(1234,5678,9012,3456)
        if $$func2(1)
        if $$func2(12,34)
        if $$func2(123,456,789)
        if $$func2(1234,5678,9012,3456)
        if $$func3(1)
        if $$func3(12,34)
        if $$func3(123,456,789)
        if $$func3(1234,5678,9012,3456)
        if $$lab1
        if $$lab1(1)
        if $$lab1(1,2)
        if $$lab2
        if $$lab2(1)
        if $$lab2(1,2)
        quit
func1(x)
        quit
func2(x,y)
        quit
func3(x,y,z)
        quit
lab1
        quit
lab2()
        quit

