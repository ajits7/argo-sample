#!/bin/bash

ENVIRONMENT=$1
REGION=$2
SERVICE_LEVEL=$3
SLACK=sun-b2c-devops-alerts

GIT=`which git`

WORKSPACE="/Users/ajitsingh/Documents/GitHub/LE-b2c-terraform"
export TERRAFORM_HOME=$WORKSPACE

cd $TERRAFORM_HOME
#$GIT pull

cd $TERRAFORM_HOME/terraform/$ENVIRONMENT/$REGION/$SERVICE_LEVEL
echo "$(pwd)"
# TF_PATH=`find * -name "_backend.tf" | sed -r 's|/[^/]+$||' | sort | uniq`
# TF_PATH=mailbucket
# echo $TF_PATH

cd $TERRAFORM_HOME/scripts
STATEFILE=mailbucket
echo "$(pwd)"
# for STATEFILE in $TF_PATH
# do
# output="Initializing the backend... Initializing modules... Initializing provider plugins... - terraform.io/builtin/terraform is built in to Terraform - Reusing previous version of hashicorp/aws from the dependency lock file - Using previously-installed hashicorp/aws v4.55.0 Terraform has been successfully initialized!  You may now begin working with Terraform. Try running to see any changes that are required for your infrastructure. All Terraform commands should now work. If you ever set or change modules or backend configuration for Terraform, rerun this command to reinitialize your working directory. If you forget, other commands will detect it and remind you to do so if necessary. No changes. Your infrastructure matches the configuration. Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed."
  output=`./terraform-runner-v2.sh "terraform.watch(/$ENVIRONMENT/$REGION/$SERVICE_LEVEL/$STATEFILE)"`
  [[ ! -z "$output" ]] || ./terraform-runner-v2.sh "terraform.plan(/$ENVIRONMENT/$REGION/$SERVICE_LEVEL/$STATEFILE)"
echo $output

if [[ $output == *"0 to add, 0 to change, 0 to destroy."* ]] || [[ $output == *"No changes."* ]]; then
  echo Thumbs up
else
  # echo $output
  echo "bad .."
  MESSAGE="Changes detected in $ENVIRONMENT $REGION  $STATEFILE"
  # curl --data '{"channel":"'${SLACK}'", "text":"'"$MESSAGE"'"}' -X POST -H 'Content-type:application/json' https://hooks.slack.com/services/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
fi

# done

#$GIT stash