c001953	;
	; series of tests to test the fixes/optimizations done to the pattern match code as part C9C03-001953.
	; the goal of this project was to try and get every pattern evaluation to not exceed 1 second across all platforms.
	; although the goal seems ambitious, it did succeed on high end linux machines and almost succeeded on the others.
	; the worst time that any test case took across all platforms including Unix and VMS was 6 seconds or so.
	; this is a major improvement considering the fact that it used to take ages (not sure how many days) earlier.
	; towards the goal, the set of disabled pattern match tests in the MVTS test suite were tried one by one and any
	; 	pathological cases that arise on the way were addressed.
	; the test cases below represent a history of the progress in this change request.
	;
	do init^genutfchar
	write !,"----TEST1 ----",!  d TEST1
	write !!,"----TEST2 ----",!  d TEST2
	write !,"----TEST3 ----",!  d TEST3
	write !,"----TEST4 ----",!  d TEST4
	write !!,"----TEST5 ----",!  d TEST5
	write !!,"----TEST6 ----",!  d TEST6
	write !!,"----TEST7 ----",!  d TEST7
	quit

TEST1	;
	; following used to accvio in the code due to a bug in patstr in terms of maintaining alt_active state.
	; instead of detecting the comma separator being used in 5,8 below instead of the period '.' and erroring out,
	;	the compiler used to accvio
	; to avoid the compilation error, we use xecute and print $zstatus to write the error detail
	;
	;do genutfstrkill^genutfchar	; reset %genutfstrchar array
	set str="a"
	set oldstr=str,str=$$genutfstr^genutfchar(str)
	zshow "v":^state("TEST1") ; store random data in case needed for debugging
	set $zt="write !,$zstatus zgoto $zlevel-1"
	set xstr="write !,str?1(1l,1u) write !,str?5,8(1(1l,1u),2(3l,4u))"
	xecute xstr
	quit

TEST2	;
	; check that 1.10(4.5L) is not considered equivalent to 4.50L
	; earlier code used to return "success" match when x was of length 6L, 7L, 11L which is incorrect.
	; it was doing that because it was optimizing nested alternation containing 1 atom in cases
	;	where the outer minimum was 1. that is not correct. 
	; a fix was done so that the optimization is done only if 
	;	 => the inner lower limit is 0 or 1
	;	 => or the outer lower limit equals the outer upper limit
	; see do_patstr.c for comments on why the above optimization is valid.
	;
	do genutfstrkill^genutfchar	; reset %genutfstrchar array
	set origstr="abcdefghijkl"
	set oldorigstr=origstr,origstr=$$genutfstr^genutfchar(origstr)
	zshow "v":^state("TEST2") ; store random data in case needed for debugging
	for i=4:1:12  do
	.	set str=$extract(origstr,1,i)
	.	write str?1.10(4.5L),!
	quit

TEST3	;
	; the following used to give false result for x="abcdef" to x="abcdefghi".
	; although it is not clear what was the buggy code in the earlier version of do_patalt() 
	;	that caused this, there was a rewrite of do_patalt() done on parts that were not
	;	understandable to me (nars) and with that rewrite this problem disappeared
	;	and hence i didn't spend the time investigating how the earlier buggy code could
	;	cause this problem.
	;
	do genutfstrkill^genutfchar	; reset %genutfstrchar array
	set origstr="abcdefghijklmnopqrstuvwxyz"
	set oldorigstr=origstr,origstr=$$genutfstr^genutfchar(origstr)
	zshow "v":^state("TEST3") ; store random data in case needed for debugging
	for i=4:1:26  do
	.	set str=$extract(origstr,1,i)
	.	write str?5.8(1(1l,1u),2(3l,4u)),!
	quit

