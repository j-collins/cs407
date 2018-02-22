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
    var databaseHandle : DatabaseHandle?
    var buildingNames: [String] = ["ClassOf1950", "Lawson", "Lilly Hall of Life Sciences", "MSEE", "Neil Armstrong Hall of Engineering"] //List of all buildings in Database
    
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
        
        updateBuildingInfo()
        
        //show building pins on map
        loadBuildingPins()
        
        //dropBuildingPins()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is CampusMapOverlay {
            return CampusMapOverlayView(overlay: overlay, overlayImage: #imageLiteral(resourceName: "overlay_campus")) //#imageLiteral(resourceName: "overlay_campus"
        }
        return MKOverlayRenderer()
    }
    
    //when you click the Populate Buildings Button, updateBuildingInfo() is called
    @IBAction func UploadBuildingInfo(_ sender: Any) {
        print("in UploadBuildingInfo button function")
        updateBuildingInfo();
    }
    
    //the building info is updated to database
    func updateBuildingInfo() {
        print("in update building info")
       //Lawson
        ref?.child("Buildings").child("Lawson").child("Longitude").setValue(-86.917496)
        ref?.child("Buildings").child("Lawson").child("Latitude").setValue(40.427579)
        ref?.child("Buildings").child("Lawson").child("Information").setValue("Laswon is a computer Science Building")
        ref?.child("Buildings").child("Lawson").child("Address").setValue("L305 N University St, West Lafayette, IN 47907")
        //Class of 1950
        ref?.child("Buildings").child("ClassOf1950").child("Longitude").setValue(-86.915005)
        ref?.child("Buildings").child("ClassOf1950").child("Latitude").setValue(40.426481)
        ref?.child("Buildings").child("ClassOf1950").child("Information").setValue("Exams are held here")
        ref?.child("Buildings").child("ClassOf1950").child("Address").setValue("Stanley Coulter Hall, 640 Oval Dr, West Lafayette, IN 47907")
    }
    
    @IBAction func getInfoOnLawson(_ sender: Any) {
        //get info about lawson
        print("trying to get info on lawson")
        ref?.child("Buildings").child("Lawson").child("Information").observeSingleEvent(of: .value, with: { (snapshot) in
            //code to execute when a child is added under "posts"
            let post = snapshot.value as? String
            var postData = ""
            if let actualPost = post{
                postData = actualPost
            }
            print("!!!!!!!!!!")
            print(postData)
        })
    }
    
    func dropBuildingPins() { //used for testing dropping one pin
        let building = Buildings(title: "Lawson", locationName: "Building", discipline: "academic", coordinate: CLLocationCoordinate2D(latitude: 40.427579, longitude: -86.917496))
        map.addAnnotation(building)
    }
    
    func loadBuildingPins() {
        var lat = 0.0
        var long = 0.0
        
        for item in buildingNames {
            //get Latitude
            ref?.child("Buildings").child(item).child("Latitude").observeSingleEvent(of: .value, with: { (snapshot) in
                let post = snapshot.value as? Double
                if let actualPost = post{
                    lat = actualPost
                    //get longitude
                    self.ref?.child("Buildings").child(item).child("Longitude").observeSingleEvent(of: .value, with: { (snapshot) in
                        let post = snapshot.value as? Double
                        if let actualPost = post{
                            long = actualPost
                            print("Map Pin Coordinates for " + item + ": ")
                            print(lat)
                            print(long)
                            let building = Buildings(title: item, locationName: "", discipline: "academic", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long)) //creates the pin (Annotation)
                            self.map.addAnnotation(building) //adds the pin to the map
                            //get the building information
                            self.ref?.child("Buildings").child(item).child("Information").observeSingleEvent(of: .value, with: { (snapshot) in
                                //code to execute when a child is added under "posts"
                                let post = snapshot.value as? String
                                var postData = ""
                                if let actualPost = post{
                                    postData = actualPost
                                    print(postData) //print the information in the database for the building
                                }
                            })
                        }
                    })
                }
            })
        }
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
    
    //this function is called every time self.map.addAnnotation(building) is called
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Buildings else { return nil }
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView { // 3
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) //the "i" button on the marker popup
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //used if sequing to Johanna's Amenities view controller
        /*print("   info button was tapped")
        if control == view.rightCalloutAccessoryView {
            print("    in if statement")
            performSegue(withIdentifier: "toTheMoon", sender: view)
        }*/
        
        let buildingInfo = view.annotation as! Buildings
        let buildingName = buildingInfo.title

        ref?.child("Buildings").child(buildingName!).child("Information").observeSingleEvent(of: .value, with: { (snapshot) in
            let post = snapshot.value as? String
            var postData = ""
            if let actualPost = post{
                postData = actualPost
            }
        
            //creates a popup alart window with info
            let ac = UIAlertController(title: buildingName, message: postData, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        })
    }
    
    //used if seguing to johanna's amenities view controller
    /*func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("    preparing for segue")
        if (segue.identifier == "toTheMoon" )
        {
            //var amenities =segue.destination as! AmenitiesViewController
            //amenities.viewDidLoad() = (sender as! MKAnnotationView).annotation!.title
            print("   in segue if")
            if let destinationVC = segue.destination as? AmenitiesViewController {
                print("   trying to segue")
                destinationVC.name = title
            }
        }
        
    }*/
    
    /*func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Artwork
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] location.mapItem().openInMaps(launchOptions: launchOptions)
    }*/
    
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
