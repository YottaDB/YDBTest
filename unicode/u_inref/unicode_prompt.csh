#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
$GTM << \aaa
set a=1
write "Before $zprompt change",!
set $zprompt="豈羅爛來祿屢讀數>"
write "After $zprompt change",!
write "Before $zprompt change",!
set $zprompt="α β γ  δ ε"
write "After $zprompt change",!
halt
\aaa
