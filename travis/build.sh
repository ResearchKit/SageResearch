#!/bin/sh
set -ex
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then     # on pull requests
    FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"RSDCatalog" workspace:"ResearchStack2.xcworkspace"
elif [[ -z "$TRAVIS_TAG" && "$TRAVIS_BRANCH" == "master" ]]; then  # non-tag commits to master branch
    bundle exec fastlane ci_archive scheme:"RSDCatalog" export_method:"app-store"
elif [[ -z "$TRAVIS_TAG" && "$TRAVIS_BRANCH" =~ ^stable-.* ]]; then # non-tag commits to stable branches
    FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"RSDCatalog" workspace:"ResearchStack2.xcworkspace"
    bundle exec fastlane beta scheme:"RSDCatalog" export_method:"app-store"
fi
exit $?
