# Tests the following IO errors:
#RMWIDTHTOOBIG <File record size too big>
# In the future, enhance it to test all IO errors.
# Some of the commands here will not give errors, but will error in VMS. They are here for completeness
# and to see that they do not error.

$switch_chset M >&! /dev/null
$GTM << EOF
set file1="example_1.txt"
set file2="example_2.txt"
set file3="example_3.txt"
set file7="example_7.txt"
do open^io(file1,"NEWVERSION:RECORDSIZE=100000")
do showdev^io(file1)
do open^io(file1,"NEWVERSION:RECORDSIZE=1000000:BIGRECORD")
do showdev^io(file1)
do open^io(file1,"NEWVERSION:RECORDSIZE=5000")
do showdev^io(file1)
close file1
do open^io(file2,"NEWVERSION:RECORDSIZE=50000000")
do showdev^io(file2)
do open^io(file2,"NEWVERSION:RECORDSIZE=1000000")
do open^io(file2,"NEWVERSION:BIGRECORD:RECORDSIZE=1000000")
do showdev^io(file2)
close file2
do open^io(file3,"NEWVERSION:BIGRECORD:RECORDSIZE=1048576")
do showdev^io(file3)
close file3
do open^io(file7,"BADDEVPARAM")
halt
EOF


