#!/usr/local/bin/tcsh -f
#
# Verify large piece or byte numbers in SET $PIECE and SET $EXTRACT respectively
# create the proper error message instead of blowing up
#

$gtm_dist/mumps -dir <<EOF
Set pnum=4294967295+110011
Set \$Piece(x,"|",pnum)="This is a test"
EOF

$gtm_dist/mumps -dir <<EOF
Set pnum=4294967295+110011
Set \$ZPiece(x,"|",pnum)="This is a test"
EOF

$gtm_dist/mumps -dir <<EOF
Set bnum=4294967295+110011
Set \$Extract(x,bnum)="*"
EOF

$gtm_dist/mumps -dir <<EOF
Set bnum=4294967295+110011
Set \$ZExtract(x,bnum)="*"
EOF
