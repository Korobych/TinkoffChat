//
//  FRCConversationsList.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 14.11.17.
//  Copyright © 2017 Sergey. All rights reserved.
//
import Foundation
import UIKit
import CoreData

protocol FRCConversationListProtocol {
    var fetchedResultsForConversationsList: NSFetchedResultsController<Conversation>? { get set }
    var tableView: UITableView? { get set }
}

class FRCConversationsList: NSObject, FRCConversationListProtocol {
    var fetchedResultsForConversationsList: NSFetchedResultsController<Conversation>?
    var tableView: UITableView? {
        didSet{
            do { try self.fetchedResultsForConversationsList?.performFetch()
                self.tableView?.reloadData() }
            catch{
                print("Can't fetch. \(error.localizedDescription)")
            }
        }
    }
    let dataStack: CoreDataStackProtocol
    
    init(with stack: CoreDataStackProtocol) {
        self.dataStack = stack
        let context = stack.mainContext
        var persistentStoreCoordinator = context?.persistentStoreCoordinator
        if let parent = context?.parent {
            persistentStoreCoordinator = parent.persistentStoreCoordinator
        }
        let fetchRequestsManager = FetchedRequestsManager(objectModel: persistentStoreCoordinator?.managedObjectModel)
        guard let fetchRequest = fetchRequestsManager.fetchRequestAllOnlineConversations()
        else {
            fetchedResultsForConversationsList = nil
            //
            super.init()
            return
        }
        
        super.init()
        // sort descriptor
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Conversation.lastMessage.date), ascending: false)]
        fetchedResultsForConversationsList = NSFetchedResultsController<Conversation>(fetchRequest: fetchRequest, managedObjectContext: context!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsForConversationsList?.delegate = self
    }
}

// *** FRC delegate ***
extension FRCConversationsList: NSFetchedResultsControllerDelegate {
    
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

