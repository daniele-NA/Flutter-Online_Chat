# description
Implementing a cross-platform chat with Flutter and Firebase, when opening the project, is essential, [if not done previously]:

# fluuter

-install the entire flutter environment on your PC with plugins and dart compiler

## Getting Started witch FIREBASE

-configure your own Firebase account for creating a console and subsequently connecting to the project

- the configuration requires NPM [Node.js] commands, so proceed with installing Node on your PC

-download, modify [if necessary] the 3 console files that are not present in my project, which:
   1) firebase_options.dart (projectName/lib) [goes into the dart folder]
   2) firebase.json (in the project)
   3) google-services.json (android/app/src)
   
   !) create 2 collections, 'messages' and 'parameters', the names can be changed in the ArgMessages and ArgParameter classes in the abstract connections class

# project
-for safety and to accept splash and icon operation, first type:
    flutter pub run flutter_launcher_icons:main

-for the splash:
    flutter pub run flutter_native_splash:create

N.B [version], you need:

-openJdk 21 Java
-Kotlin compiler
-gradle 8.x.y
-flutter plugin and sdk
-dart sdk [embedded in flutter folder]

# Issues
N.B:
- the app can sometimes cause problems when first opening the chat for a new user, also putting their messages on the left together with those received, this is caused by latency (failure to call the flow to the parameters collection.
-The app is not guaranteed to run on desktop and iOS, only tested on web and Android

## preview splash

![splash](https://github.com/user-attachments/assets/51f5a476-2be0-4355-b962-5878321b40cc)

## dispaly

![home_auth](https://github.com/user-attachments/assets/ca3d45b2-5bcc-44a3-bafe-c9243286a413)






