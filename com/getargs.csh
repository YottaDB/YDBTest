# Note that this script should only be sourced from another tcsh-script for the variable settings to be visible to the caller.
# expects opt_array and opt_name_array to contain the respective qualifiers and variable-names to fill in the qualifier parameters.

unset getargs_error
set noglob	# to prevent filename expansion or substitution in parameters from happening
set cluster_list   = ""
set arguments_list = ""
set print_help = `echo "$argv" | awk '/-h.*/ {print "1"}'`
set arguments_for  = "dummy_args"
@ argindex = 1
foreach arg ($argv dummy) # last is a dummy argument
	@ index = 1
	while ($index <= $#opt_array)
		if ((\\$arg =~ $opt_array[$index]) || ("$arg" == "dummy")) then
			if ("$arguments_list" != "" && "$cluster_list" != "") then
				foreach arguments_for ($cluster_list)
					set $arguments_for = "$arguments_list"
				end
				set cluster_list = ""
			else
				set $arguments_for = "$arguments_list"
			endif
			set arguments_list = ""
			set skip
			if ("$arg" == "dummy") break
			set arguments_for  = "$opt_name_array[$index]"
			if ($?opt_index_array) then
				set opt_index_array[$index] = $argindex
			endif
			if ($print_help) then 
				if ($?opt_scripts) then
					if ("$opt_scripts[$index]" != "0") $cms_tools/$opt_scripts[$index] -help
				endif
			endif
			if ($?opt_cluster_array) then
				if ($opt_cluster_array[$index] == 1) then
					set cluster_list = "$cluster_list $opt_name_array[$index]"
				else
					# reset the cluster-list once you see a non-clusterable qualifier
					set cluster_list = ""
				endif
			endif
			break
		endif
		@ index = $index + 1
	end
	if ($index > $#opt_array) then	# didn't find any match
		if !($?skip) then
			echo "GETARGS-E-ARG Error in first argument : $arg : was expecting a valid qualifier"
			set getargs_error = 1
			exit 5
		endif
		if ("$arguments_list" == "") then
			set arguments_list = "$arg"
		else
			set arguments_list = "$arguments_list $arg"
		endif
	endif
	@ argindex = $argindex + 1
end
unset noglob	# to re-enable filename expansion or substitution in parameters from happening
