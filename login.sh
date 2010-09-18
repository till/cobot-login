#!/usr/bin/env bash
#
# login.sh - automagically login to the cobot captive portal
#

#set -x

this_dir=$(dirname ${0})
source "${this_dir}/functions"

space_config="${this_dir}/etc/space.cfg"
if [ ! -f ${space_config} ]; then
    echo "Please create a space config: ${space_config}"
    exit 1
fi
source ${space_config}

user_config="${this_dir}/etc/user.cfg"
if [ ! -f ${user_config} ]; then
    echo "Please create a user config: ${user_config}"
    exit 1
fi
source ${user_config}

system_name=`uname -s`
case ${system_name} in
  Linux|*BSD)
    password_cmd="getPasswordFromUserCfg"
  ;;

  Darwin)
    password_cmd="getPasswordFromKeychain ${keychain_item_name} ${keychain_name}"
  ;;

  *)
    # do something else
    echo "The ${system_name} operating system is not supported"
    exit 1
  ;;
esac

cobot_captiveportal_url=$(discoverCaptivePortal)
if [ "x${cobot_captiveportal_url}" = "x" ]; then
    echo "Already logged in."
    exit 0
fi

cobot_account_type='user'
cobot_auth_user=$(getFullCobotUsername ${cobot_username} ${cobot_space_name})

login_cmd="curl -X POST
    -w=%{response_code}
    -s
    -o /dev/null
    -d username=${cobot_username}
    -d redirect_url=
    -d auth_user=${cobot_auth_user}
    -d accept=Log+In
    -d account_type=${cobot_account_type}
    --data-urlencode auth_pass@-
    ${cobot_captiveportal_url}"

# pipe the password directly to the login command,
# so it does not appear when displaying process information,
# e.g. with ps -efa
response=$(${password_cmd} | ${login_cmd})

if [ "${response}" = "=302" ]; then
    echo "Great success!"
    exit 0
else
    echo "Login failed."
    exit 1
fi
