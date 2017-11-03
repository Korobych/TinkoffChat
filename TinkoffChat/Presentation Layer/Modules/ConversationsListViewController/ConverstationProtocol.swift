//
//  ConverstationProtocol.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 31.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation

protocol ConversationProtocol: class{
    var userID: String? {get set}
    var name: String? {get set}
    var lastMessage: String? {get}
    var date: Date? {get}
    var messagesStore: [ReceivedMessageData] {get set}
    var online: Bool {get set}
    var hasUnreadMessages: Bool {get set}
    
}


