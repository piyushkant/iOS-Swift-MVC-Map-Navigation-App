//
//  CLPlacemark+Ex.swift
//  MapX
//
//  Created by Piyush Kant on 2021/05/21.
//

import CoreLocation

extension CLPlacemark {
    var shortAddress: String {
        if let name = self.name {
            return name
        }
        
        if let interestingPlace = areasOfInterest?.first {
            return interestingPlace
        }
        
        return [subThoroughfare, thoroughfare].compactMap { $0 }.joined(separator: " ")
    }
}
