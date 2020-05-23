//
//  ChannelView.swift
//  NeoIRC
//
//  Created by Helge Heß on 23.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import Foundation
import SwiftUI
import IRC

/**
 * The "main page" or "root view".
 */
struct ChannelView: View {
  
  @ObservedObject var conversation : IRCConversation
  
  var body: some View {
    VStack {
      TimelineView(conversation: conversation)
      
      Divider()
      
      PostField(conversation: conversation)
        .padding(8)
    }
    .navigationBarTitle(conversation.name)
  }
  
  struct PostField: View {
    
    @ObservedObject var conversation : IRCConversation
    
    @State var message : String = ""
    
    private func sendMessage() {
      let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty else { return }
      
      if conversation.sendMessage(trimmed) {
        message = ""
      }
    }
    
    var body: some View {
      HStack {
        TextField("Post message to \(conversation.name)", text: $message)
        
        #if os(macOS)
          Button(action: self.sendMessage) { Text("Send") }
        #else
          Button(action: self.sendMessage) { Image(systemName: "paperplane") }
        #endif
      }
    }
  }
}
