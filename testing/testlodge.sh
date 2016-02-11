#!/bin/sh
# Adding deployment event to Bugsnag
# http://notify.bugsnag.com/deploy
#
# You have to set the following environment variables in your project configuration
#
# * TESTLODGE_NAME
# * TESTLODGE_EMAIL
# * TESTLODGE_PASSWORD
# * TESTLODGE_PROJECT
#
# You have the option to define the environment variables below, else defaults will be applied.
# For more details on Default Environment Variables (those starting with "CI_"), please visit:
# https://codeship.com/documentation/continuous-integration/set-environment-variables/
#
# * TESTLODGE_RELEASE_BRANCH_PREFIX=release
# * MOCHA_RESULT_JSON=mochaTestResults.json
#
# You can either add those here, or configure them on the environment tab of your
# project settings.
TESTLODGE_NAME=${TESTLODGE_NAME:?'You need to configure the TESTLODGE_NAME environment variable!'}
TESTLODGE_EMAIL=${TESTLODGE_EMAIL:?'You need to configure the TESTLODGE_EMAIL environment variable!'}
TESTLODGE_PASSWORD=${TESTLODGE_PASSWORD:?'You need to configure the TESTLODGE_PASSWORD environment variable!'}
TESTLODGE_PROJECT=${TESTLODGE_PROJECT:?'You need to configure the TESTLODGE_PROJECT environment variable!'}


# Advanced configuration
TESTLODGE_RELEASE_BRANCH_PREFIX=${TESTLODGE_RELEASE_BRANCH_PREFIX:-"release"}
MOCHA_RESULT_JSON=${MOCHA_RESULT_JSON:-"mochaTestResults.json"}


# Constant values
TESTLODGE_API_VERSION=${TESTLODGE_API_VERSION:-"v1"}
TESTLODGE_BASE_URL=${TESTLODGE_BASE_URL:-"api.testlodge.com"}



# Process arguments
while getopts ":v" opt; do
  case $opt in
    v)
      verbose='--verbose'
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

# Get dependencies
# sudo apt-get install -y jq

# Authentication details
auth_details=$(echo "${TESTLODGE_EMAIL}:${TESTLODGE_PASSWORD}")

# Base Url
base_url=$(echo "https://${TESTLODGE_NAME}.${TESTLODGE_BASE_URL}/${TESTLODGE_API_VERSION}")

# Extract the name of the current release
release_name=$(echo $CI_BRANCH | sed 's/^release\///g')

# Get the test run ID for the current release by filtering the list of all test runs
test_run_id=$( \
  curl -s \
    "${base_url}/projects/${TESTLODGE_PROJECT}/runs.json" \
    --user $auth_details \
    $verbose \
    | jq ".runs[] | select(.name==\"${release_name}\") | .id" \
)

if [ -z "$test_run_id" ]
	then
  echo "No test run related to the current release (${release_name}) found."
  exit 0
fi

# Get all test cases within this test run
  curl -s \
    "${base_url}/projects/${TESTLODGE_PROJECT}/runs/${test_run_id}/executed_steps.json" \
    --user $auth_details \
    $verbose \
    | jq ".executed_steps[] | select(.step_number==\"TC01\") | .id"
