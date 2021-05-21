//
//  TimeTravel+Ex.swift
//  MapX
//
//  Created by Piyush Kant on 2021/05/21.
//

import Foundation

extension TimeInterval {
    var formatted: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        
        return formatter.string(from: self) ?? ""
    }
}
