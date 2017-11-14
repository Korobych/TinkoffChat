//
//  FRCConversation.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 14.11.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol FRCConversationProtocol {
    var fetchedResultsForConversation: NSFetchedResultsController<Message>? { get set }
    var tableView: UITableView? { get set }
}

class FRCConversation: NSObject, FRCConversationProtocol {
    var fetchedResultsForConversation: NSFetchedResultsController<Message>?
    var tableView: UITableView? {
        didSet{
            do { try self.fetchedResultsForConversation?.performFetch()
                self.tableView?.reloadData() }
            catch{
                print("Can't fetch. \(error.localizedDescription)")
            }
        }
    }
    let dataStack: CoreDataStackProtocol
    
    init(with stack: CoreDataStackProtocol, userID: String) {
        self.dataStack = stack
        let context = stack.mainContext
        var persistentStoreCoordinator = context?.persistentStoreCoordinator
        if let parent = context?.parent {
            persistentStoreCoordinator = parent.persistentStoreCoordinator
        }
        let fetchRequestsManager = FetchedRequestsManager(objectModel: persistentStoreCoordinator?.managedObjectModel)
        guard let fetchRequest = fetchRequestsManager.fetchRequestMessagesWithConversationID(id: userID)
            else {
                fetchedResultsForConversation = nil
                //
                super.init()
                return
        }
        
        super.init()
        // sort descriptor
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Message.date), ascending: true)]
        fetchedResultsForConversation = NSFetchedResultsController<Message>(fetchRequest: fetchRequest,
            managedObjectContext: context!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsForConversation?.delegate = self
    }
}

// *** FRC delegate ***
extension FRCConversation: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    
                    didChange anObject: Any,
                    
                    at indexPath: IndexPath?,
                    
                    for type: NSFetchedResultsChangeType,
                    
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView?.deleteRows(at: [indexPath], with: .automatic)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView?.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath {
                tableView?.deleteRows(at: [indexPath], with: .automatic)
            }
            
            if let newIndexPath = newIndexPath {
                tableView?.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                tableView?.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .delete:
            tableView?.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .insert:
            tableView?.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .move, .update : break
            
        }
    }
}

