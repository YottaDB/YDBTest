FILENAME~/submitted_tests/ { if (done) next;
			     if (the_test!=$2) next;
			     if (the_no!=$1) next;
			     testname= $2"_"$1
			     LFE = $3
			     option["LFE"]=LFE
			     for (i=4;i<=NF;i++)
			     option[process($i,"option_name")]=process($i,"correct")
			     for (elem in option)
			     { if (option[elem]=="")  option[elem]="@" ; 
			       else option[elem]= "#" option[elem];
			       }
			     done=1

			    } 


$1 ~ /##ALLOW_OUTPUT/ { 
		     for (i=2;i<=NF;i++) gsub("#"process($i,"correct"),"",deny)
		     next
		     }
$1 ~ /##SUSPEND_OUTPUT/ {
		       for (i=2;i<=NF;i++) deny=deny"#"process($i,"correct")
		       next
		       }
FILENAME!~/submitted_tests/ { 
			 allow=1;
			 for (elem in option)
			  {
			   #do not print out the line if one of the options is in the deny string
			   #printf deny"," option[elem] ",,,," index(deny,option[elem]) "," allow
			   #print ""
			   if (index(deny,option[elem])!=0)
			    {allow=0;
			    }
			    }
			  #print allow "  " $0
			  if (allow) print $0 
		}

