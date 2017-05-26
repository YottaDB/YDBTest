#
# Awk to extract certain key fields from a gtmpcat output file. Used to verify various
# components of unlink operation.
#

BEGIN	\
{
	rtncnt = 0		# Routine count 
	rtnshbytes = 0		# Shared routine code bytes
	rtnunshbytes = 0	# Unshared routine code bytes
	cntdstackfrms = 0	# Number of counted stack frames
	storpcs = 0		# Allocated pieces of storage
	storbytes = 0		# Allocated bytes of storage
	shlibloaded = 0		# 1 if gtmunlnklib1 shared lib is loaded
}

# Count of routines
/^   Total of [0-9]+ routines linked/		\
{
	rtncnt = $3
	rtnshbytes = $7
	rtnunshbytes = $11
}

# Count of stack frames
/^   Total of [0-9]+ counted stackframes/	\
{
	cntdstackfrms = $3
}

# Storage pieces allocated
/^   Total of [0-9]+ storage pieces allocated/	\
{
	storpcs = $3
	storbytes = $11
}

# Is gtmunlnklib1 shared library loaded?
/gtmunlnklib1/					\
{
	shlibloaded = 1
}

END	\
{
	print rtncnt, rtnshbytes, rtnunshbytes, cntdstackfrms, storpcs, storbytes, shlibloaded
	if ((0 == rtncnt) || (0 == cntdstackfrms) || (0 == storpcs) || (0 == storbytes) ||
	    ((0 == rtnshbytes) && (0 == rtnunshbytes)))
	{
		print "Incomplete gtmpcat output file - too many values zeroed"
		exit 1
	}
}
