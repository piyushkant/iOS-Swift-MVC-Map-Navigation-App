//
//  SDKType.swift
//  MapX
//
//  Created by Piyush Kant on 2021/05/23.
//

import Foundation

enum SDKType: String, CustomStringConvertible {
    case mapKit = "MapKit"
    case mapbox = "Mapbox"
    case googleMaps = "Google Maps"
    
    var description: String {
        get {
            return self.rawValue
        }
    }
}
