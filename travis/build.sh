#!/bin/sh
set -ex
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then     # on pull requests
    FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"RSDCatalog"
    bundle exec fastlane build scheme:"Research-watchOS"
    bundle exec fastlane build scheme:"Research-tvOS"
    bundle exec fastlane build scheme:"Research-macOS"
elif [[ -z "$TRAVIS_TAG" && "$TRAVIS_BRANCH" == "master" ]]; then  # non-tag commits to master branch
    FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"RSDCatalog"
 #   echo "n"|bundle exec fastlane env
    bundle exec fastlane keychains
    bundle exec fastlane ci_archive scheme:"RSDCatalog" export_method:"app-store"
    bundle exec fastlane ci_archive scheme:"RSDTest" export_method:"app-store"
    bundle exec fastlane build scheme:"Research-watchOS"
    bundle exec fastlane build scheme:"Research-tvOS"
    bundle exec fastlane build scheme:"Research-macOS"
elif [[ -z "$TRAVIS_TAG" && "$TRAVIS_BRANCH" =~ ^stable-.* ]]; then # non-tag commits to stable branches
    FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"RSDCatalog"
    bundle exec fastlane bump_all
    bundle exec fastlane keychains
    bundle exec fastlane beta scheme:"RSDCatalog" export_method:"app-store" project:"RSDCatalog/RSDCatalog.xcodeproj"
    bundle exec fastlane beta scheme:"RSDTest" export_method:"app-store" project:"RSDTest/RSDTest.xcodeproj"
fi
exit $?
