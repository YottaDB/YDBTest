#!/usr/local/bin/tcsh -f
#
#The test performs an extrinsic function & variable calls for a long label,long named "M" routine
#
############## Extrinsic Function Section#########################
# Check <8 char label
$GTM << \gtm_eof
write $$MYLABEL^maths(3,4)
write $$CUBE^maths(11)
halt
\gtm_eof
#
# Check >8 char label
$GTM << \gtm_eof8
write $$IAMLONGLABELTOOLONGOFLENGTH31CH^maths(3,4)
halt
\gtm_eof8
#
# Check >8 char label & >8char M routine name
$GTM << \gtm_eof88
write $$IAMLONGLABELTOOLONGOFLENGTH31CH^iamalongmroutineoflengthequal31(4,3)
halt
\gtm_eof88
#
############## Extrinsic Variable Section#########################
# Check <8 char variable
$GTM << \gtm_var
write $$EXTLABEL^xvar
write $$SPLLABEL^xvar
halt
\gtm_var
#
# Check >8 char label
$GTM << \gtm_var1
write $$IAMLONGVARTOOLONGOFLENGTH31CHAR^xvar
halt
\gtm_var1
#
# Check >8 char label & >8char M routine name
$GTM << \gtm_var2
write $$IAMlONGVARTOOLONGOFLENGTH31CHAR^alongmroutineoflengthequal31iam
halt
\gtm_var2
