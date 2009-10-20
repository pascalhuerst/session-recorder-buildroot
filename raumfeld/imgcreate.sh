#!/bin/bash

#
# This is what the user of this script has to provide:
#
# - a kernel image that contains a iniramfs which mounts the ext2
#   part of the resulting image and executes /init.sh ($kernel)
# - the imgcreate utility and a path to it ($imgcreate)
# - a minimal file system that contains everything you want
#   the system to run upon start ($rootfsdir)
# - the testsuite which is copied together with the rootfs (testdir)
#
# Optionally this script takes a revision identifier as extra
# parameter. If this is unspecified a revision is created from
# the current date and time.

set -e

echo_usage() {
cat << __EOF__ >&2
Usage: $0 --target=<target>
	--platform=<platform>
	--base-rootfs-img=<base-rootfs-img>
	--target-rootfs-tgz=<target-rootfs-tgz>
	--kernel=<kernel>
	[--revision=<revision>]

__EOF__
	exit 1
}

./buildlog.sh $*

. ./getopt.inc
getopt $*

if [ -z "$target" ]		|| \
   [ -z "$platform" ]		|| \
   [ -z "$base_rootfs_img" ]	|| \
   [ -z "$kernel" ]		|| \
   [ -z "$target_rootfs_tgz" ];
then echo_usage; fi

test -z "$revision" && revision=$(date +%F-%T)

###### BUILD BINARIES #######
echo "building prerequisites ..."
make -C raumfeld/imgtool

###### CHECK PARMS #######

tmpdir=$(tempfile)-$PPID
testdir=raumfeld/testsuite/
#inputtest_bin=$testdir/input_test/input_test
imgcreate=raumfeld/imgtool/imgcreate
imginfo=raumfeld/imgtool/imginfo
resize2fs=/sbin/resize2fs

# ext2_img has to be created in binaries/ temporarily. will be removed later.
ext2_img=binaries/$target.ext2

target_img=binaries/$target-$revision.img

test -f $kernel		|| echo "ERROR: $kernel not found"
test -f $kernel		|| exit 1

test -f $rootfstgz	|| echo "ERROR: $rootfstgz not found."
test -f $rootfstgz	|| exit 1

###### CREATE THE CONTENT #######

mkdir $tmpdir
echo "Operating in $tmpdir"

cp $target_rootfs_tgz $tmpdir/rootfs.tgz
cp -a raumfeld/testsuite/rootfs/* $tmpdir/

IMG_PRIMARY_SITE=http://devel.internal/buildroot/dl
IMG_BACKUP_SITE=http://caiaq.de/download/raumfeld

test -f raumfeld/audiotest.wav || \
    for site in $IMG_PRIMARY_SITE $IMG_BACKUP_SITE; \
        do wget -P raumfeld $site/audiotest.wav && break; done

cp raumfeld/audiotest.wav $tmpdir/

# sanity check to not create unbootable images
if [ ! -f $tmpdir/$target.sh ]; then
	echo "Eeeek. $tmpdir/$target.sh does not exist. Wrong '--image' parameter!?"
	exit 1
fi

echo "exec /$target.sh \$*" > $tmpdir/start-test.sh
chmod a+x $tmpdir/start-test.sh

# count entries in rootfs.tar
tar -zf $tmpdir/rootfs.tgz -t | wc -l > $tmpdir/rootfs.tgz.numfiles

rm -f $ext2_img
genext2fs -b 1024 -x $base_rootfs_img -d $tmpdir $ext2_img

# shrink the fs to the max
$resize2fs -M $ext2_img

###### CREATE THE IMAGE #######

echo "Creating image ..."
echo "Bootstrap image for target $target" > $tmpdir/desc
date >> $tmpdir/desc
echo "Host $(hostname)" >> $tmpdir/desc

$imgcreate $kernel $tmpdir/desc $ext2_img $target_img


####### CLEANUP ########

echo "Purging $tmpdir + $ext2_img"
rm -fr $tmpdir
rm -fr $ext2_img

echo "Image ready:"
$imginfo $target_img
ls -hl $target_img

