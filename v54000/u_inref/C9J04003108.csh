#!/usr/local/bin/tcsh -f
#
# C9J04-003108 - Verify $ECODE/$STACK() save/restore works across a $ZINTERRUPT.

$GTM << EOF
  DO ^C9J04003108
EOF
