//
//  IRCAccount.swift
//  NeoIRC
//
//  Created by Helge Heß on 21.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import Combine
import struct Foundation.UUID
import let NIOIRC.DefaultIRCPort

public final class IRCAccount: ObservableObject, Codable, Identifiable {
  
  public            let id               : UUID
  @Published public var host             : String
  @Published public var port             : Int
  @Published public var nickname         : String
  @Published public var activeRecipients : [ String ]
  
  public var joinedChannels : [ String ] {
    return activeRecipients.filter { $0.hasPrefix("#") }
  }
  
  public init(id: UUID = UUID(),
              host: String, port: Int = DefaultIRCPort,
              nickname: String,
              activeRecipients: [ String ] = [ "#NIO", "#SwiftDE" ])
  {
    self.id               = id
    self.host             = host
    self.port             = port
    self.nickname         = nickname
    self.activeRecipients = activeRecipients
  }
  
  
  // MARK: - Arrgh, Codable
  
  enum CodingKeys: CodingKey {
    case id, host, port, nickname, activeRecipients
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.id       = try container.decode(UUID.self,   forKey: .id)
    self.host     = try container.decode(String.self, forKey: .host)
    self.port     = try container.decode(Int.self,    forKey: .port)
    self.nickname = try container.decode(String.self, forKey: .nickname)
    self.activeRecipients =
      try container.decode([String].self, forKey: .activeRecipients)
  }
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(id,               forKey: .id)
    try container.encode(host,             forKey: .host)
    try container.encode(port,             forKey: .port)
    try container.encode(nickname,         forKey: .nickname)
    try container.encode(activeRecipients, forKey: .activeRecipients)
  }
}

extension IRCAccount: CustomStringConvertible {
  public var description: String {
    var ms = "<Account: \(id) \(host):\(port) \(nickname)"
    ms += " " + activeRecipients.joined(separator: ",")
    ms += ">"
    return ms
  }
}