TEST4	;
	; the following used to take a long time (nearly a minute) earlier. 
	; it was because there was no intelligence built in to detect the following.
	; say the first do_patalt() call matches a substring the beginning of the input string "a" 
	;	with the first alternation choice 1l
	; say the recursive second do_patalt() call then matches a substring of the now beginning 
	;	input string "b" with the first alternation choice 1l again
	; the recursively called third do_patalt() now can be rest assured that the remaining string
	;	can't be matched by the alternation. This is because it has only 11 chances left
	;	(note the maximum is .13) and each time the maximum length it can match is 2 (the
	;	maximum length of all the alternation choices which is 2l) which leaves it with a
	;	maximum of 22 characters while there are still 24 characters left in the input-string.
	; this optimization can cause a backtracking to occur at the 3rd level of call to do_patalt()
	;	instead of going through the call trace 13 times and then determining at the leaf level
	; since the at each level, the choices examined are 6, we are saving nearly (6 to the power of 11)
	;	choice examinations (11 for the levels that we avoid with the optimization) 
	;	which is quite a lot.
	; with this optimization it now takes less than a second to evaluate the below expression.
	;
	do genutfstrkill^genutfchar	; reset %genutfstrchar array
	set origstr="abcdefghijklmnopqrstuvwxyz"
	set oldorigstr=origstr,origstr=$$genutfstr^genutfchar(origstr)
	set str=origstr
	zshow "v":^state("TEST4") ; store random data in case needed for debugging
	write str?.13(1l,1e,1n,1u,1p,2l)
	quit

