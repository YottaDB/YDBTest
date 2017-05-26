# use as: awk -f $gtm_test/V971_nm/com/process.awk -f $gtm_test/V971_nm/com/determine_test_num.awk $gtm_test/V971_nm/com/determine_test_num.txt sub_temp1

BEGIN	{
		if (unix)
		{
			all_options = ENVIRON["tst_options_all"]
			process_options()
		}
	}
# for VMS
FILENAME ~ /all_options.txt/ {
		all_options = $0
		process_options()
	}
FILENAME ~ /determine_test_num.txt/ {
		if ($1 ~ /MAXDEF/)
			maxdef = $2
		if ($1 ~ /^[ 	]*#/)	#skip comment lines
			next
		if ($0 ~ /^[ 	]*$/)	#skip empty lines
			next
		x = $1
		$1 = ""
		num[subsc($0)] = x
		# if we need to calculate, use one as the default
		if ("" == one)
			one = subsc($0)
	}
FILENAME ~ /submit_tests/ {
		# no harm in correcting once more:
		testname = $2
		$1 = ""
		$2 = ""
		restofline=$0
		$NF=""
		#print ">>>" subsc($0)
		#for (i in num)
		#print i " " num[i]
		if ("" != num[subsc($0)])
		{
			# we found this configuration in the list of common configurations (determine_test_num.txt)
			print num[subsc($0)] " " testname " " restofline
			next
		}
		else
		{
			# this isn't a common configuration, calculate
			count = split($0,optar," ")
			x = 1
			testnum = maxdef + 1
			for (i = 1; i <= count; i++)
			{
				if (one !~ ","optar[i])
					testnum=testnum+x
				x = x * 2
			}
			print testnum  " " testname " "restofline

		}
	}
function process_options()
	{
		no_op = split(all_options, option_names, " ")
		# e.g. option_names[1] = "test_gtm_gtcm"
		#flip array, e.g. indx["test_gtm_gtcm"] = 1
		for (i in option_names)
			indx[tolower(option_names[i])] = i
	}
# sorts the options in the same order, and creates a string (to be used as a subscript)
function subsc(line,oput,mpar1,tmpar2)
	{
		no_tmpar = split(line, tmpar1, " ")
		for (i = 1; i <= no_tmpar; i++)
		{
			tmpar2[indx[tolower(process(tmpar1[i], "option_name"))]]=process(tmpar1[i], "correct")
		}
		#for (i in tmpar2)
		#	print i " " tmpar2[i]
		for (i = 1; i <= no_tmpar; i++)
			oput = oput "," tmpar2[i]
		return oput
	}
