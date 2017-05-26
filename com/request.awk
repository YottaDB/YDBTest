BEGIN {print "#!/usr/local/bin/tcsh -f"
       test_list_1= ENVIRON[ "test_list_1"] 
       exclude= ENVIRON["exclude_file"]
       print "\\rm -f " test_list_1
       print "touch " test_list_1
       }
/^[ \t]*#/ {next}
$0 !="" {
 if (($1 ~ "-t")||($1 ~ /[0-9]+/))
       { #it is a test
	 #if a blank is missing
	 sub("-t","-t ")
	 if ($2 in already_seen) 
	    already_seen[$2]++
	    else {
	    already_seen[$2]=1
	    }
	 #print "setenv test_" already_seen[$2] "_" $2
	 printf "echo "already_seen[$2]" "$2" "

	 gsub("-","") #to remove the dash from the options
	 for(i=3;i<=NF;i++){ 
	 # printf "setenv test_"  already_seen[$2] "_" $2 " \"\$test_" already_seen[$2] "_" $2 " " 
	  $i=process($i,"correct")
	 printf $i " " 
	 } 
	 print " >>! " test_list_1
      } 
   else if ($1 ~ "-x")
      {
       sub("-x","-x ")
       print "echo \" " $2 " \" >>!  " exclude
      }
   else #it is a shell command
      { print }
}
