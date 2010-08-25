#!/usr/bin/env bash
#
# login.sh - automagically login to the cobot captive portal
#

user_config=`pwd`/etc/user.cfg
space_config=`pwd`/etc/space.cfg

if [ ! -f $user_config ]; then
    echo "Please create a user config: ${user_config}"
    exit 1
fi

if [ ! -f $space_config ]; then
    echo "Please create a space config: ${space_config}"
    exit 1
fi


source `pwd`/etc/user.cfg
source `pwd`/etc/space.cfg

data="username=${cobot_username}&redirect_url=&auth_user=${cobot_username}${cobot_username_postfix}&accept=Log+In&account_type=${cobot_account_type}"

curl \
    -X POST -s -o /dev/null \
    -d $data \
    --data-urlencode auth_pass="${cobot_pass}" \
    $cobot_captiveportal_url
