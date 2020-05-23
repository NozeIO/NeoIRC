//
//  AppDelegate.swift
//  NeoIRC
//
//  Created by Helge Heß on 21.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import UIKit
import NeoIRCClient

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  lazy var serviceManager = IRCServiceManager(passwordProvider: "")

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
       -> Bool
  {
    serviceManager.resume() // spin up the services
    return true
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    serviceManager.suspend()
  }
  func applicationWillEnterForeground(_ application: UIApplication) {
    serviceManager.resume()
  }

  func application(_ application: UIApplication,
                   configurationForConnecting session: UISceneSession,
                   options: UIScene.ConnectionOptions) -> UISceneConfiguration
  {
    return UISceneConfiguration(name: "Default Configuration",
                                sessionRole: session.role)
  }

  func application(_ application: UIApplication,
                   didDiscardSceneSessions sceneSessions: Set<UISceneSession>)
  {
  }
}
