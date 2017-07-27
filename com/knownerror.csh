#!/usr/local/bin/tcsh -f
#
# $1 = file to search in
# $2 = pattern to search for and filter out
#

mv $1 {$1}x
$grep -vE "$2" {$1}x >&! $1

