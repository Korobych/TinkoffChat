//
//  FetchesRequestManager.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 13.11.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation
import CoreData

class FetchedRequestsManager {
    let objectModel: NSManagedObjectModel?
    
    init(objectModel: NSManagedObjectModel?) {
        self.objectModel = objectModel
    }
    
    func fetchRequestAllConversations() -> NSFetchRequest<Conversation>? {
        let fetchRequest = NSFetchRequest<Conversation>(entityName: "Conversation")
        return fetchRequest
    }
    
    func fetchRequestAllOnlineConversations() -> NSFetchRequest<Conversation>? {
        let fetchRequest = NSFetchRequest<Conversation>(entityName: "Conversation")
        let predicate = NSPredicate(format: "user.online == %@", NSNumber(value: true))
        fetchRequest.predicate = predicate
        return fetchRequest
    }
    
    func fetchRequestFindConversationWithID(id: String) -> NSFetchRequest<Conversation>? {
        if let model = objectModel {
            return Conversation.fetchRequestFindConversationWithID(id: id, withModel: model)
        } else {
            print("Error with model")
            return nil
        }
    }
    
    func fetchRequestFindUserWithID(id: String) -> NSFetchRequest<User>? {
        if let model = objectModel {
            return User.fetchRequestFindUserWithID(id: id, withModel: model)
        } else {
            print("Error with model")
            return nil
        }
    }
    
    func fetchRequestMessagesWithConversationID(id: String) -> NSFetchRequest<Message>? {
        if let model = objectModel {
            return Message.fetchRequestMessagesWithConversationID(id: id, withModel: model)
        } else {
            print("Error with model")
            return nil
        }
    }
    
}


