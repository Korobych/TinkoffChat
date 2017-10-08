//
//  DialogCustomCell.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 06.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import UIKit

extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
}

class DialogCustomCell: UITableViewCell {
    
    
    @IBOutlet weak var dialogPartnerNameLabel: UILabel!
    
    @IBOutlet weak var dialogPartnerLastMessageLabel: UILabel!
    
    @IBOutlet weak var dialogPartnerLastMessageDateLabel: UILabel!
    
    
    func setupCell(name: String?, message: String?, date: Date?, online: Bool, unread: Bool){
        let dateFormatter = DateFormatter()
        if date != nil{
            if date! < Date().yesterday{
                dateFormatter.setLocalizedDateFormatFromTemplate("dd MMM")
            } else{
                dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
            }
        }
        // !!!!! ТУТ ЛОГИКА НА ПРОВЕРКУ ГДЕ ТО !!! можно вынести в другую функцию
        if message == nil{
            dialogPartnerLastMessageLabel.font = UIFont(name: "HelveticaNeue-LightItalic", size: 14)
            dialogPartnerLastMessageLabel.text = "No messages yet"
        }
        else{
            if unread{
                dialogPartnerLastMessageLabel.font = UIFont.boldSystemFont(ofSize: 15)
            } else
            {
                dialogPartnerLastMessageLabel.font = UIFont(name: "System", size: 14)
            }
            dialogPartnerLastMessageLabel.text = message
        }
        
        dialogPartnerNameLabel.text = name
        dialogPartnerLastMessageDateLabel.text = dateFormatter.string(for: date)
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

}
