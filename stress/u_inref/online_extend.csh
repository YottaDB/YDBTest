#!/usr/local/bin/tcsh -f
\touch NOT_DONE.EXTEND
$GTM << \aaa
for  h 1  q:$GET(^lasti(2,^instance))>3 
for  h 1  q:$GET(^lasti(3,^instance))>3 
for  h 1  q:$GET(^lasti(4,^instance))>3 
\aaa
@ stat = 0
@ cnt = 1
while ($cnt <= 5)
	$MUPIP extend DEFAULT
        @ stat = $stat + $status
	$MUPIP extend DREGIONNAMELONG6789012345678901 -blocks=10
        @ stat = $stat + $status
	if ($stat != 0) then
		echo "EXTEND TEST FAILED!"
		break
	endif
        @ cnt = $cnt + 1
end
@ stat = 0
@ cnt = 1
while ($cnt <= 5)
	$MUPIP extend AREG -blocks=50
        @ stat = $stat + $status
	$MUPIP extend DREGIONNAMELONG6789012345678901 -blocks=1
        @ stat = $stat + $status
	if ($stat != 0) then
		echo "EXTEND TEST FAILED!"
		break
	endif
        @ cnt = $cnt + 1
end
########################
\rm -f NOT_DONE.EXTEND
