//
//  MapViewController.swift
//  cs407
//
//  Created by Ashley Nussel on 2/9/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    var campus = Campus(filename: "Campus")
    
    //let regionRadiusDisplay: CLLocationDistance = 1000 //1000 meters (1/2 a mile)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NEEDED FOR THE MAP GETTING STARTED TUTORIAL
        //Set initial location for map: 610 Purdue Mall, West Lafayette, IN 47907
        //let initialLoc = CLLocation(latitude: 40.428246, longitude: -86.914391)
        //centerMapOnInitialLocation(location: initialLoc) //call the helper function to center the map
    
        let latDelta = campus.overlayTopLeftCoordinate.latitude - campus.overlayBottomRightCoordinate.latitude
        
        // Think of a span as a tv size, measure from one corner to another
        let span = MKCoordinateSpanMake(fabs(latDelta), 0.0)
        let region = MKCoordinateRegionMake(campus.midCoordinate, span)
        
        map.region = region
        map.delegate = self;
        
        let overlay = CampusMapOverlay(campus: campus)
        map.add(overlay)
        //mapView(overlay, rendererFor: campus: campus)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("in first")
        if overlay is CampusMapOverlay {
            return CampusMapOverlayView(overlay: overlay, overlayImage: #imageLiteral(resourceName: "overlay_campus")) //#imageLiteral(resourceName: "overlay_campus"
        }
        
        return MKOverlayRenderer()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //NEEDED FOR THE MAP GETTING STARTED TUTORIAL
    // location refers to the center point
    /*func centerMapOnInitialLocation(location: CLLocation) {
        let coordRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadiusDisplay, regionRadiusDisplay)
        map.setRegion(coordRegion, animated: true) //tells the map to display this specified region, the true animates a zoom to this location
    }*/
    
}

//extension MapViewController: MKMapViewDelegate {
    /*private func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("in second")
        if overlay is CampusMapOverlay {
            //return CampusMapOverlayView(overlay: overlay, overlayImage: )
        }
        
        return MKOverlayRenderer()
    }*/
//}
