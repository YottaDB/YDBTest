#!/usr/local/bin/tcsh -f
#
# D9J01-002781 Return proper return code from $ZSYSTEM
#

ls froglips >& /dev/null
setenv lsrc $?
$GTM << GTM_EOF
  zsystem "ls froglips >& /dev/null"
  Set x=$lsrc
  Set y=\$ZSYSTEM
  If +x'=y zshow "*" 
  Else  Write "PASS",!
GTM_EOF

echo "End of D9J01002781 test..."
