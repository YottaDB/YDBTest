#run output thru this (before unite, after inref) to filter:
#0000028660 lespaul  dincern           Mon Mar 17 12:35:27 2003 [$H = 59245, 45327]
# and
#Journal Creation Time  Mon Mar 17 13:30:25 2003 [$H = 59245, 48625]
#and
#$H = 59245, 48625 -> .H = [0-9]*,[0-9]*
#and
#Thu Mar 20 09:52:07 EST 2003
# and
#2003/04/15 10:35:49
# $ZV = ....
BEGIN { starmask = "##_STAR_##" }
{
	add_test_awk = 0
	nostar = gsub(/\*/, starmask)
	#Mon Jan 11 09:08:07 2003 [$H = 59245, 45327]
	no = gsub(/(Mon|Tue|Wed|Thu|Fri|Sat|Sun) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) ( [0-9]|[0-9][0-9]) [0-9][0-9]:[0-9][0-9]:[0-9][0-9] 20[0-9][0-9] \[\$H = [0-9]*, [0-9]*\]/,"(Mon|Tue|Wed|Thu|Fri|Sat|Sun) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) ( [0-9]|[0-9][0-9]) [0-9][0-9]:[0-9][0-9]:[0-9][0-9] 20[0-9][0-9] \[\$H = [0-9]*, [0-9]*\]");
	if (no)
	{
		if ($0 ~ /^[0-9][0-9]* [ ]*##TEST_HOST## [ ]*[a-z]* /)
			gsub(/^[0-9]* [ ]*##TEST_HOST## [ ]*[a-z]*/,"[0-9]* [ ]*##TEST_HOST## [ ]*[a-z]*")
		add_test_awk++
	}
	# VMS style date:
	# 4-APR-2003 16:36:02.19
	no = gsub(/[ 0-9][0-9]-(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)-20[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9]([0-9]|[0-9].[0-9][0-9])/,"[- 0-9A-Z]* [0-9:.]*");
	if (no)
	{
		if ($0 ~ /^[0-9A-F][0-9A-F]*[ ]* ##TEST_HOST##[ ]* [A-Z0-9]* /)
		{
			#21212739 ##TEST_HOST##   DINCERN                4-APR-2003 16:36:02 DINCERN_1       00000002 Batch  4-APR-2003 16:36:01
			$0="[0-9A-F]*[ ]* ##TEST_HOST##[ ]* [A-Z0-9]*[ ]* [-0-9A-Z]* [0-9:]* [^ ]*[ ]* [^ ]* [a-zA-Z]*[ ]* [-0-9A-Z]* [0-9:.]*"
		}
		add_test_awk++
	}
	#2003/02/19 20:18:15 [$H = 59247,73095]
	#no = gsub(/20[0-9][0-9]\/[0-9][0-9]\/( [0-9]|[0-9][0-9]) [0-9:]* .\$H = [0-9]*,[0-9]*./,"20[0-9/]* [0-9:]* ..H = [0-9,]*.");
	#if (no)
	#{
	#	#It might be of the type:
	#	#0000028660 lespaul  dincern           Mon Mar 17 12:35:27 2003 [$H = 59245, 45327]
	#	#0000016112 ##TEST_HOST##      dincern       20[0-9/]* [0-9:]* ..H = [0-9,]*.
	#	gsub(/^[0-9]* ##TEST_HOST##[.sanchez.com]*[ ]* [a-z1]*[ ]*/,"[0-9]* [ ]*##TEST_HOST## [ ]*[a-z1]* [ ]*");
	#	add_test_awk++
	#}

	#2003/04/15 10:35:49
	no = gsub(/20[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]/,"20../../.. ..:..:..")
	if (no)
		add_test_awk++

	##The date is: Thu Mar 20 09:52:07 EST 2003
	no = gsub(/^The date is:.*/,"The date is: .*")
	if (no)
		add_test_awk++

	no += gsub(/-before="[^"]*"/, "-before=\".*\"")
	no += gsub(/\/before="[^"]*"/, "\/before=\".*\"")
	no += gsub(/\/BEFORE="[^"]*"/, "\/BEFORE=\".*\"")

	no += gsub(/-since="[^"]*"/, "-since=\".*\"")
	no += gsub(/\/since="[^"]*"/, "\/since=\".*\"")
	no += gsub(/\/SINCE="[^"]*"/, "\/SINCE=\".*\"")

	no += gsub(/-after="[^"]*"/, "-after=\".*\"")
	no += gsub(/\/after="[^"]*"/, "\/after=\".*\"")
	no += gsub(/\/AFTER="[^"]*"/, "\/AFTER=\".*\"")
	if (no)
		add_test_awk++

	if ($0 ~ /(-|\/)(id|ID)=[0-9~"_,()]* /)
	{
		gsub(/-id=[^ ]*/, "-id=[^ ]*")
		gsub(/\/id=[^ ]*/, "\/id=[^ ]*")
		gsub(/\/ID=[^ ]*/, "\/ID=[^ ]*")
		add_test_awk++
	}
	if ($0 ~ /(-|\/)(resync|RESYNC)=[0-9]* /)
	{
		gsub(/-resync=[0-9]*/, "-resync=[0-9]*")
		gsub(/\/resync=[0-9]*/, "\/resync=[0-9]*")
		gsub(/\/RESYNC=[0-9]*/, "\/RESYNC=[0-9]*")
		add_test_awk++
	}
	if ($0 ~ /^Time written into /)
	{
		gsub(/:.*/,":.*");
		add_test_awk++
	}
	if ($0 ~ /\$H = [0-9]*,[0-9]*$/)
	{
		$0=".H = [0-9]*,[0-9]*"
		add_test_awk++
	}
	if ($0 ~ /^\$ZV = GT.M .*/)
	{
		$0=".ZV = GT.M .*"
		add_test_awk++
	}
	####################################
	#0000021620 beowulf.sanc dincern       2003/04/30 15:13:53 (UNIX)

	if ($0 ~ /^[0-9][0-9]*[ ]* ##TEST_HOST##[a-z\.]*[ ]* [a-z0-9]*[ ]* 20........ ..:..:..[ ]*$/)
	{
		$0 = "[0-9]*[ ]*[a-z0-9\.]*[ ]* [a-z0-9]*[ ]*20........ ..:..:..[ ]*"
		add_test_awk++;
	}
	#2180BCFC ASGARD   DINCERN      TNA102:  25-APR-2003 18:36:36 DINCERN         00000542 Remot 24-APR-2003 14:50:04
	#if ($0 ~ /^[0-9A-Z]*[ ]*##TEST_HOST##[ ]* [A-Z]* #VMS
	####################################
	if (add_test_awk)
	{
		#filter -global only if there are other expressions on the line
		if ($0 ~ /-global=/)
		{
			gsub(/-global=[^ ]*/, "-global=[^ ]*")
			add_test_awk++
		}
		if ($0 !~ /##TEST_AWK/) $0="##TEST_AWK"$0
		gsub(starmask,"\\\*") #for * characters in awk expressions
	}
	else
		gsub(starmask,"*")

	print
}
