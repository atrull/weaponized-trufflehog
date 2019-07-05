#!/bin/sh

# deps:
# pip3 install trufflehog
# apt-get install jq || brew install jq || yum install jq || pkg install jq

# set:
# GITHUB_ORGS = "org list"
# GITHUB_TOKEN = "your token to do some api stuff"

# usage:
# Run
# Fix a dependency
# Run again
# Wait
# Check the scan file for results

# to make this useful:
# Store the scan-results somewhere
# Diff the results to produce a report which you run every
# few hours

for GITHUB_ORG in $GITHUB_ORGS; do

  MEMBERS_REPOS="`curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/orgs/$GITHUB_ORG/members | jq '.[] .repos_url' | sed 's/"//g'`"

  for MEMBER_REPO in $MEMBERS_REPOS; do

    CLONE_REPOS="`curl -H "Authorization: token $GITHUB_TOKEN" $MEMBER_REPO | jq '.[] .clone_url' | sed 's/"//g'`"

    for CLONE_REPO in $CLONE_REPOS; do

      echo "Scanning $CLONE_REPO" >> trufflehog-scan.txt
      trufflehog --regex --entropy=False $CLONE_REPO >> trufflehog-scan.txt

    done

  done

done
