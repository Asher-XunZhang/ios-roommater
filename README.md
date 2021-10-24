# Roommater

## Deliverable 2

## Team

- Kamiku Xue
- Xun Xhang

## Gitlab Repo

- Client: https://gitlab.uvm.edu/anmuso/roommater
- Server: https://gitlab.uvm.edu/anmuso/roommater-server

## Description

An management app for communication between dormitories, reminders, fee sharing and other convenient services. 

## Get started
1. Instaill the [CocoaPods](https://cocoapods.org) *A depencencies management for swift project*  | You can using `brew install cocoapods` if you have [Homebrew](https://docs.brew.sh/Installation)
2. Go to the project folder `cd <path to project folder>` and run the command `pod install`  to install the dependencies.
3. Open the `Roommater.xcworkspace` file to load the project  *The `Roommater.xcodeproj` doesn't contain the dependencies*
4. Build and run

## Notes:

- There have errors about `Failed to render and update auto layout status...`. These are caused by the ui library and it will not cause any fatal error for build and normal usage. We will try to fix this issues in the future.

## Features implemented so fat

Util now we are trying to figure out the account system, this is a very complex system with server and client.

- Login the account  and login page
- Create an account and regiseter page
- Reset an account and forgot page
- Account web request closure (For login, signup and forgot request)
- Initial Socket IO connection (Connect to the server and get the session id *See Console output*)

## How to run it?

1. Start the app and you will in the login page
2. Click the create new account to  creata a new account.
3. Back to login in page, fill the username and password, click the login button, you will see the console ouput of result.
4. You can clinet the forgot password to reset your account's password. You just fill the email address and you can chech your mailbox form Roommater to reset your account.

## References

Web Part

- [Alamofire | Powerful Web Request Library](https://github.com/Alamofire/Alamofire)
- [SocketIO | Realtime Communication Between Server and Client](https://github.com/socketio/socket.io-client-swift)
- [SwiftJWT | Web request security encryption](https://github.com/Kitura/Swift-JWT)
- [ObjectMapper | Convert json to custom data model](https://github.com/tristanhimmelman/ObjectMapper)

UI Part

- [CocoaTextField](https://github.com/edgar-zigis/CocoaTextField)
- [TransitionButton](https://github.com/AladinWay/TransitionButton)
