//
//  CoreDataExtentions.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 06.11.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation
import CoreData
import UIKit
//*************************//
// AppUser Entity extension
//*************************//
extension AppUser {
    
    static func findOrInsertAppUser(in context: NSManagedObjectContext) -> AppUser? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            assertionFailure("Model is not available in context")
            return nil
        }
        var appUser: AppUser?
        guard let fetchRequest = AppUser.fetchRequestAppUser(withModel: model) else {
            return nil
        }
        
        
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count < 2, "Multiple AppUsers found!")
            if let foundUser = results.first {
                appUser = foundUser
            }
        } catch {
            print("Failed to fetch AppUser: \(error.localizedDescription)")
        }
        
        if appUser == nil {
            appUser = AppUser.insertAppUser(in: context)
        }
        
        
        return appUser
    }
    
    static func insertAppUser(in context: NSManagedObjectContext) -> AppUser? {
        if let appUser = NSEntityDescription.insertNewObject(forEntityName: "AppUser", into: context) as? AppUser {
            if appUser.currentUser == nil {
                let currentUser = User.findOrInsertAppUser(with: User.generatedUserIdString, in: context)
                appUser.currentUser = currentUser
            }
            return appUser
        }
        
        return nil
    }
    
    static func fetchRequestAppUser(withModel model: NSManagedObjectModel) -> NSFetchRequest<AppUser>? {
        let templateName = "AppUser"
        guard let fetchRequest = model.fetchRequestTemplate(forName: templateName) as? NSFetchRequest<AppUser> else {
            assertionFailure("No template with name: \(templateName)")
            return nil
        }
        
        return fetchRequest
    }
    
}

//*************************//
// User Entity extension
//*************************//
extension User {
    
    static func findOrInsertAppUser(with id: String, in context: NSManagedObjectContext) -> User? {
        if let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User {
            user.userID = id
            return user
        }
        return nil
    }
    
    static var generatedUserIdString: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    // added in new HW8
    static func allUsers(inContext context: NSManagedObjectContext) -> [User]? {
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch {
            print("Failed to fetch all Users: \(error)")
            return nil
        }
    }
    // added in new HW8
    static func fetchRequestFindUserWithID(id: String, withModel model: NSManagedObjectModel) -> NSFetchRequest<User>? {
        let templateName = "FindUserWithID"
        let data = ["userID" : id]
        guard let fetchRequest = model.fetchRequestFromTemplate(withName: templateName, substitutionVariables: data) as? NSFetchRequest<User>
        else {
            print("No template with name: \(templateName)")
            return nil
        }
        
        return fetchRequest.copy() as? NSFetchRequest<User>
    }
    
    // added new HW8
    static func fetchRequestUsersOnline(withModel model: NSManagedObjectModel) -> NSFetchRequest<User>? {
        let templateName = "UsersOnline"
        guard let fetchRequest = model.fetchRequestTemplate(forName: templateName) as? NSFetchRequest<User>
        else {
            print("No template with name: \(templateName)")
            return nil
        }
        
        return fetchRequest.copy() as? NSFetchRequest<User>
    }
}

//*************************//
// Conversation Entity extension
//*************************//
extension Conversation {
    
    // added in new HW8
    static func findOrInsertConversation(withID id: String, in context: NSManagedObjectContext) -> Conversation? {
        var conversation: Conversation?
        let fetchRequest = NSFetchRequest<Conversation>(entityName: "Conversation")
        let predicate = NSPredicate(format: "userID == %@", id)
        let sortDescriptor = NSSortDescriptor(key: "userID", ascending: true)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        // check if 2 simular id's
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count < 2, "Multiple conversations with the same id!")
            if let foundConversation = results.first {
                conversation = foundConversation
            }
        } catch {
            print("Failed to fetch Conversation: \(error)")
        }
        
        if conversation == nil {
            conversation = Conversation.insertConversation(with: id, in: context)
        }
        return conversation
    }
    
    // added in new HW8
    static func insertConversation(with id: String, in context: NSManagedObjectContext) -> Conversation? {
        if let conversation = NSEntityDescription.insertNewObject(forEntityName: "Conversation", into: context) as? Conversation {
            conversation.userID = id
            conversation.hasUnreadMessages = false
            return conversation
        }
        return nil
    }
    
    // added in new HW8
    static func fetchRequestFindConversationWithID(id: String, withModel model: NSManagedObjectModel) -> NSFetchRequest<Conversation>? {
        let templateName = "FindConversationWithID"
        let data = ["userID" : id]
        guard let fetchRequest = model.fetchRequestFromTemplate(withName: templateName, substitutionVariables: data) as? NSFetchRequest<Conversation>
        else {
            assertionFailure("No template with name: \(templateName)")
            return nil
        }
        
        return fetchRequest.copy() as? NSFetchRequest<Conversation>
    }
}

//*************************//
// Message Entity extension
//*************************//
extension Message {
    
    // added in new HW8
    static func insertMessage(withID id: String, inContext context: NSManagedObjectContext) -> Message? {
        if let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as? Message {
            message.messageID = id
            message.date = Date()
            return message
        }
        return nil
    }
    
    // added in new HW8
    static func fetchRequestMessagesWithConversationID(id: String, withModel model: NSManagedObjectModel) -> NSFetchRequest<Message>? {
        let templateName = "MessagesWithConversationID"
        let data = ["userID" : id]
        guard let fetchRequest = model.fetchRequestFromTemplate(withName: templateName, substitutionVariables: data) as? NSFetchRequest<Message>
        else {
            assertionFailure("No template with name: \(templateName)")
            return nil
        }
        
        return fetchRequest.copy() as? NSFetchRequest<Message>
    }
}



