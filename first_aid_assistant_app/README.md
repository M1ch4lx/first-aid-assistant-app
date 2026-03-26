# First Aid Assistant Application

## Requirements

The application has been implemented using the cross-platform Flutter framework.

To get familiar with this tool, I encourage you to review its documentation: [Flutter documentation](https://docs.flutter.dev/)

To build the application, this tool must be installed on your system. Installation instructions can be found here: [installation guide](https://docs.flutter.dev/install). The application is intended to run on Android, so in addition to the Flutter SDK, you also need to install Android Studio along with the Android SDK. In the Flutter installation guide, you should also follow the steps in the section for installing Flutter on Android.

## Configuring the Connection to the Assistant Service

The application requires a connection to the server where the backend logic of the medical assistant is hosted. Communication is performed via WebSocket.

In the .env file, the application’s environment variables are stored. The server URL is saved in the variable WS_URL.

## Building the Application

Before running the application, while in the root directory of the project, run the command flutter pub get.

## Running the Application

Before running, connect an Android phone to your computer via a USB cable. In the developer settings on the phone, USB Debugging must be enabled.

You can check the available target devices for Flutter using the command flutter devices. The phone should be visible in the list with "(mobile)" next to its name.

With the device connected, you can run the application using the command flutter -v -d device_name run.
