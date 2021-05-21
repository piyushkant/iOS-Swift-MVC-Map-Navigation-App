//
//  UIButton+Ex.swift
//  MapX
//
//  Created by Piyush Kant on 2021/05/21.
//

import UIKit

extension UIButton {
    func setStyle() {
        setTitleColor(.white, for: .normal)
        backgroundColor = UIColor(hexString: "#4970bf")
//        layer.borderWidth = 1.0
        layer.cornerRadius = 5.0
        titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
    }
}

//extension UIButton {
//    func setBordersSettings() {
//        self.layer.borderWidth = 1.0
//        self.layer.cornerRadius = 5.0
//        self.layer.borderColor = UIColor(hexString: "#4970bf").cgColor
//        self.layer.masksToBounds = true
//    }
//}
