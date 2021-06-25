#!/usr/bin/env bash

# Sample script to bump minor version of the RH-SSO image

if [ "x$1x" == "xx" ]
then
  echo "Please specify directory with RH-SSO image git repository clone"
  exit 1
fi

RH_SSO_IMAGE_GIT_REPO="$1"

OLD_SSO_MAJOR_MINOR_MICRO_VERSION="7\.4\.7"
NEW_SSO_MAJOR_MINOR_MICRO_VERSION="7\.5\.0"

OLD_SSO_MAJOR_MINOR_VERSION="7\.4"
NEW_SSO_MAJOR_MINOR_VERSION="7\.5"

OLD_SSO_MINOR_VERSION="4"
NEW_SSO_MINOR_VERSION="5"

pushd $RH_SSO_IMAGE_GIT_REPO

for filePath in $(find $PWD -type f | grep -v "\.git")
do
  # Update version within files
  sed -i "s/7$OLD_SSO_MINOR_VERSION/7$NEW_SSO_MINOR_VERSION/g" $filePath
  sed -i "s/$OLD_SSO_MAJOR_MINOR_MICRO_VERSION/$NEW_SSO_MAJOR_MINOR_MICRO_VERSION/g" $filePath
  sed -i "s/$OLD_SSO_MAJOR_MINOR_VERSION/$NEW_SSO_MAJOR_MINOR_VERSION/g" $filePath
done

# Rename directories containing version in their name
for dirPath in $(find $PWD -depth -ignore_readdir_race -type d | grep -v "\.git")
do
  if [[ "$dirPath" =~ "7$OLD_SSO_MINOR_VERSION" ]]
  then
    newDirPath="${dirPath/7$OLD_SSO_MINOR_VERSION/7$NEW_SSO_MINOR_VERSION}"
    # Since directories are processed from leafs above, ignore git mv fatal errors
    git mv "$dirPath" "$newDirPath" 2>/dev/null
  fi
done

# Rename files containing version in their name
for filePath in $(find $PWD -type f | grep -v "\.git")
do
  if [[ "$filePath" =~ "7$OLD_SSO_MINOR_VERSION" ]]
  then
    fileDir="$(dirname $filePath)"
    fileName="$(basename $filePath)"
    newFilename="${fileName/7$OLD_SSO_MINOR_VERSION/7$NEW_SSO_MINOR_VERSION}"
    git mv "$fileDir/$fileName" "$fileDir/$newFilename"
  fi
done

echo "Updated references to RH-SSO image to version 7.5"
echo "Run 'git status' to check the changes"

popd
