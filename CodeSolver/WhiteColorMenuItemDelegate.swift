//
//  WhiteColorMenuItemDelegate.swift
//  CodeSolver
//
//  Created by Apple on 16/12/2.
//  Copyright © 2016年 Findaldudu. All rights reserved.
//

import Cocoa
import Foundation

class WhiteColorMenuItemDelegate: NSObject, NSMenuDelegate {

    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        if let ite = item
        {
            if menu.isEqual(menu.item(at: 3)) || menu.isEqual(menu.item(at: 4)){
                ite.attributedTitle = NSAttributedString(string: ite.title, attributes: [NSForegroundColorAttributeName:NSColor.black])
            }
        }
    }
    
}
