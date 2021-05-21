//
//  UITextField+Ex.swift
//  MapX
//
//  Created by Piyush Kant on 2021/05/21.
//

import UIKit

extension UITextField {
    var contents: String? {
        guard
            let text = text?.trimmingCharacters(in: .whitespaces),
            !text.isEmpty
        else {
            return nil
        }
        
        return text
    }
}

