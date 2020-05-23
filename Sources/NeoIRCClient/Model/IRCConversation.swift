//
//  IRCConversation.swift
//  NeoIRC
//
//  Created by Helge Heß on 22.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Date
import Combine
import IRC

public final class IRCConversation: ObservableObject, Identifiable {
  
  public enum ConversationType: Equatable {
    case channel
    case im
  }
  
  public var recipient : IRCMessageRecipient? {
    switch type {
      case .channel:
        guard let name = IRCChannelName(name) else { return nil }
        return .channel(name)
      case .im:
        guard let name = IRCNickName(name)    else { return nil }
        return .nickname(name)
    }
  }
  
  public private(set) weak var service : IRCService?
  
  public var type : ConversationType
  public var name : String
  public var id   : String { return name }
  
  @Published var timeline = [ IRCTimelineEntry ]()
  
  init(channel: IRCChannelName, service: IRCService) {
    self.type      = .channel
    self.name      = channel.stringValue
    self.service   = service
  }
  init?(nickname: String, service: IRCService) {
    self.type      = .im
    self.name      = nickname
    self.service   = service
  }

  convenience init?(channel: String, service: IRCService) {
    guard let name = IRCChannelName(channel) else { return nil }
    self.init(channel: name, service: service)
  }

  
  // MARK: - Subscription Changes
  
  internal func userDidLeaveChannel() {
    // have some state reflecting that?
  }
  
  
  // MARK: - Connection Changes
  
  internal func serviceDidGoOffline() {
    guard let last = timeline.last else { return }
    if case .disconnect = last.payload { return }
    
    timeline.append(.init(date: Date(), payload: .disconnect))
  }
  internal func serviceDidGoOnline() {
    guard let last = timeline.last else { return }
    
    switch last.payload {
      case .reconnect, .message, .notice, .ownMessage:
        return
      case .disconnect:
        break
    }
    
    timeline.append(.init(date: Date(), payload: .reconnect))
  }
  
  
  // MARK: - Sending Messages

  @discardableResult
  public func sendMessage(_ message: String) -> Bool {
    guard let recipient = recipient                   else { return false }
    guard let service = service                       else { return false }
    guard service.sendMessage(message, to: recipient) else { return false }
    timeline.append(.init(payload: .ownMessage(message)))
    return true
  }
  
  
  // MARK: - Receiving Messages
  
  public func addMessage(_ message: String, from sender: IRCUserID) {
    timeline.append(.init(payload: .message(message, sender)))
  }
  public func addNotice(_ message: String) {
    timeline.append(.init(payload: .notice(message)))
  }
}

extension IRCConversation: CustomStringConvertible {
  public var description: String { "<Conversation: \(type) \(name)>" }
}
