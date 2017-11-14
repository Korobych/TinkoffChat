//
//  DialogCustomOnlineCellData.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 06.11.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation

class DialogCustomOnlineCellData : ConversationProtocol{
    var userID: String?
    var name: String?
    var lastMessage: String?{
        return messagesStore.last?.text
    }
    var messagesStore: [ReceivedMessageData]
    var date: Date?{
        return messagesStore.last?.date
    }
    var online = true
    var hasUnreadMessages: Bool
    
    init(userID: String?, name: String?, hasUnreadMessages: Bool = false, messagesStore :[ReceivedMessageData] = [] ) {
        self.userID = userID
        // conversationID: String? TODO
        self.name = name
        self.messagesStore = messagesStore
        self.hasUnreadMessages = hasUnreadMessages
    }
}

