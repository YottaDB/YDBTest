#!/usr/local/bin/tcsh -f
#
################ grepfile.csh usage ##################
# grepfile.csh <pattern> <filename> <0/1>
# pattern and file name has its usual meaning.
# The third parameter: 0 - if the pattern is NOT expected to be in the file
#                      1 - if the pattern is expected in the file
#####################################################
#
if ($# != 3) then
  echo "GREPFILE-E-ERROR, invalid number of arguments"
  exit
endif

if ($3 == 0) then
  @ case = 1
  set pass = "is not present"
  set fail = "is present"
else if($3 == 1) then
  @ case = 0
  set pass = "is present"
  set fail = "is not present"
else
  echo "GREPFILE-E-ERROR, unrecognised third parameter"
  exit
endif

$grep "$1" $2 >>&! /dev/null
set opstat = $status
if ($opstat == 2) then 
 echo "GREP-E-ERROR, check file name"
else if ($opstat == $case) then
 echo "$1 $pass in the file $2"
else
 echo "GREPFILE-E-ERROR, $1 $fail in the file $2"
endif
