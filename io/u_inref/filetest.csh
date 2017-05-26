
## the echo below is necessary due to the TR:
##;;;C9E02-002527 $ZEOF maintenance for a null input device
$switch_chset M >&! /dev/null
echo "C9E02-002527" | $gtm_dist/mumps -run filetest >&! filetest_out.txt

# change permissions of all *.txt files so that they can be managed
chmod +w *.txt

sed 's/.*GTM$DMOD[ 	]*(Direct mode)/##Direct mode##/g' filetest_out.txt
