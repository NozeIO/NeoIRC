//
//  ChannelListView.swift
//  NeoIRC
//
//  Created by Helge Heß on 21.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import IRC
import class IGIdenticon.Identicon

struct ChannelListView: View {
  
  @ObservedObject var service              : IRCService
  @State          var selectedConversation : IRCConversation?

  private var stateInfo: String {
    switch service.state {
      case .suspended  : return "suspended"
      case .offline    : return "offline"
      case .connecting : return "connecting…"
      case .online     : return "online"
    }
  }
  private var isOnline: Bool {
    switch service.state {
      case .suspended, .offline, .connecting: return false
      case .online: return true
    }
  }
  
  private var account: IRCAccount { service.account }
  
  private var title: String {
    if account.nickname.isEmpty { return account.host }
    return "\(account.nickname)@\(account.host)"
  }
  
  private func sendHello() {
    service.sendMessage("Hello", to: .channel(IRCChannelName("#SwiftDE")!))
  }
  
  private var hasChannels: Bool {
    service.conversations.values.first(where: { $0.type == .channel }) != nil
  }
  private var sortedChannels: [ IRCConversation ] {
    service.conversations.values.filter { $0.type == .channel }
                                .sorted { $0.id < $1.id }
  }
  private var hasIMs: Bool {
    service.conversations.values.first(where: { $0.type == .im }) != nil
  }
  private var sortedIMs: [ IRCConversation] {
    service.conversations.values.filter { $0.type == .im }
                                .sorted { $0.id < $1.id }
  }

  var body: some View {
    List {
      if hasChannels {
        Section(header: Text("Channels")) {
          ForEach(sortedChannels) { channel in
            ItemView(
              conversation: channel,
              selected: self.$selectedConversation
            )
          }
        }
      }
      if hasIMs {
        Section(header: Text("Direct Messages")) {
          ForEach(sortedIMs) { im in
            ItemView(
              conversation: im,
              selected: self.$selectedConversation
            )
          }
        }
      }
    }
  }

  struct ItemView: View {
    
    @ObservedObject var conversation : IRCConversation
    let selected : Binding<IRCConversation?>
    
    private func isActive(_ conversation: IRCConversation) -> Binding<Bool> {
      Binding(get: { self.selected.wrappedValue === conversation }) {
        isActive in
        self.selected.wrappedValue = isActive ? conversation : nil
      }
    }
    
    var body: some View {
      NavigationLink(destination: ChannelView(conversation: conversation),
                     isActive: isActive(conversation))
      {
        IdenticonText(conversation.id)
      }
    }
  }
}

struct ChannelListView_Previews: PreviewProvider {
  static var previews: some View {
    IRCServiceManager(passwordProvider: "").services.first.flatMap {
      ChannelListView(service: $0)
    }
  }
}
