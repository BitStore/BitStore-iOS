# DMJobManager

[![Build Status](https://img.shields.io/travis/D-32/DMJobManager/master.svg?style=flat)](https://travis-ci.org/D-32/DMJobManager)
[![Version](https://img.shields.io/cocoapods/v/DMJobManager.svg?style=flat)](http://cocoadocs.org/docsets/DMJobManager)
![License](https://img.shields.io/cocoapods/l/DMJobManager.svg?style=flat)
[![twitter: @dylan36032](http://img.shields.io/badge/twitter-%40dylan36032-blue.svg?style=flat)](https://twitter.com/dylan36032)

A simple library to manage "jobs", like web requests, in a queue that can be handled asynchronously.  

Often you want to perform a web request after the user has performed an action. In many cases if there's no network connection you don't want to keep the user blocked.  
DMJobManager helps you queue these requests, they even get persisted, so no request will ever get lost :)

## Installation

DMJobManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "DMJobManager"

If you're not using CocoaPods you'll find the source code files inside `Pod/Classes`. 

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

###JobManager

First, start the JobManager:
	
	[DMJobManager startManager];

Now as soon as you have a job to be handled, just call:
	
	[DMJobManager postJob:job];
	
###So what's a Job?
For that a job can be handled by the JobManager it has to conform to the `DMJob`-Protocol.  
Basically this means it has to be serilizable (NSCoding) and implement the method `executeWithCompletion:`. The completion block of the execute method has a BOOL as parameter, telling if it succeeded or not. If not successful the job will be executed again after a delay.

Take a look at `DMDummyJob` and `DMHTTPRequestJob`. It's pretty simple actually.

## Author

Dylan Marriott, info@d-32.com

## License

DMJobManager is available under the MIT license. See the LICENSE file for more info.

