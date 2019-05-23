;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
ydb438	;
	set substr="154829319 154965468 193440695 204173403 209932114 224936551 265212792 284417672 "
        set substr=substr_"315769862 317450506 340022374 341027206 345736704 373826961 397977264 403115609 "
        set substr=substr_"408969348 414557936 443599391 472558137 486991648 497704556 500192246 520087944 "
        set substr=substr_"531940999 534499480 545251804 568820091 573990913 584631025 585786198 589920280 "
        set substr=substr_"597278425 608457999 647434494"
        for i=1:1:$length(substr," ") do locktest($piece(substr," ",i))
        quit

locktest(subs)  ;
        set name="^a("_subs_")"
        write "Attempting LOCK +",name,":0"
        LOCK +@name:0
        if $test=1  write " : SUCCESS (i.e. $test is 1 as expected)",!
        else        write " :  ----> FAILURE (i.e. $test : Actual=0 but Expected=1)",!
        quit

