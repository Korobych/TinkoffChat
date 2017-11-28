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
    lazy var fallingAnimation = FallingAnimation(objectImage: #imageLiteral(resourceName: "tinkoff_bank_general_logo"), to: view)


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
        if indexPath.section == 0 {
            let selectedDialog = communicationManager.onlineDialogs[indexPath.row]
            // Logic of reading message added (now label unreadMessage would change in
            // ConversationListViewController and on screen respectively)
            selectedDialog.hasUnreadMessages = false
            // perform segue
            performSegue(withIdentifier: "moveToConversation", sender: selectedDialog)
        }
        if indexPath.section == 1{
            let selectedDialog = communicationManager.offlineDialogs[indexPath.row]
            selectedDialog.hasUnreadMessages = false
            // perform segue
            performSegue(withIdentifier: "moveToConversation", sender: selectedDialog)
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    // smooth animation for the cell's update
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.4, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        })
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! DialogCustomCell
        if indexPath.section == 0{
            let dialogData: ConversationProtocol?
            dialogData = communicationManager.onlineDialogs[indexPath.row]
            if let data = dialogData {
                cell.setupCell(name: data.name, message: data.lastMessage, date: data.date, online: data.online, unread: data.hasUnreadMessages)
                UIView.animate(withDuration: 1, animations: {
                    cell.backgroundColor = UIColor.yellow.withAlphaComponent(0.4)
                })
            }
                else{
                print("error")
            }
        }
        if indexPath.section == 1{
            let dialogData: ConversationProtocol?
            dialogData = communicationManager.offlineDialogs[indexPath.row]
            if let data = dialogData {
                cell.setupCell(name: data.name, message: data.lastMessage, date: data.date, online: data.online, unread: data.hasUnreadMessages)
                cell.backgroundColor = UIColor.white
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
        fallingAnimation.gestureRecognizerSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
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
