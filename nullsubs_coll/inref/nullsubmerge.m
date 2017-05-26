nullsubmerge ;
;	test of merge scenarios among globals & locals with different null_sub values
;	we maintain different label sections here,though the code remains the same,
;	as to make it easy while analysing the outfile with various write comments.
;
setglobals;
	set ^aregionglobal=(1)=1
	set ^aregionglobal(1,"")="iam A null"
	set ^aregionglobal(1,"",1)=11
	set ^bregionglobal(2)=2
	set ^bregionglobal(2,"")="iam B null"
	set ^bregionglobal(2,"",1)=22
	set ^cregionglobal(1)=33
	set ^cregionglobal(1,2)=333
	set ^defaultregion(1)=44
	set ^defaultregion(1,2)=55
	set ^beginwithnull("")="null"
	set ^beginwithnull("",1)="null1"
	set ^beginwithnull("",2)="null2"
	set ^beginwithnull("",1,"abc")="null1str"
	quit
;
neverglobal;
	write "Merging global1 (NEVER) with global2 (NEVER) should pass",!!
	merge ^defaultregion(1)=^cregionglobal(1)
	zwrite ^defaultregion
;
	write "Merging global1 (NEVER) with global2 (ALWAYS) should pass,since no descendants",!!
	merge ^defaultregion(1)=^bregionglobal(2,"",1)
	zwrite ^defaultregion
;
	write "Merging global1 (NEVER) with local (without null_subs) should pass",!!
	merge ^defaultregion(1)=lcl(2)
	zwrite ^defaultregion
	quit
;
error1neverglobal;
	write "Merging global1 (NEVER) with global2 (ALWAYS) should error out",!!
	merge ^defaultregion(1)=^bregionglobal(2)
	zwrite ^defaultregion
	quit
;
error2neverglobal;
	write "Merging global1 (NEVER) with global2 (EXISTING) should error out",!!
	merge ^defaultregion(1)=^aregionglobal(1)
	zwrite ^defaultregion
	quit
;
error3neverglobal;
	write "Merging global1 (NEVER) with local (with null_subs) should error out",!!
	merge ^defaultregion(1)=lcl(1)
	zwrite ^defaultregion
	quit
;
alwaysglobal;
	set ^defaultregion(1,"",1)=999
	write "Merging global1 (ALWAYS) with global2 (NEVER) should pass",!!
	merge ^defaultregion(1)=^cregionglobal(1)
	zwrite ^defaultregion
;
	write "Merging global1 (ALWAYS) with global2 (ALWAYS) should pass",!!
	merge ^defaultregion(1)=^bregionglobal(2,"")
	zwrite ^defaultregion
;
	write "Merging global1 (ALWAYS) with global2 (EXISTING) should pass",!!
	merge ^defaultregion(1)=^aregionglobal(1,"")
	zwrite ^defaultregion
	merge ^defaultregion(1,"",1)=^aregionglobal(1,"")
	zwrite ^defaultregion

	write "Merging global1 (ALWAYS) with local (with null_subs) should pass",!!
	merge ^defaultregion(1)=lcl(1,"")
	zwrite ^defaultregion

	write "Merging global1 (ALWAYS) with local (without null_subs) should pass",!!
	merge ^defaultregion(1)=lcl(1)
	zwrite ^defaultregion
	quit
;
allowexistglobal;
	write "Merging global1 (EXIST) with global2 (NEVER) should pass",!!
	merge ^defaultregion(1)=^cregionglobal(1)
	zwrite ^defaultregion
;
	write "Merging global1 (EXIST) with global2 (ALWAYS) should pass as global2 has no null_sub descendants",!!
	merge ^defaultregion(1)=^beginwithnull("")
	zwrite ^defaultregion
	quit
;
error1;
	write "Merging global1 (EXIST) with global2 (NEVER) should error out as LHS contains null_subs",!!
	merge ^defaultregion(1,"",1)=^cregionglobal(1)
	zwrite ^defaultregion
	quit
;
error2;
	write "Merging global1 (EXIST) with global2 (ALWAYS) should error out with source global having descendant null subs",!!
	merge ^defaultregion(1)=^bregionglobal(2)
	zwrite ^defaultregion
	quit
error2sub;
	write "Merging global1 (EXIST) with global2 (ALWAYS) should error out as merging with destination global's null subs",!!
	merge ^defaultregion(1,"")=^bregionglobal(2,"")
	zwrite ^defaultregion
	quit
;
error3;
	write "Merging global1 (EXIST) with global2 (ALWAYS) should error out with source global having descendant null subs",!!
	merge ^defaultregion(1)=^aregionglobal(1)
	zwrite ^defaultregion
	quit
error3sub;
	write "Merging global1 (EXIST) with global2 (ALWAYS) should error out as merging with destination global's null subs",!!
	merge ^defaultregion(1,"")=^aregionglobal(1,"")
	zwrite ^defaultregion
	quit
;
error4;
	write "Merging global1 (EXIST) with local should error out with source having descendant null subs",!!
	merge ^defaultregion(1)=lcl(1)
	zwrite ^defaultregion
	quit
;
error5;
	write "Merging global1 (EXIST) with local should error out as merging with destination global's null subs",!!
	merge ^defaultregion(1,"")=lcl(2)
	zwrite ^defaultregion
	quit
;
