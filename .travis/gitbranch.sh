#!/bin/bash

# Usage description
usage() { echo "Usage: $0 [-d <string>] [-b <string>] [-r <true|false>]" 1>&2; exit 1; }

# Parse Options
while getopts ":d:b:r:" o; do
    case "${o}" in
        d)
            directory=${OPTARG}
            ;;
        b)
            branch=${OPTARG}
            ;;
        r)
            report=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${directory}" ] || [ -z "${branch}" ]; then
    usage
fi

cd $directory

# Update Git so it does find all the required branches
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git fetch --all

COMMIT=$(git rev-parse HEAD)
BRANCHES=$(git branch -r --contains ${COMMIT})

if `echo ${BRANCHES} | grep "${branch}" 1>/dev/null 2>&1`; then
  cd -
  exit 0;
else
  cd -
  if [ "$report" = true ] ; then
    ./.travis/discord.sh -t "Failure $TRAVIS_TAG" -d "[Git] Deploy Build $BUILD_NUMBER on Tag $TRAVIS_TAG failed - $directory is not on $branch" -c error
  fi
  exit 1;
fi