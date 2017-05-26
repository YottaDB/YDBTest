#! /usr/local/bin/tcsh -f
@ cnt = 1
while ($cnt < 50)
$GTM << GTM_EOF
d ^test13($cnt)
GTM_EOF
@ cnt = $cnt + 1
end
touch job_"$1".txt
