//
//  IRCServiceManager.swift
//  NeoIRC
//
//  Created by Helge Heß on 21.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import Combine
import struct   Foundation.UUID
import class    Foundation.UserDefaults
import protocol NIO.EventLoopGroup
import class    NIOTransportServices.NIOTSEventLoopGroup

/**
 * TODO: Document me
 */
public final class IRCServiceManager: ObservableObject {
  
  let defaults = UserDefaults.standard
  
  @Published private(set) public var services : [ IRCService ]

  private let eventLoopGroup   : EventLoopGroup
  private let passwordProvider : IRCServicePasswordProvider
  
  public init(passwordProvider: IRCServicePasswordProvider) {
    let eventLoopGroup = NIOTSEventLoopGroup(loopCount: 1, defaultQoS: .default)

    let accounts = (try? defaults.decode([IRCAccount].self, forKey: .accounts))
                ?? []
    
    self.passwordProvider = passwordProvider
    self.eventLoopGroup   = eventLoopGroup
    self.services         = accounts.map {
      return IRCService(account: $0, passwordProvider: passwordProvider,
                        eventLoopGroup: eventLoopGroup)
    }
    
    #if DEBUG
    if services.isEmpty {
      addAccount(IRCAccount(host: "irc.noze.io", nickname: "Neo"))
    }
    #endif
  }
  
  
  // MARK: - Service Lookup
    
  public func serviceWithID(_ id: UUID) -> IRCService? {
    return services.first(where: { $0.account.id == id })
  }
  public func serviceWithID(_ id: String) -> IRCService? {
    guard let uuid = UUID(uuidString: id) else { return nil }
    return serviceWithID(uuid)
  }
  
  public func addAccount(_ account: IRCAccount) {
    guard services.first(where: { $0.account.id == account.id }) == nil else {
      assertionFailure("duplicate ID!")
      return
    }
    
    let service = IRCService(account: account, passwordProvider: "",
                             eventLoopGroup: eventLoopGroup)
    services.append(service)
    
    persistAccounts()
  }
  public func removeAccountWithID(_ id: UUID) {
    guard let idx = services.firstIndex(where: {$0.account.id == id }) else {
      return
    }
    services.remove(at: idx)
    persistAccounts()
  }
  
  private func persistAccounts() {
    do {
      try defaults.encode(services.map(\.account), forKey: .accounts)
    }
    catch {
      assertionFailure("Could not persist accounts: \(error)")
      print("failed to persist accounts:", error)
    }
  }
  
  
  // MARK: - Lifecycle
  
  public func resume() {
    services.forEach { $0.resume() }
  }
  public func suspend() {
    services.forEach { $0.suspend() }
  }
}
