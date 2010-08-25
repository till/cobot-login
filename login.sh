#!/usr/bin/env bash
#
# login.sh - automagically login to the cobot captive portal
#

source `pwd`/etc/user.cfg
source `pwd`/etc/space.cfg

data="username=${cobot_username}&redirect_url=&auth_user=${cobot_username}${cobot_username_postfix}&accept=Log+In&account_type=${cobot_account_type}"

curl \
    -X POST -s -o /dev/null \
    -d $data \
    --data-urlencode auth_pass="${cobot_pass}" \
    $cobot_captiveportal_url
