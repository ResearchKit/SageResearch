#!/bin/sh
set -ex
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then     # on pull requests
    FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"RSDCatalog"
    bundle exec fastlane build scheme:"RSDTestApp"
    bundle exec fastlane build scheme:"ResearchUI (watchOS)"
    bundle exec fastlane build scheme:"Research (tvOS)"
elif [[ -z "$TRAVIS_TAG" && "$TRAVIS_BRANCH" == "master" ]]; then  # non-tag commits to master branch
    bundle exec fastlane ci_archive scheme:"RSDCatalog" export_method:"app-store" 
    bundle exec fastlane ci_archive scheme:"RSDTestApp" export_method:"app-store"
    bundle exec fastlane build scheme:"ResearchUI (watchOS)"
    bundle exec fastlane build scheme:"Research (tvOS)"
elif [[ -z "$TRAVIS_TAG" && "$TRAVIS_BRANCH" =~ ^stable-.* ]]; then # non-tag commits to stable branches
    FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"RSDCatalog"
    bundle exec fastlane bump_framework scheme:"Research (iOS)" tag_name:"Research" project:"Research/Research.xcodeproj"
    bundle exec fastlane bump_framework scheme:"ResearchUI (iOS)" tag_name:"ResearchUI" project:"ResearchUI/ResearchUI.xcodeproj"
    bundle exec fastlane beta scheme:"RSDCatalog" export_method:"app-store" project:"RSDCatalog/RSDCatalog.xcodeproj"
    bundle exec fastlane beta scheme:"RSDTestApp" export_method:"app-store" project:"RSDTestApp/RSDTestApp.xcodeproj"
fi
exit $?
