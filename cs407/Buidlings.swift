//
//  Buidlings.swift
//  cs407
//
//  Created by Ashley Nussel on 2/21/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import Foundation
import MapKit

class Buildings: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    //This will be used if we use an array of JSON to hold the building info
    /*init?(json: [Any]) {
        // 1
        if let title = json[16] as? String {
            self.title = title
        } else {
            self.title = "No Title"
        }
        // json[11] is the long description
        self.locationName = json[11] as! String
        // json[12] is the short location string
        //    self.locationName = json[12] as! String
        self.discipline = json[15] as! String
        // 2
        if let latitude = Double(json[18] as! String),
            let longitude = Double(json[19] as! String) {
            self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            self.coordinate = CLLocationCoordinate2D()
        }
    }*/
    
    var subtitle: String? {
        return locationName
    }
}
