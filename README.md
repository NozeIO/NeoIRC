<h2>
  NeoIRC
  <img src="http://zeezide.com/img/NeoIRC.svg"
       align="right" width="128" height="128" />
</h2>

![Swift5](https://img.shields.io/badge/swift-5-blue.svg)
![SwiftNIO2](https://img.shields.io/badge/swiftnio-2-blue.svg)
![SwiftUI](https://img.shields.io/badge/os-swiftui-purple.svg)
![iOS](https://img.shields.io/badge/os-iOS-green.svg?style=flat)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)

A simple [Internet Relay Chat](https://en.wikipedia.org/wiki/Internet_Relay_Chat)
client implemented using
[SwiftNIO](https://github.com/apple/swift-nio)
and
[SwiftUI](https://developer.apple.com/xcode/swiftui/).

Inspired by:

> For maximum NIO someone (I’m tempted) should adopt NIO to work on top of
> swift-nio-irc-client ... [Twitter](https://twitter.com/helje5/status/1262849721858772993?ref_src=twsrc%5Etfw)

Unfortunately [NIO](https://nio.chat) - the promising Matrix chat client -
is too tightly coupled to [Matrix SDK](https://www.matrix.org),
so I've redone a very basic UI.

This is by no means "done", it is a demo on how to use SwiftNIO within a SwiftUI
application.
Pull requests are very welcome.

The program is part of the "Swift NIO IRC" family of packages, which includes:

- [swift-nio-irc](https://github.com/SwiftNIOExtras/swift-nio-irc), 
  a low level IRC protocol implementation for SwiftNIO
- [swift-nio-irc-client](https://github.com/NozeIO/swift-nio-irc-client),
  an easier to use client library for use in applications (like NeoIRC)
- [swift-nio-irc-server](https://github.com/NozeIO/swift-nio-irc-server),
  a simple IRC server written using SwiftNIO
- [swift-nio-irc-webclient](https://github.com/NozeIO/swift-nio-irc-webclient),
  a small Web IRC client using SwiftNIO's WebSocket support
- and finally, [swift-nio-irc-eliza](https://github.com/NozeIO/swift-nio-irc-eliza),
  a scalable Rogerian psychotherapist, as an IRC bot.


### Screenshots

<center><img src="https://zeezide.de/img/NeoIRC-screenshot-1.png"
     align="right" width="200"/></center>

macOS also works, kinda. Not really. But it builds :-)

#### WebClient

<center><img src="https://zeezide.de/img/irc-eliza-720x781.png"
     align="right" width="200"/></center>


### TODO

- [ ] tons of bugs
- [ ] actually add, delete and edit accounts :-)
- [ ] keychain password storage
- [ ] combining bubbles
- [ ] better IRC support
- [ ] state restoration (I tried, but NavigationLinks just don't work right)
- [ ] listing available channels in subscribe
- [ ] leave button


### Who

Brought to you by
[ZeeZide](http://zeezide.de).
We like
[feedback](https://twitter.com/ar_institute),
GitHub stars,
cool [contract work](http://zeezide.com/en/services/services.html),
presumably any form of praise you can think of.
