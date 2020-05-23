//
//  NeoIRCClientView.swift
//  NeoIRC
//
//  Created by Helge Heß on 21.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * The "main page" or "root view".
 */
public struct NeoIRCClientView: View {
    
  @EnvironmentObject private var serviceManager : IRCServiceManager
  
  public init() {}
  
  public var body: some View {
    NavigationView {
      ServerListView()
        .navigationBarTitle("IRC Accounts")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    NeoIRCClientView()
      .environmentObject(IRCServiceManager(passwordProvider: ""))
  }
}
