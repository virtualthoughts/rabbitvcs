#!/usr/bin/env bash

# TODO:
# . give the script a proper usage() function

SOURCEDIR=`pwd`
if [ ! -d ${SOURCEDIR}/packages ]; then
    echo "ERROR:"
    echo "   ./packages not found."
    echo "   $0 must be run from the top level of a nautilussvn "
    echo "   working copy."
    exit 1
fi

# Get the version identifier from the nautilussvn package
PACKAGE_ID=`python -c "from nautilussvn import *;print package_identifier()"`
PACKAGE_FILE=`echo $PACKAGE_ID | tr - _`

# Cleanup
BUILDPATH=/tmp/nautilussvn_build
rm -rf $BUILDPATH
mkdir $BUILDPATH

# Export
BUILDSRC=$BUILDPATH/$PACKAGE_ID
if [ -d ${SOURCEDIR}/.svn ]; then
    svn export $SOURCEDIR $BUILDSRC
else
    cp -R $SOURCEDIR $BUILDSRC
fi

# Zip up the original source code
(cd $BUILDPATH && tar zcvf $PACKAGE_FILE.tar.gz $PACKAGE_ID)

# Copy the Debian directory into place and build the directory
cp -R $BUILDSRC/packages/ubuntu/debian/ $BUILDSRC/debian
(cd $BUILDSRC && debuild)
