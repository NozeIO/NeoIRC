//
//  ServiceView.swift
//  NeoIRC
//
//  Created by Helge Heß on 21.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import IRC
import class IGIdenticon.Identicon

/**
 * Currently unused?
 */
struct ServiceView: View {
  
  @ObservedObject var service : IRCService
  
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
  
  var body: some View {
    VStack {
      ChannelListView(service: service, selectedConversation: nil)
        .navigationBarTitle(title)
        .navigationBarItems(trailing: TrailingButtons(service: service))
      
      if !service.messageOfTheDay.isEmpty {
        Divider()
        Text(service.messageOfTheDay)
          .lineLimit(7)
      }
    }
  }
  
  struct TrailingButtons: View {

    @ObservedObject var service : IRCService
    
    var body: some View {
      #if os(macOS)
        return EmptyView()
      #else
        return HStack {
          NavigationLink(destination: EditAccountView(account: service.account))
          {
            Image(systemName: "pencil.circle")
          }
          NavigationLink(destination: JoinChannelView(service: service)) {
            Image(systemName: "plus.circle")
          }
        }
      #endif
    }
  }
}

struct ServiceView_Previews: PreviewProvider {
  static var previews: some View {
    IRCServiceManager(passwordProvider: "").services.first.flatMap {
      ServiceView(service: $0)
    }
  }
}
