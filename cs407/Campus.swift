//
//  Campus.swift
//  cs407
//
//  Created by Ashley Nussel on 2/14/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class Campus {
    var name: String?
    var boundary: [CLLocationCoordinate2D] = []
    
    var midCoordinate = CLLocationCoordinate2D()
    var overlayTopLeftCoordinate = CLLocationCoordinate2D()
    var overlayTopRightCoordinate = CLLocationCoordinate2D()
    var overlayBottomLeftCoordinate = CLLocationCoordinate2D()
    var overlayBottomRightCoordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(overlayBottomLeftCoordinate.latitude,
                                              overlayTopRightCoordinate.longitude)
        }
    }
    
    var overlayBoundingMapRect: MKMapRect {
        get {
            let topLeft = MKMapPointForCoordinate(overlayTopLeftCoordinate);
            let topRight = MKMapPointForCoordinate(overlayTopRightCoordinate);
            let bottomLeft = MKMapPointForCoordinate(overlayBottomLeftCoordinate);
            
            return MKMapRectMake(
                topLeft.x,
                topLeft.y,
                fabs(topLeft.x - topRight.x),
                fabs(topLeft.y - bottomLeft.y))
        }
    }
    
    init(filename: String) {
        guard let properties = Campus.plist(filename) as? [String : Any],
            let boundaryPoints = properties["boundary"] as? [String] else { return }
        
        midCoordinate = Campus.parseCoord(dict: properties, fieldName: "midCoord")
        overlayTopLeftCoordinate = Campus.parseCoord(dict: properties, fieldName: "overlayTopLeftCoord")
        overlayTopRightCoordinate = Campus.parseCoord(dict: properties, fieldName: "overlayTopRightCoord")
        overlayBottomLeftCoordinate = Campus.parseCoord(dict: properties, fieldName: "overlayBottomLeftCoord")
        
        let cgPoints = boundaryPoints.map { CGPointFromString($0) }
        boundary = cgPoints.map { CLLocationCoordinate2DMake(CLLocationDegrees($0.x), CLLocationDegrees($0.y)) }
    }
    
    static func plist(_ plist: String) -> Any? {
        guard let filePath = Bundle.main.path(forResource: plist, ofType: "plist"),
            let data = FileManager.default.contents(atPath: filePath) else { return nil }
        
        do {
            return try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        } catch {
            return nil
        }
    }
    
    static func parseCoord(dict: [String: Any], fieldName: String) -> CLLocationCoordinate2D{
        if let coord = dict[fieldName] as? String {
            let point = CGPointFromString(coord)
            return CLLocationCoordinate2DMake(CLLocationDegrees(point.x), CLLocationDegrees(point.y))
        }
        return CLLocationCoordinate2D()
    }
}
