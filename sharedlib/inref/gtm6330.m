;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm6330	;

genlits	;
	; Generate M source with lots of distinct literals.
	;
	Set n=100000
	Write "lotlits",!
	For i=1:1:n Write " Set %=""abc"_i_""",%=%_""def"_i_"""",!
	Write " Write ""lotslits done."",!",!
	Write " Quit",!
	Quit

cmpmem	;
	; Compare output from run1 and run2.
	;
	Set pcnt=.15	; threshold percentage
	Set file="run1_trim.log" Open file Use file
	Read x
	Close file
	Set x=$Piece(x," ",12)
	Set file="run2_trim.log" Open file Use file
	Read y
	Close file
	Set y=$Piece(y," ",12)
	if (x*pcnt)<y Write "TEST-ERROR: Too much memory used in run2; more than 10% of amount used in run1. run1: "_x_" run2: "_y,!
	Quit
