;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

v636 ;
	; Below are subscripts that hash to the same value (0) modulo 174762
	set substr="1245014 1249732 1577809 1608559 1651844 1722298 1993080 2010388 "
	set substr=substr_"2156363 2449773 3052015 3147405 3309662 3489482 3725673 3741651 "
	set substr=substr_"3808512 3824597 3952929 4031897 4105569 4153787 4771807 4803343 "
	set substr=substr_"5099839 5143785 5220653 5517395 5581077 5669280 5763975 5912077 "
	set substr=substr_"6056069 6078819 "
	; Below are subscripts that hash to the same value modulo (174762*181)
	set substr=substr_"154829319 154965468 193440695 204173403 209932114 224936551 265212792 284417672 "
	set substr=substr_"315769862 317450506 340022374 341027206 345736704 373826961 397977264 403115609 "
	set substr=substr_"408969348 414557936 443599391 472558137 486991648 497704556 500192246 520087944 "
	set substr=substr_"531940999 534499480 545251804 568820091 573990913 584631025 585786198 589920280 "
	set substr=substr_"597278425 608457999 647434494"
	for i=1:1:$length(substr," ") do locktest($piece(substr," ",i))
	quit
locktest(sub) ;
	set name="^a("_sub_")"
	write "Attempting LOCK +",name,!
	lock +@name
