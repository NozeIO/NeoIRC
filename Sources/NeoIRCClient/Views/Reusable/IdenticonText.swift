//
//  IdenticonText.swift
//  NeoIRC
//
//  Created by Helge Heß on 23.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

struct IdenticonText: View {
  
  let text : String
  
  init(_ text: String) {
    self.text = text
  }
  
  var body : some View {
    HStack {
      Identicon(text).padding(4)
      Text(text)
    }
  }
}

struct IdenticonText_Previews: PreviewProvider {
  static var previews: some View {
    VStack(alignment: .leading) {
      IdenticonText("Hello, World!")
      IdenticonText("#general")
      IdenticonText("soy")
    }
  }
}
