//
//  DialogCustomCell.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 06.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import UIKit
// для удобства вызова вчерашней даты (необходимо для проверки на замену формата вывода даты последнего сообщения)
extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
}
// Класс ячейки диалогов
class DialogCustomCell: UITableViewCell {
    
    // Name
    @IBOutlet weak var dialogPartnerNameLabel: UILabel!
    //Content of the last message
    @IBOutlet weak var dialogPartnerLastMessageLabel: UILabel!
    //Date of the last message
    @IBOutlet weak var dialogPartnerLastMessageDateLabel: UILabel!
    
    
    func setupCell(name: String?, message: String?, date: Date?, online: Bool, unread: Bool){
        // Logic of changing data format if the message is 'older' than 1 day
        let dateFormatter = DateFormatter()
        if date != nil{
            if date! < Date().yesterday{
                dateFormatter.setLocalizedDateFormatFromTemplate("dd MMM")
            } else{
                dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
            }
        }
        //logic of checking nil message content + changing font if its true
        if message == nil{
            dialogPartnerLastMessageLabel.font = UIFont(name: "HelveticaNeue-LightItalic", size: 14)
            dialogPartnerLastMessageLabel.text = "No messages yet"
        }
        else{
            // logic of changing font to bold if its unread message
            if unread{
                dialogPartnerLastMessageLabel.font = UIFont.boldSystemFont(ofSize: 15)
            } else
            {
                dialogPartnerLastMessageLabel.font = UIFont(name: "HelveticaNeue-LightItalic", size: 14)
            }
            dialogPartnerLastMessageLabel.text = message
        }
        
        dialogPartnerNameLabel.text = name
        dialogPartnerLastMessageDateLabel.text = dateFormatter.string(for: date)
    }

    

}
