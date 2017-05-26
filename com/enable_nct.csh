#!/usr/local/bin/tcsh -f
$GTM << \aaa   > nct.log
w $$set^%GBLDEF("^a",1,0)
w $$set^%GBLDEF("^b",1,0)
w $$set^%GBLDEF("^c",1,0)
w $$set^%GBLDEF("^d",1,0)
w $$set^%GBLDEF("^e",1,0)
w $$set^%GBLDEF("^f",1,0)
w $$set^%GBLDEF("^g",1,0)
w $$set^%GBLDEF("^h",1,0)
w $$set^%GBLDEF("^i",1,0)
\aaa
