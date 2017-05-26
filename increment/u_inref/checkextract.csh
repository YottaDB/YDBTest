#! /usr/local/bin/tcsh 
$grep -E "(100)|finalcnt" mumps.mjf >! tmpextract.txt
set index=1
while ($index < 9)
	set tmp = "^INCREMENTGV$index"
	set var1 = "^INCREMENTGV$index(100)"
	set var2 = "^finalcnt(\"$tmp\")"
	@ index = $index + 1
	$tst_awk -f $gtm_tst/$tst/inref/incrcheckjnlext1.awk -v gbl="$var1" -v gbl2="$var2" tmpextract.txt
end	
