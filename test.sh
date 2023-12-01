#!/bin/bash

# cwd=$(pwd)

# read -p "Enter the profile name: " profile_name
profile_name=$1

case "$profile_name" in
  "sun-qa")
    export OKTA_IDP_ENTRY_URL=https://weather.okta.com/home/theweatherchannel_awssunqa_1/0oa6ylcp9odkKhTOL0x7/aln6ylf1brYaSd1lu0x7
    ;;
  "sun-prod")
    export OKTA_IDP_ENTRY_URL=https://weather.okta.com/home/theweatherchannel_awssunprod_1/0oa6ylujq0EUWVapo0x7/aln6ym14v8mLVuTNe0x7
    ;;
  "platform")
    export OKTA_IDP_ENTRY_URL=https://weather.okta.com/home/weather_awsplatformengineering_1/0oaryyk8wxln9U80X0x7/alnryyqo75W03bjgf0x7
    ;;
  "pe-qa")
    export OKTA_IDP_ENTRY_URL=https://weather.okta.com/home/weather_awspeqa_1/0oatsun59dhh7W2Om0x7/alntsurt9pATPuEn50x7
    ;;
  *)
    echo "Invalid profile name: $profile_name"
    exit 1
    ;;
esac


export OKTA_AWS_PROFILE=$profile_name
export OKTA_AWS_REGION=us-east-1
export OKTA_AWS_OUTPUT_FORMAT=json
export OKTA_USERNAME=ajit.singh@weather.com

# Install dependencies from requirements.txt
# cd /Users/ajitsingh/mywork/repo/twc-okta_aws_login

# Change to the directory containing the okta_aws_login.py script and execute it

python3 /Users/ajitsingh/mywork/repo/twc-okta_aws_login/okta_aws_login.py


# Read the credentials file
credentials_file="/Users/ajitsingh/.aws/credentials"

if [[ ! -f "$credentials_file" ]]; then
    echo "Error: Credentials file not found."
    exit 1
fi

profile=$1

# Read the values from the credentials file
region=$(awk -v profile="$profile" '/^\['"$profile"'\]$/{p=1} p&&/region/{print $3; exit}' ${credentials_file})
aws_access_key_id=$(awk -v profile="$profile" '/^\['"$profile"'\]$/{p=1} p&&/aws_access_key_id/{print $3; exit}' ${credentials_file})
aws_secret_access_key=$(awk -v profile="$profile" '/^\['"$profile"'\]$/{p=1} p&&/aws_secret_access_key/{print $3; exit}' ${credentials_file})
aws_session_token=$(awk -v profile="$profile" '/^\['"$profile"'\]$/{p=1} p&&/aws_session_token/{print $3; exit}' ${credentials_file})


export AWS_DEFAULT_REGION=$region
export AWS_PROFILE=$profile
export AWS_ACCESS_KEY_ID=$aws_access_key_id
export AWS_SECRET_ACCESS_KEY=$aws_secret_access_key
export AWS_SESSION_TOKEN=$aws_session_token
