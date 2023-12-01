# Read the credentials file
credentials_file="/Users/ajitsingh/.aws/credentials"

if [[ ! -f "$credentials_file" ]]; then
    echo "Error: Credentials file not found."
    exit 1
fi

# Read the profile name from the command line argument
read -p "Enter the profile name: " profile
# profile=$1

# Read the values from the credentials file
region=$(awk -v profile="$profile" '/^\['"$profile"'\]$/{p=1} p&&/region/{print $3; exit}' ${credentials_file})
aws_access_key_id=$(awk -v profile="$profile" '/^\['"$profile"'\]$/{p=1} p&&/aws_access_key_id/{print $3; exit}' ${credentials_file})
aws_secret_access_key=$(awk -v profile="$profile" '/^\['"$profile"'\]$/{p=1} p&&/aws_secret_access_key/{print $3; exit}' ${credentials_file})
aws_session_token=$(awk -v profile="$profile" '/^\['"$profile"'\]$/{p=1} p&&/aws_session_token/{print $3; exit}' ${credentials_file})

# Output the environment variable assignments
echo "export AWS_DEFAULT_REGION=$region"
echo "export AWS_PROFILE=$profile"
echo "export AWS_ACCESS_KEY_ID=$aws_access_key_id"
echo "export AWS_SECRET_ACCESS_KEY=$aws_secret_access_key"
echo "export AWS_SESSION_TOKEN=$aws_session_token"

# export AWS_DEFAULT_REGION=$region
# export AWS_PROFILE=$profile
# export AWS_ACCESS_KEY_ID=$aws_access_key_id
# export AWS_SECRET_ACCESS_KEY=$aws_secret_access_key
# export AWS_SESSION_TOKEN=$aws_session_token