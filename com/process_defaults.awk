#################################################################
#								#
# Copyright (c) 2019-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################
#function of process_defaults.awk:
#check_setenv(_echo)  a b        : checks if env var a is set, if unset, sets it to b
#check_setenv_valid a b          : checks if env var (option) a is valid (from values in process.awk),
#                                  and if not valid sets it to b, (assumption b is valid)
#check_number a b                : checks if env var a is a number, if not sets it to b (assumption b is a number)
#
#check_(valid/echo) echo the final value as a warning. With the assumptions, the values are "proper", i.e.
#valid option or a number.
#
#check_setenv_valid test_repl NON_REPLIC will not change test_repl if it is (NON_)REPLIC, but
#will set it to NON_REPLIC if it is not set, or is set to something else.

/^[ \t]*#/	{next}
	  { printed = 0
	    for (i=1;i<=NF;i++)
		{
		  var_name= $(i+1)
		  if ($i ~ /^check_setenv_valid$/)
			{ current_value = process(ENVIRON[var_name],"option_name")
			  $i = "setenv "
			  if (current_value == "NULL")
			    #i.e. the current value is invalid
			    { print $0
			      if (ENVIRON[var_name] != "") print "echo " var_name " is $" var_name
			     }
			  printed = 1
			 }
		  if ($i ~ /^check_setenv$/)
			{ $i = "if ( $?" var_name " == 0 ) setenv "
			  print $0
			  printed = 1
			 }
		  if ($i ~ /^check_setenv_echo$/)
			{ $i = "if ( $?" var_name " == 0 ) setenv "
			  print $0
			  print "echo " var_name " is \"$" var_name "\""
			  printed = 1
			 }
		  if ($i ~ /^check_number$/)
			{ if (ENVIRON[var_name] !~ /^[0-9\.][0-9\.]*$/)
			  { $i = "setenv "
			    print $0
			    }
			  printed = 1
			 }
		}
	  # if it is not any of the recognized actions,
	  # it might be an ordinary shell command
	  if (!printed) print $0

	  }
