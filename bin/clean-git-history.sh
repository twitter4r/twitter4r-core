#!/bin/bash

git co master
git remote add mbbx6spp git@github.com:mbbx6spp/twitter4r.git
git pull mbbx6spp master

# filter branch and remove recursively web/ and marketing/ directories,
# then remove references of unnecessary blobs from repository.
git filter-branch -f --prune-empty --tree-filter 'rm -rf web/ marketing/' -- --all
git for-each-ref --format='%(refname)' refs/original | \
  while read ref
  do
     git update-ref -d "$ref"
  done
git reflog expire --expire=0 --all
git repack -ad
git prune

# change all email references for committer and author from 'mbbx6spp' 
# Rubyforge username to me@susanpotter.net
git filter-branch --env-filter '
if [ "$GIT_AUTHOR_EMAIL" = "mbbx6spp" ];
then
  export GIT_AUTHOR_EMAIL="me@susanpotter.net";
fi
if [ "$GIT_COMMITTER_EMAIL" = "mbbx6spp" ];
then
  export GIT_COMMITTER_EMAIL="me@susanpotter.net";
fi
' HEAD

# change all name references for committer and author from 'mbbx6spp' 
# Rubyforge username to Susan Potter
git filter-branch -f --env-filter '
if [ "$GIT_AUTHOR_NAME" = "mbbx6spp" ];
then
  export GIT_AUTHOR_NAME="Susan Potter";
fi
if [ "$GIT_COMMITTER_NAME" = "mbbx6spp" ];
then
  export GIT_COMMITTER_NAME="Susan Potter";
fi
' HEAD

