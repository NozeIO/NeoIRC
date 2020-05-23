//
//  TimelineView.swift
//  NeoIRC
//
//  Created by Helge Heß on 22.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import IRC

/**
 * The "main page" or "root view".
 */
struct TimelineView: View {
  
  @ObservedObject var conversation : IRCConversation
  
  var body: some View {
    ScrollView {
      ForEach(Array(conversation.timeline.enumerated()), id: \.offset) {
        _, entry in
      
        TimelineEntryView(entry: entry)
      }
    }
  }
}

struct TimelineEntryView: View {
  
  let entry : IRCTimelineEntry
  
  var body: some View {
    switch entry.payload {
      case .disconnect, .reconnect: // TODO
        return AnyView(EmptyView())
 
      case .message(let message, let user):
        return AnyView(IncomingMessageView(timestamp: entry.date,
                                           message: message, sender: user))
      
      case .ownMessage(let message):
        return AnyView(OwnMessageView(timestamp: entry.date, message: message))
      
      case .notice(let message):
        return AnyView(NoticeMessageView(timestamp: entry.date,
                                         message: message))
    }
  }

  struct NoticeMessageView: View {
    
    let timestamp : Date
    let message   : String
    
    var body: some View {
      HStack {
        Spacer()
        Text(verbatim: message)
        Spacer()
      }
      .padding(8)
    }
  }

  struct IncomingMessageView: View {
    
    let timestamp : Date
    let message   : String
    let sender    : IRCUserID
    
    var body: some View {
      HStack(alignment: .top) {
        Identicon(sender.nick.stringValue)
        VStack(alignment: .leading, spacing: 4) {
          HStack {
            Text(verbatim: sender.nick.stringValue)
              .fontWeight(.bold)
          }
          Text(verbatim: message)
        }
        Spacer()
      }
      .padding(8)
    }
  }
  
  struct OwnMessageView: View {
    
    let timestamp : Date
    let message   : String
    
    var body: some View {
      HStack(alignment: .top) {
        Spacer()
        VStack(alignment: .trailing, spacing: 4) {
          HStack {
            // TODO: date
            Text("Me")
              .fontWeight(.bold)
          }
          Text(verbatim: message)
        }
        Identicon("FancyMe")
      }
      .padding(8)
    }
  }
}
