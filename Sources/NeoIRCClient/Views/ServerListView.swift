//
//  ServerListView.swift
//  NeoIRC
//
//  Created by Helge Heß on 23.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import let NIOIRC.DefaultIRCPort

struct ServerListView: View {
    
  @EnvironmentObject private var serviceManager : IRCServiceManager
  @State private var selectedService : IRCService?
  
  init(selectedService: IRCService? = nil) {
    self.selectedService = selectedService
  }
  
  private func isActive(_ service: IRCService) -> Binding<Bool> {
    Binding(get: { service === self.selectedService }) {
      isActive in
      self.selectedService = isActive ? service : nil
    }
  }
  
  var body: some View {
    List(serviceManager.services) { service in
      NavigationLink(destination: ServiceView(service: service),
                     isActive: self.isActive(service))
      {
        ItemView(service: service)
      }
    }
  }
  
  struct ItemView: View {
    
    @ObservedObject var service : IRCService
    
    private var account : IRCAccount { service.account }
    
    private var hash: String {
      "\(account.host):\(account.port)"
    }
    
    private var title: String {
      var ms = ""
      if !account.nickname.isEmpty {
        // TODO: use the actual nick, not the configured one!
        ms += account.nickname
        ms += "@"
      }
      ms += account.host
      if account.port != DefaultIRCPort {
        ms += ":\(account.port)"
      }
      return ms
    }
    
    private var subtitle: String {
      if !isOnline { return "Offline" }
      
      let count = service.conversations.values
                         .filter { $0.type == .channel }
                         .count
      let first = service.conversations.values
                    .first(where: { $0.type == .channel })
      switch count {
        case 0:  return "no channels joined"
        case 1:  return "\(first?.name ?? "-")"
        default: return "#\(count) channels joined"
      }
    }
    
    private var isOnline: Bool {
      switch service.state {
        case .suspended, .offline, .connecting: return false
        case .online: return true
      }
    }

    var body: some View {
      HStack {
        Identicon(hash).padding(4)
        VStack(alignment: .leading, spacing: 4) {
          Text(title)
          if !subtitle.isEmpty {
            Text(subtitle)
              .foregroundColor(.secondary)
          }
        }
      }
    }
  }
}

struct ServerListView_Previews: PreviewProvider {
  static var previews: some View {
    ServerListView()
      .environmentObject(IRCServiceManager(passwordProvider: ""))
  }
}
