#!/usr/bin/env bash
#
# login.sh - automagically login to the cobot captive portal
#

#sed -x

this_dir=$(dirname $0)

user_config="${this_dir}/etc/user.cfg"
space_config="${this_dir}/etc/space.cfg"

if [ ! -f $user_config ]; then
    echo "Please create a user config: ${user_config}"
    exit 1
fi

if [ ! -f $space_config ]; then
    echo "Please create a space config: ${space_config}"
    exit 1
fi

source $user_config
source $space_config

data="username=${cobot_username}&redirect_url=&auth_user=${cobot_username}${cobot_username_postfix}&accept=Log+In&account_type=${cobot_account_type}"
cmd="curl -X POST -w=%{response_code} -s -o /dev/null -d $data --data-urlencode auth_pass=${cobot_pass} $cobot_captiveportal_url"

response=$($cmd)

if [ "$response" = "=302" ]; then
    echo "Great success!"
    exit 0
else
    echo "Login failed."
    exit 1
fi