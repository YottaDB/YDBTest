#!/usr/local/bin/tcsh -f

echo "Start gtmsecshr wrapper test"
ln -s $gtm_exe/gtmsecshr ./gtmsecshr
mkdir gtmsecshrdir

cat >gtmsecshrdir/gtmsecshr <<EOF
#!/usr/local/bin/tcsh -f
echo "TEST-E-ROOTEXPLOIT -- able to execute arbitrary code as root"
/usr/bin/id
EOF

chmod +x gtmsecshrdir/gtmsecshr
setenv gtm_dist "$PWD"

# Attempt Exploit
$gtm_dist/gtmsecshr 

# Save off gtmsecshrdir

mv gtmsecshrdir gtmsecshrdir.wrapper

echo "End gtmsecshr wrapper test"
echo "Start gtmsecshr symlink test"

# Create executable with same permissions as gtmsecshr, and show whether we can run
# it as a normal user by creating a symbolic link to it called "gtmsecshr" and feeding
# it to the gtmsecshr_wrapper. In the real world, the executable could be something
# like /usr/sbin/pppd, or some other setuid executable that the user should not normally be
# able to run.
#
# This is more strict than required for an expliot; all we really need is an suid root
# executable that is not executable to the attacker. However, IGS gives us the stricter
# permissions for free, and checking the more difficult case is actually better.
# The target binary doesn't have to be called "gtmsecshr", but we don't have a simple
# way of renaming it before or after setting the permissions.

cat > not_gtmsecshr.c <<ENDC
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>

int main(int argc, char *argv[])
{
	printf("TEST-E-PRIVESCALATED, Doing something nasty as UID %d\n", (int) getuid());
	return 0;
}
ENDC

# The below uses default system make rules for *.c to executable file conversion.
# Since there isn't anything fancy going on, this is sufficient.
make not_gtmsecshr >&! make_not_gtmsecshr.out

mkdir gtmsecshrdir
cp not_gtmsecshr gtmsecshrdir/gtmsecshr

$gtm_com/IGS `pwd`/gtmsecshrdir CHOWN

mv -f gtmsecshrdir not_gtmsecshrdir

# Set up symlink to new executable

mkdir gtmsecshrdir
ln -s `pwd`/not_gtmsecshrdir/gtmsecshr gtmsecshrdir

# Attempt Exploit
$gtm_dist/gtmsecshr

# Save off gtmsecshrdir

mv gtmsecshrdir gtmsecshrdir.symlink

# Cleanup

mv -f not_gtmsecshrdir gtmsecshrdir

$gtm_com/IGS `pwd`/gtmsecshr RMDIR

echo "End gtmsecshr symlink test"
