//
//  CampusMapOverlay.swift
//  cs407
//
//  Created by Ashley Nussel on 2/14/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class CampusMapOverlay: NSObject, MKOverlay {
    
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    
    init(campus: Campus) {
        boundingMapRect = campus.overlayBoundingMapRect
        coordinate = campus.midCoordinate
    }
}
