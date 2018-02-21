//
//  MapViewController.swift
//  cs407
//
//  Created by Ashley Nussel on 2/9/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseDatabase

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    var campus = Campus(filename: "Campus")
    let manager = CLLocationManager()
    var ref: DatabaseReference!
    
    @IBAction func logoutAction1(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUp")
            self.present(vc!, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    //let regionRadiusDisplay: CLLocationDistance = 1000 //1000 meters (1/2 a mile)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // define reference variable for database
        ref = Database.database().reference()
        
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
        
        //the stuff below is to make a user's location appear on the map
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        //manager.startUpdatingLocation()
        self.map.showsUserLocation = true;
        
        //this chunk is for overlays
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
    //when you click the Populate Buildings Button, the building info is updated to database
    @IBAction func UploadBuildingInfo(_ sender: Any) {
        print("in UploadBuildingInfo")
       //Lawson
        ref?.child("Buildings").child("Lawson").child("Longitude").setValue("40.427579,")
        ref?.child("Buildings").child("Lawson").child("Latitude").setValue("-86.917496")
        ref?.child("Buildings").child("Lawson").child("Information").setValue("Laswon is a computer Science Building")
        ref?.child("Buildings").child("Lawson").child("Address").setValue("L305 N University St, West Lafayette, IN 47907")
        //Class of 1950
        ref?.child("Buildings").child("ClassOf1950").child("Longitude").setValue("40.426481,")
        ref?.child("Buildings").child("ClassOf1950").child("Latitude").setValue("-86.915005")
        ref?.child("Buildings").child("ClassOf1950").child("Information").setValue("Exams are held here")
        ref?.child("Buildings").child("ClassOf1950").child("Address").setValue("Stanley Coulter Hall, 640 Oval Dr, West Lafayette, IN 47907")
        
        
    }
    @IBAction func getCurrentLocButton(_ sender: Any) {
        manager.startUpdatingLocation()
        self.map.showsUserLocation = true;
    }
    
    //this function is for updating the users location - it is called every time user changes position
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0] //we want the first element because it is the most recent element of the user
        //zoom in the map on that location - span is how much we are zoomed in
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        //set the location of the user
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        //set the region (combine 2 variables: how much the map is zoomed into the users location and the users location)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        map.setRegion(region, animated:true)
        
        //shows blue dot
        self.map.showsUserLocation = true;
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
