//
//  Identicon.swift
//  NeoIRC
//
//  Created by Helge Heß on 23.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import class IGIdenticon.Identicon

fileprivate let identicon = IGIdenticon.Identicon()
fileprivate let iconSize  = CGSize(width: 48, height: 48)

struct Identicon: View {
  
  #if os(macOS)
    private typealias UXImage = NSImage
  #else
    private typealias UXImage = UIImage
  #endif

  let text : String
  
  init(_ text: String) {
    self.text = text
  }
  
  private var icon : UXImage {
    // FIX: IGIdenticon this can also do CGImage, which we can
    //      directly pass to `Image`.
    identicon.icon(from: text, size: iconSize, scale: 1)!
  }

  var body : Image {
    #if os(macOS)
      return Image(nsImage: icon)
    #else
      return Image(uiImage: icon)
    #endif
  }
}

struct Identicon_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      Identicon("Hello, World!")
      Identicon("#general")
      Identicon("soy")
    }
  }
}
