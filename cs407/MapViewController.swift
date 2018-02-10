//
//  MapViewController.swift
//  cs407
//
//  Created by Ashley Nussel on 2/9/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    let regionRadiusDisplay: CLLocationDistance = 1000 //1000 meters (1/2 a mile)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set initial location for map: 610 Purdue Mall, West Lafayette, IN 47907
        let initialLoc = CLLocation(latitude: 40.428246, longitude: -86.914391)
        centerMapOnInitialLocation(location: initialLoc) //call the helper function to center the map
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // location refers to the center point
    func centerMapOnInitialLocation(location: CLLocation) {
        let coordRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadiusDisplay, regionRadiusDisplay)
        map.setRegion(coordRegion, animated: true) //tells the map to display this specified region, the true animates a zoom to this location
    }
    
}

