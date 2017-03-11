# PSSRedisClient

A simple Swift-based interface to Redis, using CocoaAsyncSocket

## Introduction

We had a project that required a modern implementation of either an ObjC or Swift-based redis client. After some research, it became clear that [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket) was far-and-away the superior choice for socket communication. First, it is in the public domain, so it has excellent licensing policies. Second, it has more than 8k stars and 2k forks, making it very popular. Finally, it is actively and frequently maintained. Thus, any such solution we considered must be built on top of CocoaAsyncSockets.

Numerous Swift-based interfaces to redis exist, including:

1. [RedBird](https://github.com/vapor/redbird)
This library has a networking dependency on the Vaport Socks library, not the [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket) library
1. [Zewo Redis](https://github.com/Zewo/Redis)
This library has a dependency on Zewo's own [TCP socket library](https://github.com/Zewo/TCP), again not [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket) library
1. [Swidis](https://github.com/FarhadSaadatpei/Swidis)
There doesn't seem to be any actual code in this library??
1. [SwiftRedis](https://github.com/ronp001/SwiftRedis)
This library appears to implement the networking functions itself, instead of using the [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket) library

Because none of these solutions were built atop CocoaAsyncSockets, we created our own simple class that is able to use CocoaAsyncSockets for the networking component, and that parses the [redis protocol](https://redis.io/topics/protocol).

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

PSSRedisClient is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PSSRedisClient"
```

## Author

Eric Silverberg, @esilverberg

## License

PSSRedisClient is available under the MIT license. See the LICENSE file for more info.
