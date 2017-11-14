//
//  OutgoingMessageCustomCell.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 08.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import UIKit

class OutgoingMessageCustomCell: UITableViewCell {
    
    @IBOutlet weak var outgoingMessageText: UILabel!
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.size.width = UIScreen.main.bounds.width * 0.75
            frame.origin.x += frame.size.width * 0.3
            super.frame = frame
        }
    }
    
    func setupCell(message: String?){
        outgoingMessageText.text = message
    }
    //QUICKFIX: При разработке возникла ошибка при переносе слов, автоматисеские значения ширины срезают кусок текста, ручное установление параметров решает проблему и текст при большом количестве символов выводится адекватно
    func messageCellFixing(){
        if frame.size.width < 250 {
            outgoingMessageText.preferredMaxLayoutWidth = 220
        }else if  frame.size.width < 310{
            outgoingMessageText.preferredMaxLayoutWidth = 265
        } 
    }


}
