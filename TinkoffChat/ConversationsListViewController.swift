//
//  ConversationsListViewController.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 06.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import UIKit

protocol ConversationCellConfiguration{
    var name: String? {get set}
    var message: String? {get set}
    var date: Date? {get set}
    var online: Bool {get set}
    var hasUnreadMessages: Bool {get set}
    
}
class DialogCustomOnlineCellData : ConversationCellConfiguration{
    var name: String?
    
    var message: String?
    
    var date: Date?
    
    var online = true
    
    var hasUnreadMessages: Bool
    
    init(name: String?, message: String?, date: Date?, hasUnreadMessages: Bool ) {
        self.name = name
        self.message = message
        self.date = date
        self.hasUnreadMessages = hasUnreadMessages
        // Квик фикс на случай отсутствия сообщения, при том что флаг пропущенного сообещния и его дата (вдруг) появятся
        if message == nil{
            self.date = nil
            self.hasUnreadMessages = false
        }
    }
}
class DialogCustomOfflineCellData : ConversationCellConfiguration{
    var name: String?
    
    var message: String?
    
    var date: Date?
    
    var online = false
    
    var hasUnreadMessages: Bool
    
    init(name: String?, message: String?, date: Date?, hasUnreadMessages: Bool ) {
        self.name = name
        self.message = message
        self.date = date
        self.hasUnreadMessages = hasUnreadMessages
        // Квик фикс на случай отсутствия сообщения, при том что флаг пропущенного сообещния и его дата (вдруг) появятся
        if message == nil{
            self.date = nil
            self.hasUnreadMessages = false
        }
    }
}

class ConversationsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var dialogsTableView: UITableView!
    var datasetOnline = [DialogCustomOnlineCellData]()
    var datasetOffline = [DialogCustomOfflineCellData]()
    let currentDateTime = Date()
    var sendingTitleString: String?
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            return datasetOnline.count
        }
        else{
            return datasetOffline.count
        }
    }
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            sendingTitleString = datasetOnline[indexPath.row].name
        }
        else {
            sendingTitleString = datasetOffline[indexPath.row].name
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "moveToConversation", sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Online"
        } else{
            return "History"
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell") as! DialogCustomCell
        if indexPath.section == 0{
            cell.setupCell(name: datasetOnline[indexPath.row].name, message: datasetOnline[indexPath.row].message, date: datasetOnline[indexPath.row].date, online: datasetOnline[indexPath.row].online, unread: datasetOnline[indexPath.row].hasUnreadMessages)
            cell.backgroundColor = UIColor.yellow.withAlphaComponent(0.4)
        }
        if indexPath.section == 1{
            cell.setupCell(name: datasetOffline[indexPath.row].name, message: datasetOffline[indexPath.row].message, date: datasetOffline[indexPath.row].date, online: datasetOffline[indexPath.row].online, unread: datasetOffline[indexPath.row].hasUnreadMessages)
            cell.backgroundColor = UIColor.white
        }
        return cell
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dialogsTableView.dataSource = self
        self.dialogsTableView.delegate = self
        
        datasetOnline.append(DialogCustomOnlineCellData(name: "Barson Barson", message: "Daayamn son! It's triple", date: Date(timeIntervalSinceReferenceDate: -125.2), hasUnreadMessages: false))
        datasetOnline.append(DialogCustomOnlineCellData(name: "Michail Medetskyi", message: "It's a kek man", date: currentDateTime, hasUnreadMessages: true))
        datasetOnline.append(DialogCustomOnlineCellData(name: "Andrey Sizov", message: "Hi, boy! Would you like some cookies?", date: currentDateTime, hasUnreadMessages: true))
        datasetOnline.append(DialogCustomOnlineCellData(name: "Anton Sherbakov", message: "C'mon bro. Do something already. xD", date: Date(timeIntervalSinceReferenceDate: -15.5), hasUnreadMessages: false))
        datasetOnline.append(DialogCustomOnlineCellData(name: "Diman", message: nil, date: currentDateTime - 1, hasUnreadMessages: false))
        
        // ----///
        datasetOffline.append(DialogCustomOfflineCellData(name: "Tonya Alaeva", message: "Pythonить!", date: currentDateTime, hasUnreadMessages: false))
        datasetOffline.append(DialogCustomOfflineCellData(name: "Mashtak V Shopy Kulak", message: nil, date: currentDateTime - 1, hasUnreadMessages: true))
        datasetOffline.append(DialogCustomOfflineCellData(name: "Mishakin Kolya", message: "Где моя домашка, мазафакер? А ну иди сюда, ты гавно собачье", date: Date(timeIntervalSinceReferenceDate: -0.8), hasUnreadMessages: false))
        datasetOffline.append(DialogCustomOfflineCellData(name: "Ганджелло", message: "Гоу пить пиво, рыж", date: currentDateTime, hasUnreadMessages: true))
        datasetOffline.append(DialogCustomOfflineCellData(name: "Ден", message: "Рок'н'ролл, детка. Кнэээээээээк бичары", date: Date(timeIntervalSinceReferenceDate: -1.5), hasUnreadMessages: true))
        datasetOffline.append(DialogCustomOfflineCellData(name: "Mashtak V Shopy Kulak", message: nil, date: currentDateTime, hasUnreadMessages: true))
        datasetOffline.append(DialogCustomOfflineCellData(name: "Mishakin Kolya", message: "Где моя домашка, мазафакер? А ну иди сюда, ты гавно собачье", date: Date(timeIntervalSinceReferenceDate: -0.8), hasUnreadMessages: false))
        datasetOffline.append(DialogCustomOfflineCellData(name: "Ганджелло", message: "Гоу пить пиво, рыж", date: currentDateTime, hasUnreadMessages: true))

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "moveToConversation") {
            let nextViewController = segue.destination as! ConversationViewController
            // your new view controller should have property that will store passed value
            nextViewController.dialogPersonNameString = self.sendingTitleString
        }
    }
    


}
