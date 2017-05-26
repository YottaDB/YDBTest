#!/usr/local/bin/tcsh -f

# This script is to disable the environment variables related to huge pages testing
# This script should be "source"d in test/subtests that requires the feature to be disabled

unsetenv HUGETLB_MORECORE
unsetenv HUGETLB_SHM
unsetenv HUGETLB_VERBOSE
unsetenv LD_PRELOAD
