#!/bin/sh

# deps:
# pip3 install trufflehog
# apt-get install jq || brew install jq || yum install jq || pkg install jq

# set:
# GITHUB_ORGS = "org list"
# GITHUB_TOKEN = "your token to do some api stuff"
# IGNORE_REPO_REGEX = "(bad|repos)"

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

# we need empty lists to start
TOTAL_MEMBER_LIST=""
TOTAL_REPO_LIST=""

# some silly defaults for IGNORE_REPO_REGEX
IGNORE_REPO_REGEX="${IGNORE_REPO_REGEX:(foocakederpmax|foocakederpmin)}"

# github API has pagination - 100 per page, the below default lets us grab 300 results per search. YMMV.
MAXPAGINATION="1"
MAXPERPAGE="100"

#echo "Step 1 - org scan"

for GITHUB_ORG in $GITHUB_ORGS; do

  for PAGE in $(seq 1 $MAXPAGINATION); do

    #echo "Searching $GITHUB_ORG Members page $PAGE"
    MEMBERS_ACCOUNTS="`curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/orgs/$GITHUB_ORG/members?\&page=$PAGE\&per_page=$MAXPERPAGE | jq '.[].repos_url' | sed 's/"//g'`"

    #echo "Searching $GITHUB_ORG Collaborators page $PAGE"
    COLLAB_ACCOUNTS="`curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/orgs/$GITHUB_ORG/outside_collaborators?\&page=$PAGE\&per_page=$MAXPERPAGE | jq '.[].repos_url' | sed 's/"//g'`"

    #echo "Merging User List for $GITHUB_ORG page $PAGE"
    TOTAL_MEMBER_LIST=`echo "$TOTAL_MEMBER_LIST $MEMBERS_ACCOUNTS $COLLAB_ACCOUNTS" | tr " " "\n" | sort | uniq`
    export TOTAL_MEMBER_LIST

  done

done

# We've built up the unique list now that we want to scan.

#echo "Step 2 - member public repo list creation"

for MEMBERPATH in $TOTAL_MEMBER_LIST; do

  for PAGE in $(seq 1 $MAXPAGINATION); do

    #echo "Checking User Repos at $MEMBERPATH"
    CLONE_REPOS="`curl -s -H "Authorization: token $GITHUB_TOKEN" $MEMBERPATH?\&page=$PAGE\&per_page=$MAXPERPAGE | jq '.[].clone_url' | sed 's/"//g'`"

    #echo "Merging Repo List for $MEMBERPATH page $PAGE"
    TOTAL_REPO_LIST=`echo "$TOTAL_REPO_LIST $CLONE_REPOS" | tr " " "\n" | sort | uniq`
    export TOTAL_REPO_LIST

  done

done

#echo "Step 3 - repo scan"

for REPO in $TOTAL_REPO_LIST; do
  echo $REPO | egrep $IGNORE_REPO_REGEX >/dev/null
  RESULT=$?
  if [ $RESULT -eq 0 ]; then
    echo "Skipping $REPO"
  else
    echo "Scanning Repo $REPO"
    trufflehog --regex --entropy=False $REPO
  fi
done
