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
import FirebaseStorage

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var clearRouteButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    var campus = Campus(filename: "Campus")
    let manager = CLLocationManager()
    var ref: DatabaseReference!
    var storageReference : StorageReference!
    var image : UIImage!
    var databaseHandle : DatabaseHandle?
    var buildings: [String] = []
    var buildingNames: [String] = [] //List of all buildings in Database
    //var response: MKDirectionsResponse = nil
    var polyline: MKPolyline = MKPolyline()
    var isrouting = false;
    var mostCurrentUserLatitude = 0.0;
    var mostCurrentUserLongitude = 0.0;
    var destinationLatitude = 0.0;
    var destinationLongitude = 0.0;
    var destinationBuilding = "";
    
    @IBAction func logoutAction1(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(vc!, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    //let regionRadiusDisplay: CLLocationDistance = 1000 //1000 meters (1/2 a mile)
    
    func getMapData() {
        if (self.image == nil) {
            let mapRef = self.storageReference.child("map_overlay") //get ref to map_overlay directory
            let mapChildRef = mapRef.child("Map.png")
            mapChildRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error \(error)")
                } else {
                    //download was successful.
                    self.image = UIImage(data: data!)
                    if self.image != nil {
                        print("GOT THE IMAGE!!")
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBuildingNames()
        
        // define reference variable for database
        ref = Database.database().reference()
        
        //Trying to use firebase storge for map image...
        self.storageReference = Storage.storage().reference() //initialize reference var for Firebase storage
        let mapRef = self.storageReference.child("map_overlay") //get ref to map_overlay directory
        let mapChildRef = mapRef.child("Map.png")
        //DispatchQueue.main.async{
        //mapChildRef.keepSynced(true)
        mapChildRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error \(error)")
            } else {
                //download was successful.
                self.image = UIImage(data: data!)
                if self.image != nil {
                    print("GOT THE IMAGE!!")
                }
            }
        //}
        //}
        //done with storage for now
        
        //NEEDED FOR THE MAP GETTING STARTED TUTORIAL
        //Set initial location for map: 610 Purdue Mall, West Lafayette, IN 47907
        //let initialLoc = CLLocation(latitude: 40.428246, longitude: -86.914391)
        //centerMapOnInitialLocation(location: initialLoc) //call the helper function to center the map
        
            let latDelta = self.campus.overlayTopLeftCoordinate.latitude - self.campus.overlayBottomRightCoordinate.latitude
        
        // Think of a span as a tv size, measure from one corner to another
        let span = MKCoordinateSpanMake(fabs(latDelta), 0.0)
            let region = MKCoordinateRegionMake(self.campus.midCoordinate, span)
        
            self.map.region = region
            self.map.delegate = self;
        
        //the stuff below is to make a user's location appear on the map
            self.manager.delegate = self
            self.manager.desiredAccuracy = kCLLocationAccuracyBest
            self.manager.requestWhenInUseAuthorization()
        //manager.startUpdatingLocation()
        self.map.showsUserLocation = true;
        
        //this chunk is for overlays
            let overlay = CampusMapOverlay(campus: self.campus)
        
            self.map.add(overlay)
        //mapView(overlay, rendererFor: campus: campus)
        
        //show building pins on map
            self.loadBuildingNames()

        }
        //dropBuildingPins()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is CampusMapOverlay {
            //var check : Int
            //check = 0;
            //Trying to use firebase storge for map image...
            /*let mapRef = self.storageReference.child("map_overlay") //get ref to map_overlay directory
            let mapChildRef = mapRef.child("Map.png")
            mapChildRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error \(error)")
                } else {
                    //download was successful.
                    self.image = UIImage(data: data!)
                    if self.image != nil {
                        print("GOT THE IMAGE!!")
              //          check = 1;
                        return CampusMapOverlayView(overlay: overlay, overlayImage: self.image)
                    }
                }
            }*/
            //if (check == 1) {
              //  print("DISPLAYING MAP!")
                //return CampusMapOverlayView(overlay: overlay, overlayImage: image)
            //}
            //done with storage for now
            
            if (self.image != nil) {
                return CampusMapOverlayView(overlay: overlay, overlayImage: self.image)
            } else {
                print("Error getting map overlay image")
            }
            //return CampusMapOverlayView(overlay: overlay, overlayImage: #imageLiteral(resourceName: "overlay_campus")) //#imageLiteral(resourceName: "overlay_campus"
        } else if (self.isrouting){
            print("going into here")
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 4.0
            return renderer
        }else{}
        return MKOverlayRenderer()
    }
    
    func dropBuildingPins() { //used for testing dropping one pin
        let building = Buildings(title: "Lawson", locationName: "Building", discipline: "academic", coordinate: CLLocationCoordinate2D(latitude: 40.427579, longitude: -86.917496))
        map.addAnnotation(building)
    }
    
    func loadBuildingPins() {
        var lat = 0.0
        var long = 0.0
        
        //loadBuildingNames()
        
        for item in buildings { //buildingNames
            let test = self.ref.child("Buildings").child(String(describing: item))
            test.observe(.value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if let actualValue = value {
                    lat = actualValue["Latitude"] as! Double
                    long = actualValue["Longitude"] as! Double
                    //print("values: ", lat, long)
                    let building = Buildings(title: item, locationName: "", discipline: "academic", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long)) //creates the pin (Annotation)
                    self.map.addAnnotation(building) //adds the pin to the map
                    
                }
            })
        }
    }
    
    func removeBuildingPins() {
        let allAnnotations = self.map.annotations
        self.map.removeAnnotations(allAnnotations)
    }
    
    private func loadBuildingNames() {
        ref?.child("Buildings").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let actualValue = value {
                for (buildingName, _) in actualValue.sorted(by: {String(describing: $0.0)  < String(describing: $1.0)}) {
                    //guard let building = Building(name: buildingName as! String, photo: nil) else {
                    //    fatalError("Unable to instantiate building!")
                    //}
                    //print(buildingName)
                    self.buildings.append(String(describing: buildingName))
                }
                self.loadBuildingPins()
            }
        })
    }
    
    @IBAction func getCurrentLocButton(_ sender: Any) {
        manager.startUpdatingLocation()
        self.map.showsUserLocation = true;
    }
    
    //this function is for updating the users location - it is called every time user changes position
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //if it goes into the if the user is in the middle of routing, else they are just pressing the current location button
        if(isrouting == true){
            self.map.remove(self.polyline)
            self.routing(lat: self.destinationLatitude, long: self.destinationLongitude, name: self.destinationBuilding);
            
            //Todo - if user is close to destination, stop routing and call the stop updating location function
            
        }
        else{
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
        
        //this is so that the location button still works after clicking it once.
        manager.stopUpdatingLocation()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        print(" * * DID RECIEVE MEMORY WARNING: MapViewController.swift")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //this function is called every time self.map.addAnnotation(building) is called
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //print(" * * addind annotation")
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
        print("   info button was tapped")
        /*if control == view.rightCalloutAccessoryView {
         print("    in if statement")
         performSegue(withIdentifier: "toTheMoon", sender: view)
         }*/
        
        let buildingInfo = view.annotation as! Buildings
        let buildingName = buildingInfo.title
        
        
        let test = self.ref.child("Buildings").child(buildingName!)
        test.observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let actualValue = value {
                var postData: String!
                if let amenities = actualValue["Amenities"] as? NSDictionary {
                    postData = amenities["General Information"] as! String
                }
                //var postData = actualValue["Information"] as! String
                
                let lat = actualValue["Latitude"] as! Double
                let long = actualValue["Longitude"] as! Double
                
                //creates a popup alart window with info
                let ac = UIAlertController(title: buildingName, message: postData, preferredStyle: .alert)
                //Create ok button
                let okButtonAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("ok button pressed")
                }
                ac.addAction(okButtonAction)

                
                //Create route button
                let routeButtonAction = UIAlertAction(title: "Route", style: .default) { (action:UIAlertAction!) in
                    print("route button pressed")
                    self.routing(lat: lat, long: long, name: buildingName!) //call method to create route
                }
                ac.addAction(routeButtonAction)
                
                //create get more info button
                //you set the global variable so you can use it to segue to the full amenities page in the prepare function
                self.destinationBuilding = buildingName!;

                let getMoreInfoAction = UIAlertAction(title: "More Info", style: .default, handler: {action in self.performSegue(withIdentifier: "moreBuildingInfo", sender: self)})
                ac.addAction(getMoreInfoAction)
                
                
                
                //present the pop-up
                self.present(ac, animated: true)
            }
        })
    }
    //this function is called for the first time when a user tries clicks on a building and says route.
    //this function is called continously after the user presses "Go"
    func routing(lat: Double, long: Double, name: String) {
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse) {
            //this is the first time showing the user the route
            if(self.isrouting == false){
                //set the global variables to where the user wants to go
                self.destinationLatitude = lat;
                self.destinationLongitude = long;
                self.destinationBuilding = name;
                //set global variable to true - there is a route
                self.isrouting = true;
                
                removeBuildingPins()
                
                //get current location
                let sourceLoc: CLLocationCoordinate2D = (manager.location?.coordinate)!
                
                //get destination location
                let destLoc = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                //Create pins to mark the start and end of the route
                let sourcePin = MKPlacemark(coordinate: sourceLoc, addressDictionary: nil)
                let destPin = MKPlacemark(coordinate: destLoc, addressDictionary: nil)
                
                //MKMapItems are used for routing, giving them information about the pins
                let sourceMapItem = MKMapItem(placemark: sourcePin)
                let destMapItem = MKMapItem(placemark: destPin)
                
                //annotations to give the names of the start and end location pins
                let sourceAnnotation = MKPointAnnotation()
                sourceAnnotation.title = "Current Location"
                
                if let location = sourcePin.location {
                    sourceAnnotation.coordinate = location.coordinate
                }
                
                let destAnnotation = MKPointAnnotation()
                destAnnotation.title = name
                
                if let location = destPin.location {
                    destAnnotation.coordinate = location.coordinate
                }
                
                self.map.showAnnotations([sourceAnnotation,destAnnotation], animated: true ) //display on map
                
                //MKDirectionsRequest class is used to compute the route
                let directionRequest = MKDirectionsRequest()
                directionRequest.source = sourceMapItem
                directionRequest.destination = destMapItem
                directionRequest.requestsAlternateRoutes = true
                directionRequest.transportType = .walking
                
                // Calculate the direction
                let directions = MKDirections(request: directionRequest)
                
                directions.calculate {
                    (response, error) -> Void in
                    guard let response = response else {
                        if let error = error {
                            print("Error: \(error)")
                        }
                        return
                    }
                    
                    let route = response.routes[0]
                    self.polyline = route.polyline
                    self.map.add((self.polyline), level: MKOverlayLevel.aboveRoads) //drawn with polyline on top of map
                    let rect = self.polyline.boundingMapRect
                    //self.map.setRegion(MKCoordinateRegionForMapRect(rect), animated: true) //this should be a little bigger...
                    self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsetsMake(80, 80, 80, 80), animated: true)
                    
                    self.getSteps(route: route)
                }
                
                //display the button to clear routes
                self.clearRouteButton.isHidden = false;
                //display the button to "go" in destination
                self.goButton.isHidden = false;
                
                //TODO - if the users reaches the destination, stop routing
                
            }
            // the user is already in the middle of routing, we just need to update their route.
            else if(self.isrouting == true){
                print("updating route....")
                //removeBuildingPins()
                
                //get current location
                let sourceLoc: CLLocationCoordinate2D = (manager.location?.coordinate)!
                
                //get destination location
                let destLoc = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                //Create pins to mark the start and end of the route
                let sourcePin = MKPlacemark(coordinate: sourceLoc, addressDictionary: nil)
                let destPin = MKPlacemark(coordinate: destLoc, addressDictionary: nil)
                
                //MKMapItems are used for routing, giving them information about the pins
                let sourceMapItem = MKMapItem(placemark: sourcePin)
                let destMapItem = MKMapItem(placemark: destPin)
                
                
                //MKDirectionsRequest class is used to compute the route
                let directionRequest = MKDirectionsRequest()
                directionRequest.source = sourceMapItem
                directionRequest.destination = destMapItem
                directionRequest.requestsAlternateRoutes = true
                directionRequest.transportType = .walking
                
                // Calculate the direction
                let directions = MKDirections(request: directionRequest)
                
                directions.calculate {
                    (response, error) -> Void in
                    guard let response = response else {
                        if let error = error {
                            print("Error: \(error)")
                        }
                        return
                    }
                    
                    let route = response.routes[0]
                    self.polyline = route.polyline
                    self.map.add((self.polyline), level: MKOverlayLevel.aboveRoads) //drawn with polyline on top of map
                }
                
            }
            
            
        } else {
            //user is not sharing their location so give them a message that to use this feature they must share their loction
            print("user tried to route but is not sharing their location")
            let alertVC = UIAlertController(title: "Error", message: "Sorry. You have not given BoilerFind permission to use your location, so we can not route you from your location. To use this feature, go to settings and show your location.", preferredStyle: .alert)
            
            let alertActionOkay = UIAlertAction(title: "Okay", style: .default, handler: nil)
            
            alertVC.addAction(alertActionOkay)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func getSteps(route: MKRoute) {
        var directionsString: String;
        directionsString = "";
        var i: Int;
        i = 0;
        for _ in route.steps {
            directionsString = directionsString + route.steps[i].instructions
            directionsString = directionsString + "\n"
            i = i + 1
        }
        directionsString = directionsString + "\nDistance: " + String(route.distance) + " m"
        directionsString = directionsString + "\nExpected Travel Time: " + String(format:"%.2f", (route.expectedTravelTime / 60 )) + " min."
        
        let alertVC = UIAlertController(title: "Route Info: ", message: directionsString, preferredStyle: .alert)
        
        let alertActionOkay = UIAlertAction(title: "Okay", style: .default, handler: nil)
        
        alertVC.addAction(alertActionOkay)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func onGoButtonClick(_ sender: Any) {
        //remove Go button
        self.goButton.isHidden = true;
        //change the words of "Clear Route" to be "Cancel Route"
        self.clearRouteButton.setTitle( "Cancel Route" , for: .normal );
        
        //while the user is not at the destination or has not pressed cancel, update keep recalcuating the route in the didupdatelocations function
        manager.startUpdatingLocation()
        print("finished loop")
        

        
    }
    //when this button is clicked it could be from the user canceling the route or clearing the route, either way it does the same thing.
    @IBAction func removeRoutePolylines(_ sender: Any) {
        print("pressed remove route button")
        manager.stopUpdatingLocation()
        self.map.remove(self.polyline)
        removeBuildingPins()
        loadBuildingPins()
        self.isrouting = false;
        
        //rehide the clear route button
        self.clearRouteButton.isHidden = true;
        //rehide the go button
        self.goButton.isHidden = true;
        //make sure that the next time clear route button is displayed the text will be clear route
        self.clearRouteButton.setTitle("Clear", for:.normal);
        //viewDidLoad()

    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation.
    //prepare()
    //this is called when the "get more info" button in the popup is clicked.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        //This passes the building name to the new Amenities View so that it will display when you navigate.
        if let destinationViewController = segue.destination as? AmenitiesViewController {
                destinationViewController.name = self.destinationBuilding
        }
    }
    
}
