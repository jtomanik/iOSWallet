# iOSWallet

## Task
Write an application for iOS using Swift, that displays the following information for an arbitrary EOS account:

- the EOS token balance
- the value in USD
- the staked resources for CPU and NET as well as the current consumption
- the RAM consumption

## The app

![image](https://raw.githubusercontent.com/jtomanik/iOSWallet/master/pic1.png)

### Architectural approach
I wanted to presents some advantages that architectures based on the State machines, Unidirectional dataflows, Redux and similar posses. This is heavily inspired by the following repos:

[RxFeedback.swift](https://github.com/NoTests/RxFeedback.swift)

[ReactorKit](https://github.com/ReactorKit/ReactorKit)

[ReactiveFeedback](https://github.com/babylonhealth/ReactiveFeedback)

[Workflow](https://github.com/square/workflow)


## Setup
This project has been tested with Xcode 11.1 on a MacOS 10.14.5. All Pods are included in this repo.
After cloning into local machine please open `Wallet.xcworkspace` everything should be ready to be build.

## Running the app
After running the app you can end up in the Pin Lock screen. For the moment Pin is hardcoded to `1234`.

### ToDo
There are few things to improve:

- Improve memory and thread handling
- Add proper documentation
- Add proper error handling
- Add more tests
- Add more features 🚀

### Gallery

![image](https://raw.githubusercontent.com/jtomanik/iOSWallet/master/pic1.png)
![image](https://raw.githubusercontent.com/jtomanik/iOSWallet/master/pic2.png)
![image](https://raw.githubusercontent.com/jtomanik/iOSWallet/master/pic3.png)
![image](https://raw.githubusercontent.com/jtomanik/iOSWallet/master/pic4.png)
