#!/bin/bash
set -v
logfile=log.txt
dir=$(ls -l | grep ^d | awk '/^d/ {print i$NF}' i=`pwd`'/')
shellSuccess=0
for i in $dir
do
  exitCode=`python3 check.py $i $logfile`
  logContent=$(cat $logfile)
  lastCommit=`curl -X GET https://api.github.com/repos/$TRAVIS_REPO_SLUG/pulls/$TRAVIS_PULL_REQUEST/commits | jq '.[-1].sha' -r`
  if [ exitCode == 0 ]
  then
  buildStatus="Success"
  else
  buildStatus="Fail"
  shellSuccess=-1
  fi
  if [ "$TRAVIS_PULL_REQUEST" != "false" ]
  # just pull request get comments
  then
  curl -H "Authorization: token $GITHUB_TOKEN" -X POST -d "{\"body\": \"**Commit**:$lastCommit  \n\n**Build Status**:  $buildStatus\n\n**Detail**:  $logContent\"}" "https://api.github.com/repos/$TRAVIS_REPO_SLUG/issues/$TRAVIS_PULL_REQUEST/comments"
  fi
done
exit $shellSuccess
