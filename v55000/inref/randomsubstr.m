;This script generates random number of substrings. The purpose of this test is to make sure that M LOCKs are managed well.
;If system error or LOCSPACEFULL error occurs, something is wrong with memory management. lespaul using V55FT04 debug fails.

randomsubstr
        for i=1:1:100000 do
        .       set xstr="lock ^x(""xyxy"""
        .       set rand=1+$r(15)
        .       for j=1:1:rand  set xstr=xstr_","_j
        .       set xstr=xstr_")"
        .       xecute xstr
	quit
