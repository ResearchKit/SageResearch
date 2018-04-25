#!/bin/sh
set -ex
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then     # on pull requests
    FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"RSDCatalog" project:"RSDTestApp/RSDTestApp.xcodeproj"
    FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"RSDTestApp" project:"RSDTestApp/RSDTestApp.xcodeproj"
elif [[ -z "$TRAVIS_TAG" && "$TRAVIS_BRANCH" == "master" ]]; then  # non-tag commits to master branch
    bundle exec fastlane ci_archive scheme:"RSDCatalog" export_method:"app-store" project:"RSDTestApp/RSDTestApp.xcodeproj"
    bundle exec fastlane ci_archive scheme:"RSDTestApp" export_method:"app-store" project:"RSDTestApp/RSDTestApp.xcodeproj"
elif [[ -z "$TRAVIS_TAG" && "$TRAVIS_BRANCH" =~ ^stable-.* ]]; then # non-tag commits to stable branches
    FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"RSDCatalog" project:"RSDTestApp/RSDTestApp.xcodeproj"
    FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"RSDTestApp" project:"RSDTestApp/RSDTestApp.xcodeproj"
    bundle exec fastlane beta scheme:"RSDCatalog" export_method:"app-store" project:"RSDTestApp/RSDTestApp.xcodeproj"
    bundle exec fastlane beta scheme:"RSDTestApp" export_method:"app-store" project:"RSDTestApp/RSDTestApp.xcodeproj"
fi
exit $?
