#! /usr/local/bin/tcsh -f
# Procedure to test "r x:0"
$GTM << xyz
Do ^rx0
H
xyz
echo "exit status: $status"

