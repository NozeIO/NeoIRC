//
//  IRCService.swift
//  NeoIRC
//
//  Created by Helge Heß on 21.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import Combine
import IRC
import struct   Foundation.UUID
import class    Dispatch.DispatchQueue
import protocol NIO.EventLoopGroup

public protocol IRCServicePasswordProvider {
  
  func passwordForAccount(_ account : IRCAccount,
                          yield     : @escaping ( IRCAccount, String ) -> Void)
  
}

public final class IRCService: ObservableObject, Identifiable {
  
  public  var id                  : UUID { account.id }
  
  public  let Q                   = DispatchQueue.main
  public  let account             : IRCAccount
  public  let eventLoopGroup      : EventLoopGroup
  public  let passwordProvider    : IRCServicePasswordProvider
  
  private var accountSubscriber   : AnyCancellable?
  private var activeClientOptions : IRCClientOptions?
  
  public enum State: Equatable {
    case suspended
    case offline
    case connecting(IRCClient)
    case online    (IRCClient)
  }
  
  @Published private (set) public var state : State = .suspended {
    didSet {
      guard oldValue != state else { return }
      switch state {
        case .connecting: break
        case .online:
          conversations.values.forEach { $0.serviceDidGoOnline() }
        case .suspended, .offline:
          conversations.values.forEach { $0.serviceDidGoOffline() }
      }
    }
  }
  
  @Published
  private (set) public var conversations : [ String: IRCConversation ] = [:]
  
  @Published private(set) public var messageOfTheDay : String = ""
  
  public init(account          : IRCAccount,
              passwordProvider : IRCServicePasswordProvider,
              eventLoopGroup   : EventLoopGroup)
  {
    self.eventLoopGroup    = eventLoopGroup
    self.passwordProvider  = passwordProvider
    self.account           = account
    self.accountSubscriber = account.objectWillChange.sink {
      [weak self] in self?.handleAccountChange()
    }
    
    activeClientOptions = clientOptionsForAccount(account)
  }
  deinit {
    accountSubscriber?.cancel()
    accountSubscriber = nil
  }
  
  
  // MARK: - Conversations

  public func conversationWithID(_ id: String) -> IRCConversation? {
    return conversations[id.lowercased()]
  }
  
  @discardableResult
  public func registerChannel(_ name: String) -> IRCConversation? {
    let id = name.lowercased()
    if let c = conversations[id] { return c }
    guard let c = IRCConversation(channel: name, service: self) else {
      return nil
    }
    conversations[id] = c
    return c
  }
  public func unregisterChannel(_ name: String) {
    conversations.removeValue(forKey: name.lowercased())?.userDidLeaveChannel()
  }

  @discardableResult
  public func registerDirectMessage(_ name: String) -> IRCConversation? {
    let id = name.lowercased()
    if let c = conversations[id] { return c }
    guard let c = IRCConversation(nickname: name, service: self) else {
      return nil
    }
    conversations[id] = c
    return c
  }

  public func conversationsForRecipient(_ recipient: IRCMessageRecipient,
                                        create: Bool = false)
              -> [ IRCConversation ]
  {
    switch recipient {
      
      case .channel (let name):
        let id = name.stringValue.lowercased()
        if let c = conversations[id] { return [ c ] }
        guard create else { return [] }
        let new = IRCConversation(channel: name, service: self)
        conversations[id] = new
        return [ new ]
      
      case .nickname(let name):
        let id = name.stringValue.lowercased()
        if let c = conversations[id] { return [ c ] }
        guard create else { return [] }
        guard let new = IRCConversation(nickname: name.stringValue,
                                        service: self) else {
          return []
        }
        conversations[id] = new
        return [ new ]
      
      case .everything:
        return Array(conversations.values)
    }
  }
  
  public func conversationsForRecipients(_ recipients: [ IRCMessageRecipient ],
                                         create: Bool = false)
              -> [ IRCConversation ]
  {
    var results = [ ObjectIdentifier : IRCConversation ]()
    for recipient in recipients {
      for conversation in conversationsForRecipient(recipient) {
        results[ObjectIdentifier(conversation)] = conversation
      }
    }
    return Array(results.values)
  }
  
  // MARK: - Lifecycle
  
  public func resume() {
    guard case .suspended = state else { return }
    state = .offline
    connectIfNecessary()
  }
  public func suspend() {
    defer { state = .suspended }
    switch state {
      case .suspended, .offline:
        return
      case .connecting(let client), .online(let client):
        client.close()
    }
  }
  
  
  // MARK: - Sending
  
  @discardableResult
  public func sendMessage(_ message: String, to recipient: IRCMessageRecipient)
              -> Bool
  {
    guard case .online(let client) = state else { return false }
    client.sendMessage(message, to: recipient)
    return true
  }
  
  
  // MARK: - Connection
  
  private func connectIfNecessary() {
    guard case .offline = state else { return }
    guard let options = activeClientOptions else { return }
    
    let client = IRCClient(options: options)
    client.delegate = self

    state = .connecting(client)
    client.connect()
  }
  
