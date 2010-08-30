#!/usr/bin/env bash
#
# login.sh - automagically login to the cobot captive portal
#

#sed -x

this_dir=$(dirname $0)

user_config="${this_dir}/etc/user.cfg"
space_config="${this_dir}/etc/space.cfg"

if [ ! -f $space_config ]; then
    echo "Please create a space config: ${space_config}"
    exit 1
fi


if [ `uname -s` = "Linux" -o `uname -s` = "FreeBSD" -o `uname -s` = "NetBSD" -o `uname -s` = "OpenBSD" ]; then

    if [ ! -f $user_config ]; then
        echo "Please create a user config: ${user_config}"
        exit 1
    fi

    source $user_config

elif [ `uname -s` = "Darwin" ]; then

    echo "Use the keychain! Not yet implemented."
    exit 1;

else

    # do something else
    echo "Unknown OS: $(uname -s)" 
    exit 1

fi

source $space_config

discoverCaptivePortal () {
    local url=$(curl -w=%{redirect_url} -o /dev/null -s -I http://www.google.de/)

    if [ "$url" = "=" ]; then
        echo ""
    fi

    echo "${url:1}"
}

cobot_captiveportal_url=$(discoverCaptivePortal)
if [ "x${cobot_captiveportal_url}" = "x" ]; then
    echo "Logged in already."
    exit 0
fi

echo $cobot_captiveportal_url
exit;

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