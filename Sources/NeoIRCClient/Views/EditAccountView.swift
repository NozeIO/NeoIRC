//
//  EditAccount.swift
//  NeoIRC
//
//  Created by Helge Heß on 22.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import IRC

struct EditAccountView: View {

  @ObservedObject var account : IRCAccount
  
  var body: some View {
    VStack {
      Text("Host: \(account.host)")
    }
    .navigationBarTitle(account.host)
  }
}