TEST5	;
	; the following used to take ages (at least 1 day of CPU time) to complete.
	; this was because it was recursing on do_patalt() upto a depth of PAT_MAX_REPEAT (32767)
	;	trying to match each depth on the null-string "" since that was the minimum length
	;	and the algorithm goes from minimum length to maximum length trying to match each one.
	; to cure this, an optimization was introduced to try out the null string option for matching
	;	only if we have nothing left to match in the input string and that we haven't yet 
	;	exhausted our minimum alternation string count. With this optimization, the runtime
	;	decreased to 8 seconds or so.
	; of course now with a lot of other optimizations introduced, the runtime for this is less than a second.
	;
	do genutfstrkill^genutfchar	; reset %genutfstrchar array
	set str="AAAAaaAAaaAAAA"
	set oldstr=str,str=$$genutfstr^genutfchar(str)
	set patstrL="a",oldpatstrL=patstrL,patstrL=$$genutfstr^genutfchar(patstrL)
	set patstrU="A",oldpatstrU=patstrU,patstrU=$$genutfstr^genutfchar(patstrU)
	set xstr="write str?4.(.3"""_patstrL_""",3."""_patstrU_""")"
	zshow "v":^state("TEST5",1) ; store random data in case needed for debugging
	xecute xstr
	do genutfstrkill^genutfchar	; reset %genutfstrchar array
	set str="ABCDABCDABCDABCDabcdabcdABCDABCDabcdabcdABCDABCDABCDABCD"
	set oldstr=str,str=$$genutfstr^genutfchar(str)
	set patstrL="abcd",oldpatstrL=patstrL,patstrL=$$genutfstr^genutfchar(patstrL)
	set patstrU="ABCD",oldpatstrU=patstrU,patstrU=$$genutfstr^genutfchar(patstrU)
	set xstr="write !,str?4.(.3"""_patstrL_""",3."""_patstrU_""")"
	zshow "v":^state("TEST5",2) ; store random data in case needed for debugging
	xecute xstr
	quit

TEST6	;
	; the following M program segment used to take nearly 15 minutes on a high end machine.
	; investigating this showed up a curiously interesting phenomenon.
	; the new alternation code was examining choices, and in the process, 
	;	seems to frequently re-examine the same	choices for matches.
	; experiments on this program showed that almost 99% of the choices were being re-examined for matches.
	; this is what triggered a series of optimization changes wherein we cache the evaluation result of a pattern match.
	; for a given <strptr, strlen, patptr, depth> tuple, we store the evaluation result.
	; in the above, 
	;	<strptr, strlen>	uniquely identifies a substring of the input string.
	; 	<patptr>		identifies the pattern atom that we are matching with
	;	<depth>			identifies the recursion depth of do_patalt() for this pattern atom ("repcnt" in code)
	; note that <depth> is a necessity in the above because the same alternation pattern atom can have different 
	;	match or not-match status for the same input string depending on the repetition count usage of the pattern atom
	; after a series of thoughts on an efficient structure for storing pattern evaluation, finally arrived at a simple
	;	array of structures wherein for a given length (strlen) we have a fixed number of structures available.
	; we allocate an array of structures, say, 1024 structures.
	; this is a simple 1-1 mapping, wherein 
	;	for length 0, the available structures are the first 32 structures of the array, 
	;	for length 1, the available structures are the second 32 structures of the array.
	;	...
	;	for length 47, the available structures are the 47th 32 structures of the array.
	;	for length 48 and above, the available structures are all the remaining structures of the array.
	; whenever any new entry needs to be cached and there is no room among the available structures, we preempt the 
	;	most unfrequently used cache entry (to do this we do keep a count of every entry's frequency of usage)
	; the assumption is that substrings of length > 48 (an arbitrary reasonable small number) won't be used 
	;	so frequently so that they have lesser entries to fight for among themselves than lower values of length.
	; with the above caching in place, the program segment below took 15 seconds.
	; it was found that if the array size is increased to 16384 (as opposed to 1024 as above) and the available 
	;	structures for each length increased proportionally (i.e. 16 times = 16*32 structures instead of 32 as above)
	;	the performance improved to the extent of taking 3 seconds.
	; but this raised an interesting question, that of "size" vs. "time" tradeoff.
	; with increasing array size, we get better "time" performance due to better caching.
	; but that has an overhead of increased "size" (memory) usage.
	; to arrive at a compromise, a dynamic algorithm emerged. the process will allocate a small array
	;	beginning at 1024 entries and grow to a max of 16384 entries as and when it deems the hit ratio is not good.
	; the array only grows, i.e. there is no downsizing algorithm at play.
	; the dynamic algorithm addresses to an extent both the "size" and "time" issues and finishes the below in 1 second.
	;
	do genutfstrkill^genutfchar	; reset %genutfstrchar array
	set x="35646413231--AABABABABABABABABABabababAAA89-1-1879HJABABAB89909999AAAAAAAAAAACCCCCCCCCCCCCC"
	set oldx=x,x=$$genutfstr^genutfchar(x)
	;
	; We are now using substituted characters in the pattern string. If we pass a "-", it could be substituted by
	; any other punctuation character including a double-quote. A double-quote needs special handling. It should be
	; returned as two double-quotes as we use this below to construct "xstr" which is later xecuted. We indicate
	; this to $$genutfstr^genutfchar through the optional second parameter which is set to 1. It needs to be
	; set to 1 wherever we pass a literal containing a punctuation character as part of the pattern string.
	;
	set patstr1="-",oldpatstr1=patstr1,patstr1=$$genutfstr^genutfchar(patstr1,1)
	;
	set patstr2="AB",oldpatstr2=patstr2,patstr2=$$genutfstr^genutfchar(patstr2)
	set patstr3="ab",oldpatstr3=patstr3,patstr3=$$genutfstr^genutfchar(patstr3)
	set patstr4="AA",oldpatstr4=patstr4,patstr4=$$genutfstr^genutfchar(patstr4)
	;
	set patstr5="-1",oldpatstr5=patstr5,patstr5=$$genutfstr^genutfchar(patstr5,1)
	;
	set patstr6="A",oldpatstr6=patstr6,patstr6=$$genutfstr^genutfchar(patstr6)
	set patstr7="B",oldpatstr7=patstr7,patstr7=$$genutfstr^genutfchar(patstr7)
	set patstr8="C",oldpatstr8=patstr8,patstr8=$$genutfstr^genutfchar(patstr8)
	set xstr="write x?1.3(.N,2"""_patstr1_""",.2A).5(."""_patstr2_""",."""_patstr3_""",1"""_patstr4_""",1"""_patstr3_""")2.4(.4AN,1.3AP,1E,2"""_patstr5_""")4.(3.9"""_patstr2_""",3.5AN).5(1."""_patstr6_""",1."""_patstr7_""",1."""_patstr8_""")"
	zshow "v":^state("TEST6",1) ; store random data in case needed for debugging
	xecute xstr
	;
	do genutfstrkill^genutfchar	; reset %genutfstrchar array
	set x="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	set oldx=x,x=$$genutfstr^genutfchar(x)
	set patstr="AA",oldpatstr=patstr,patstr=$$genutfstr^genutfchar(patstr)
	set xstr="write !,x?.5(2.A,2"""_patstr_""")"
	zshow "v":^state("TEST6",2) ; store random data in case needed for debugging
	xecute xstr
	;
	do genutfstrkill^genutfchar	; reset %genutfstrchar array
	set x="AAAAAAAA]]]]]]]]]]444444444]]]]]]]]]AA===4444444444\\\\\\0000000======"
	set oldx=x,x=$$genutfstr^genutfchar(x)
	set xstr="write !,x?3.10(2.AN,4.P)"
	zshow "v":^state("TEST6",3) ; store random data in case needed for debugging
	xecute xstr
	quit
 
TEST7	;
	; even with all these optimizations at play, the following testcase was noticed which offered an interesting scenario.
	; the input string consists of three substrings x1,x2,x3 and 4 pattern substrings p11,p12,p2,p3.
	; 	x1 matches p11_p12
	; 	x2 matches p2
	; 	x3 matches p3
	;
	; (a) x1?p11_p12 matched in a second 
	; (b) x2?p2 matched instantaneously
	; (c) x3?p3 matched in less than a second
	;
	; but (x1_x2_x3)?(p11_p12_p2_p3) took nearly 3 to 8 seconds to match
	; there is no reason why the above pattern should take any longer than the maximum time taken for (a), (b), (c) above.
	; this is because once we find that p2 (a fixed length pattern) matches only the substring x2 in the whole string,
	;	we need to just individually match p11_p12 with x1 and p3 with x3.
	; but instead what was happening was that do_pattern() was trying different choices for p11_p12 (through do_patalt())
	;	and for each of those, trying different choices for p2 and in turn for p3.
	; this effectively causes a runtime exponentially (rather than linearly) proportional to the number of pattern atoms 
	; do_pattern() was failing to take advantage of the fact that p2 was a fixed length pattern and hence fixating
	;	that in the input string restricts the number of choices that we have to examine for p1 and p3.
	; the above analysis led to another optimization which is termed the "divide and conquer" optimization.
	; using this optimization, the input pattern would be scanned at runtime to determine the fixed length sub pattern atom
	;	that is closest to the median of the pattern atoms.
	; the input pattern would then be split into three, left, fixed and right. 
	; do_pattern() would try to match the fixed pattern atom with the input string and for each match case,
	;	will try to match the left and right input substrings with the left and right pattern
	; a new routine do_patsplit() was created to achieve exactly this. 
	; it has additional optimizations to try match the fixed length pattern in a restricted subset of the input string
	;	taking into account the min and max of the left and the right pattern.
	; with the above optimization, the runtime for the below segment was 0.35 seconds on average.
	; here ends the pattern optimization exploration.
	;
	do genutfstrkill^genutfchar	; reset %genutfstrchar array
	set x1="35646413231--AABABABABABABABABABabababAAA89-1-1879HJABABAB89909999AAAAAAAAAAACCCCCCCCCCCCCC"
	set x2=" "
	set x3="AAAAAAAAABBBBBBBBBBBBB=----------="
	set x=x1_x2_x3
	set oldx=x,x=$$genutfstr^genutfchar(x)
	;
	;
	set patstr1="-",oldpatstr1=patstr1,patstr1=$$genutfstr^genutfchar(patstr1,1)
	;
	set patstr2="AB",oldpatstr2=patstr2,patstr2=$$genutfstr^genutfchar(patstr2)
	set patstr3="ab",oldpatstr3=patstr3,patstr3=$$genutfstr^genutfchar(patstr3)
	set patstr4="AA",oldpatstr4=patstr4,patstr4=$$genutfstr^genutfchar(patstr4)
	;set patstr5="-1",oldpatstr5=patstr5,patstr5=$$genutfstr^genutfchar(patstr5)
	set patstr6="A",oldpatstr6=patstr6,patstr6=$$genutfstr^genutfchar(patstr6)
	set patstr7="B",oldpatstr7=patstr7,patstr7=$$genutfstr^genutfchar(patstr7)
	set patstr8="C",oldpatstr8=patstr8,patstr8=$$genutfstr^genutfchar(patstr8)
	set patstr9=" ",oldpatstr9=patstr9,patstr9=$$genutfstr^genutfchar(patstr9,1)
	;
	set patstr10="-1",oldpatstr10=patstr10,patstr10=$$genutfstr^genutfchar(patstr10,1)
	;
	set p11="1.3(.N,2"""_patstr1_""",.2A).5(."""_patstr2_""",."""_patstr3_""",1"""_patstr4_""",1"""_patstr3_""")"
	set p12="2.4(.4AN,1.3AP,1E,2"""_patstr10_""")4.(3.9"""_patstr2_""",3.5AN).5(1."""_patstr6_""",1."""_patstr7_""",1."""_patstr8_""")"
	set p2="1"""_patstr9_""""
	set p3=".4(1."""_patstr6_""",1."""_patstr7_""",1."""_patstr8_""",1.13AP)"
	set p=p11_p12_p2_p3
	;
	set str="write x?"_p_",!"
	zshow "v":^state("TEST7",1) ; store random data in case needed for debugging (added to help in debugging SPOREOL error)
	xecute str
	quit

