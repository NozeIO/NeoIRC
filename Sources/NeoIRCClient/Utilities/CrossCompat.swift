//
//  CrossCompat.swift
//  NeoIRC
//
//  Created by Helge Heß on 23.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

#if os(macOS)

extension View {
  func navigationBarTitle(_ title: String) -> some View { return self }
  
  func navigationBarItems<T: View>(trailing: T) -> some View { return self }
}

#endif // macOS
