/^[ \t]*#/   {next}

FILENAME ~ /.*test_applic/ {
   #it is very important that test_applic is processed first!!!
   no_elem=split($0,temp_array)
   
   #Add new options here(if they have default values)
   # to make all tests applicable to NON_REORG NON_REPLIC NON_TP UNNICE
   list[$1"_"$2]=ENVIRON["test_default_applicable"]
   
   #do not put test name and bucket name into list, start from 3rd field
   for (elem=3;elem<=no_elem;elem++) 
      { temp=process(temp_array[elem],"correct")
        list[$1"_"$2]=list[$1"_"$2] "#" temp
       }
   }

(FILENAME !~ /.*test_applic/) && ($0 !="") {
   # reset the env. variables for each instance
   # take list of all configurable options from environment
   #print $0
   #print "----"

   no_op = split(ENVIRON["tst_options_all"],option_names," ")
   for (ni=1;ni<=no_op;ni++)
      { x=option_names[ni]
	reverse_option_names[x]=ni
        option[ni] = "#"process(ENVIRON[ x ],"correct")
	#printf "("x"."option[x]")"
       }
   
   eliminate=0 #each test is valid until proven otherwise
   eliminate_reason=""
   #....

   #if (NF==2) {printf "this must be default\n"}

   # if ($i ~ default) def=1
   # default option, is this necessary?!!!

   LFE=ENVIRON["LFE"] 
   #print "LFE is " LFE

   for(i=3;i<=NF;i++){ 
       #print "_____"$i
       $i=process($i,"correct")
       if (process($i,"option_name")=="LFE") 
	 { #printf "found LFE" $i
	   LFE = $i
	   }
       else
       {
	  opt_name=process($i,"option_name")
	  option[reverse_option_names[opt_name]] = "#"$i
       }
       #print ".."$i " .. "option[process($i,"option_name")]
	}
   #print
   #for (ni in option) {printf ni "=" option[ni] "X"}
   #print
   test_name=$2"_"LFE
   #now check  options from applicability and convert to defaults if necessary
   if (test_name in list)
      {
      #the test is part of the standard test suite
      #print list[test_name]
      for (ni=1;ni<=no_op;ni++)
       {
       elem = option_names[ni]
       #print "pos of elem=" elem " opt=" option[ni]"...is "index(list[test_name],option[ni]) "( length is " length(list[test_name]) ")"
       #print "-----\n"test_name "\n "list[test_name] "\n" option[ni]
       if (index(list[test_name],option[ni])==0) #that option is not in applic 
	  {
	   eliminate=1	
	   eliminate_reason= eliminate_reason option[ni]
	   #warn user!!! and don't test that one 
	   #printf "__ "ni"___("option[ni]") is not in ("list[test_name]")!!!\n"
	   }
	  }
      }
      #else
      #{#printf("the test is not is applicability file, might be personal test,!!!")
      #  act accordingly!!!
      #}
   #write the outputs to a file, this file will have the name of test (and number)
   # options that are going to be effective for that instance of test
   #option[] array has the environment variables that are going to be used for that
   #instance
   #
   if (eliminate)
      print "# " test_name " is canceled because of applicability- " eliminate_reason
   else
   {
      printf $1 " " $2 " "
      #if you have to keep tst_suite env. var, update it here
      for (ni=1;ni<=no_op;ni++)
       {    gsub("#","",option[ni])
	    elem = option_names[ni]
	    #printf "__" ni "__" option[ni] 
	    #LFE is taken care of specially, do not print that out
	    if (elem != "LFE") printf " " option[ni] 

	} 
       printf " "LFE "\n"
      } 
   }