  private func handleAccountChange() {
    // TODO: integrate, reconnect if necessary
    connectIfNecessary()
  }
    
  private func clientOptionsForAccount(_ account: IRCAccount)
               -> IRCClientOptions?
  {
    guard let nick = IRCNickName(account.nickname) else {
      return nil
    }
    return IRCClientOptions(port: account.port, host: account.host,
                            password: activeClientOptions?.password,
                            nickname: nick, userInfo: nil,
                            eventLoopGroup: eventLoopGroup)
  }
}


extension IRCService: IRCClientDelegate {
  
  // MARK: - Messages

  public func client(_       client : IRCClient,
                     notice message : String,
                     for recipients : [ IRCMessageRecipient ])
  {
    Q.async {
      self.updateConnectedClientState(client)
      
      // FIXME: this is not quite right, mirror what we do in message
      self.conversationsForRecipients(recipients).forEach {
        $0.addNotice(message)
      }
    }
  }
  public func client(_       client : IRCClient,
                     message        : String,
                     from    sender : IRCUserID,
                     for recipients : [ IRCMessageRecipient ])
  {
    Q.async {
      self.updateConnectedClientState(client)
      
      // FIXME: We need this because for DMs we use the sender as the
      //        name
      for recipient in recipients {
        switch recipient {
          case .channel(let name):
            if let c = self.registerChannel(name.stringValue) {
              c.addMessage(message, from: sender)
            }
          case .nickname: // name should be us
            if let c = self.registerDirectMessage(sender.nick.stringValue) {
              c.addMessage(message, from: sender)
            }
          case .everything:
            self.conversations.values.forEach {
              $0.addMessage(message, from: sender)
            }
        }
      }
    }
  }
  
  public func client(_ client: IRCClient, messageOfTheDay message: String) {
    Q.async {
      self.updateConnectedClientState(client)
      self.messageOfTheDay = message
    }
  }
  
  
  // MARK: - Channels

  public func client(_ client: IRCClient,
                     user: IRCUserID, joined channels: [ IRCChannelName ])
  {
    Q.async {
      self.updateConnectedClientState(client)
      channels.forEach { self.registerChannel($0.stringValue) }
    }
  }
  public func client(_ client: IRCClient,
                     user: IRCUserID, left channels: [ IRCChannelName ],
                     with message: String?)
  {
    Q.async {
      self.updateConnectedClientState(client)
      channels.forEach { self.unregisterChannel($0.stringValue) }
    }
  }

  public func client(_ client: IRCClient,
                     changeTopic welcome: String, of channel: IRCChannelName)
  {
    Q.async {
      self.updateConnectedClientState(client)
      // TODO: operation
    }
  }

  
  // MARK: - Connection

  /**
   * Bring the service online if necessary, update derived properties.
   * This is called by all methods that signal connectivity.
   */
  private func updateConnectedClientState(_ client: IRCClient) {
    switch self.state {
      case .offline, .suspended:
        assertionFailure("not connecting, still getting connected client info")
        return
      
      case .connecting(let ownClient):
        guard client === ownClient else {
          assertionFailure("client mismatch")
          return
        }
        print("going online:", client)
        self.state = .online(client)
        
        let channels = account.joinedChannels.compactMap(IRCChannelName.init)

        // TBD: looks weird. doJoin is for replies?
        client.sendMessage(.init(command: .JOIN(channels: channels, keys: nil)))
      
      case .online(let ownClient):
        guard client === ownClient else {
          assertionFailure("client mismatch")
          return
        }
        // TODO: update state (nick, userinfo, etc)
    }
  }
  
  public func client(_ client        : IRCClient,
                     registered nick : IRCNickName,
                     with   userInfo : IRCUserInfo)
  {
    Q.async { self.updateConnectedClientState(client) }
  }
  public func client(_ client: IRCClient, changedNickTo nick: IRCNickName) {
    Q.async { self.updateConnectedClientState(client) }
  }
  public func client(_ client: IRCClient, changedUserModeTo mode: IRCUserMode) {
    Q.async { self.updateConnectedClientState(client) }
  }

  public func clientFailedToRegister(_ newClient: IRCClient) {
    Q.async {
      switch self.state {
        case .offline, .suspended:
          assertionFailure("not connecting, still get registration failure")
          return
        
        case .connecting(let ownClient), .online(let ownClient):
          guard newClient === ownClient else {
            assertionFailure("client mismatch")
            return
          }
          
          print("Closing client ...")
          ownClient.delegate = nil
          self.state = .offline
          ownClient.close()
      }
    }
  }
}

extension IRCClient: Equatable {
  public static func == (lhs: IRCClient, rhs: IRCClient) -> Bool {
    return lhs === rhs
  }
}

extension IRCService: CustomStringConvertible {
  public var description: String { "<Service: \(account)>" }
}

/// Don't do that at home
extension String: IRCServicePasswordProvider {
  
  public func passwordForAccount(_ account: IRCAccount,
                                 yield: @escaping (IRCAccount, String) -> Void)
  {
    yield(account, self)
  }
}
