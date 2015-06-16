Hone-iosx
=========

This project contains the Hone client libraries for iOS and OS X, as well as usage examples for these platforms.

Both the iOS and OSX libraries are built and distributed as frameworks.


## How to build

Everything should build out of the box, this project has no external dependencies that are not part of the repo. You can see included external libraries in Library/Vendor.


## How to integrate in your own project

1. Check out this repo.
2. Drag Hone-iosx.xcodeproj to your Xcode project.
3. Depending on your platform, add the OSX or iOS framework into your project as an embedded+linked framework.
4. Import Hone into your classes with `@import HoneIOS` or `@import HoneOSX`.



## How to work with the API-s

See our guide: [Getting started with Hone on iOS and OS X](https://discuss.hone.tools/uploads/default/4/d8ec3eff192ec365.pdf)
