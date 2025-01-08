#!/bin/sh
set -e

LOGFILE=$NIX_CONFIG_HOME/logs/sync-blog.log
OBSIDIAN_PUBLIC_FOLDER="/home/smissingham/Documents/Obsidian/notes/@Public/";
WEBSITE_CONTENT_FOLDER="/home/smissingham/Documents/Projects/missingham.net/content/";
DATE=$(date +'%B %d, %Y %H:%M %p')


echo "Nix Cron Sync: $DATE" > $LOGFILE

rsync -a $OBSIDIAN_PUBLIC_FOLDER $WEBSITE_CONTENT_FOLDER &>> $LOGFILE

pushd $WEBSITE_CONTENT_FOLDER

git add . &>> $LOGFILE
git commit -m "Nix Cron Sync: $DATE" || echo "No changes to commit." &>> $LOGFILE

if [ -n "$(git diff --name-only HEAD^ HEAD)" ]; then
    echo "Changes detected. Pushing to origin." &>> $LOGFILE
    git push origin &>> $LOGFILE
else
    echo "No changes detected. Skipping push to origin." &>> $LOGFILE
fi

popd