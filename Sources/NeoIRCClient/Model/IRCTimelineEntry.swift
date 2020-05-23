//
//  IRCTimelineEntry.swift
//  NeoIRC
//
//  Created by Helge Heß on 22.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Date
import struct IRC.IRCUserID

public struct IRCTimelineEntry: Equatable {
  
  public enum Payload: Equatable {
    
    case ownMessage(String)
    case message(String, IRCUserID)
    case notice (String)

    case disconnect
    case reconnect
  }
  
  public let date    : Date
  public let payload : Payload
  
  init(date: Date = Date(), payload: Payload) {
    self.date    = date
    self.payload = payload
  }
}
