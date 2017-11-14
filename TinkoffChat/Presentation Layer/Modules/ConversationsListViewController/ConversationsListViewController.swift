//
//  ConversationsListViewController.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 06.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import UIKit

class ConversationsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CommunicationManagerDelegateProtocol{
    
    @IBOutlet weak var dialogsTableView: UITableView!
    var communicationManager: CommunicationManagerProtocol = CommunicationManager()
    private let dataManager: DataManagerProtocol = GCDDataManager()
    private var model: ProfileManagerProtocol = ProfileManager()

    func reloadAfterChange() {
        DispatchQueue.main.async {
            self.dialogsTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            return communicationManager.onlineDialogs.count
        }
        else{
            return communicationManager.offlineDialogs.count
        }
    }
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDialog = communicationManager.onlineDialogs[indexPath.row]
        // Logic of reading message added (now label unreadMessage would change in
        // ConversationListViewController and on screen respectively)
        selectedDialog.hasUnreadMessages = false
        tableView.deselectRow(at: indexPath, animated: true)
        // perform segue
        performSegue(withIdentifier: "moveToConversation", sender: selectedDialog)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moveToConversation" {
            let nextViewController = segue.destination as! ConversationViewController
            nextViewController.conversation = sender as! ConversationProtocol
            nextViewController.communicationManager = communicationManager
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Online"
        } else{
            return "History"
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! DialogCustomCell
        if indexPath.section == 0{
            let dialogData: ConversationProtocol?
            dialogData = communicationManager.onlineDialogs[indexPath.row]
            if let data = dialogData {
                cell.setupCell(name: data.name, message: data.lastMessage, date: data.date, online: data.online, unread: data.hasUnreadMessages)
                cell.backgroundColor = UIColor.yellow.withAlphaComponent(0.4)
            }
                else{
                print("error")
            }
        }
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dialogsTableView.dataSource = self
        self.dialogsTableView.delegate = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        communicationManager.communicationManagerDelegate = self
        model.delegate = self
        model.getProfileInfo()
    }
}

extension ConversationsListViewController: ProfileManagerDelegateProtocol{

    
    func didGet(profileViewModel: ProfileViewModel) {
        let username = profileViewModel.name
        communicationManager.displayedName = username
        communicationManager.online = true
        }
    
    func didFinishSave(success: Bool) {
        print("Success")
    }
}
