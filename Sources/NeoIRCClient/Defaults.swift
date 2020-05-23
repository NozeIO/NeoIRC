//
//  Defaults.swift
//  NeoIRC
//
//  Created by Helge Heß on 22.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import class Foundation.UserDefaults

enum UserDefaultKeys: String {
  
  // MARK: - Navigation
  case lastAccountID
  case lastConversationID
  
  // MARK: - Accounts Database
  case accounts
}

extension UserDefaults {
  
  func set(_ value: String, forKey key: UserDefaultKeys) {
    set(value, forKey: key.rawValue)
  }
  func set(_ value: String?, forKey key: UserDefaultKeys) {
    set(value, forKey: key.rawValue)
  }
  
  func string(forKey key: UserDefaultKeys) -> String? {
    return string(forKey: key.rawValue)
  }
}

import struct Foundation.Data
import class  Foundation.JSONSerialization
import class  Foundation.JSONEncoder
import class  Foundation.JSONDecoder

extension UserDefaults {
  
  func decode<T: Decodable>(_ type: T.Type, forKey key: UserDefaultKeys) throws
       -> T?
  {
    let jsonData : Data = data(forKey: key.rawValue) ?? {
      guard let plist = value(forKey: key.rawValue) else { return nil }
      return try? JSONSerialization.data(withJSONObject: plist, options: [])
    }() ?? Data()
    
    return try JSONDecoder().decode(type, from: jsonData)
  }
  
  func encode<T: Encodable>(_ object: T, forKey key: UserDefaultKeys) throws {
    let jsonData = try JSONEncoder().encode(object)
    let plist = try JSONSerialization.jsonObject(with: jsonData, options: [])
    setValue(plist, forKey: key.rawValue)
  }
}
