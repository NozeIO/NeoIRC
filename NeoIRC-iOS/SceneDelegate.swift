//
//  SceneDelegate.swift
//  NeoIRC
//
//  Created by Helge Heß on 21.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import UIKit
import SwiftUI
import NeoIRCClient

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var serviceManager : IRCServiceManager? {
    return (UIApplication.shared.delegate as? AppDelegate)?.serviceManager
  }

  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions)
  {
    guard let serviceManager = serviceManager else {
      assertionFailure("could not grab service manager ..")
      return
    }
    
    let contentView = NeoIRCClientView().environmentObject(serviceManager)

    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(rootView: contentView)
      self.window = window
      window.makeKeyAndVisible()
    }
  }

  func sceneDidDisconnect      (_ scene: UIScene) {}
  func sceneDidBecomeActive    (_ scene: UIScene) {}
  func sceneWillResignActive   (_ scene: UIScene) {}
  func sceneWillEnterForeground(_ scene: UIScene) {}
  func sceneDidEnterBackground (_ scene: UIScene) {}
}
