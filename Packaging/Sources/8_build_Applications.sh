#!/bin/bash

. ./versions.inc.sh

. /Developer/Makefiles/GNUstep.sh

CWD="$PWD"

### /etc/skel needs to be available before we can build Workspace.app
mkdir -p /etc/skel
cp -R ../../System/etc/skel/Library /etc/skel

cd ./Applications/ || exit 1

$MAKE_CMD clean
$MAKE_CMD install || exit 1
ldconfig

cd $CWD/nextspace-gorm.app-${gorm_version} || exit 1

$MAKE_CMD clean
$MAKE_CMD install || exit 1
ldconfig

cd $CWD/nextspace-projectcenter.app-${projectcenter_version} || exit 1

$MAKE_CMD clean
$MAKE_CMD install || exit 1
ldconfig
