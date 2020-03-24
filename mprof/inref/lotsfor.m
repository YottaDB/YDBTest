;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2019-2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This module was derived from FIS GT.M code.
;
alotsfor for s=1:1:1000 for x=1:1:100 for y=1:1:10 s sxy=1
	for s1=1:1:1 for s2=1:1:1 for s3=1:1:1 for s4=1:1:1 for s5=1:1:1 for s6=1:1:1 for s7=1:1:1 for s8=1:1:1 for s9=1:1:1 for s10=1:1:1 for s11=1:1:1 for s12=1:1:1 for s13=1:1:1 for s14=1:1:1 for s15=1:1:1 for s16=1:1:1 s x=1
boneone	for s=1:1:1 for x=1:1:1 for y=1:1:1 for z=1:1:1 for t=1:1:1 s sxyzt=1
cquits	for s=1:1:10 q:s=5  for x=1:1:10 for y=1:1:10 s sxy=1
	for s=1:1:10 for x=1:1:10 q:x=5  for y=1:1:10 s sxy=1
	for s=1:1:10 for x=1:1:10 for y=1:1:100 q:y=5  s sxy=1
dmulti	for s=1:1:10  d
	.for x=1:1:10 d
	. . for y=1:1:10 d
	. . . for z=1:1:10 s sxyz=1
	. . . for t=1:1:10 s sxyt=1 d
	. . . . s sxyt=2
	. . . . s sxyt=3
	. . . s xy=2
	. . s sx=2
	. s ss=2
	d smulti
	d smulti
	f i=1:1:2 d smulti1
	q
smulti	for s=1:1:10 d
	. for x=1:1:10 d
	. . for y=1:1:10 d
	. . . s sxy=1
	for s=1:1:10 s ss=1
	for s=1:1:10 q:s=3  s ss=1
zmany	for i=1:1:30 s j=1 f j=1:1:2000 f a=1:1:30 s k=1
zminfor	for s=10:-1:1 d
	. for x=10:-1:1 d
	. . s sx=1
	for s=10:-1:1 q:s=3  s ss=1
	q
smulti1	s s(i)=i
	q
