//
//  BuildingsTableViewController.swift
//  cs407
//
//  Created by Johanna Collins on 2/21/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseStorageUI //Friendlier API for Firebase Storage.

class BuildingsTableViewController: UITableViewController {

    //MARK: Properties
    
    //Array of building objects.
    var buildings = [Building?]()
    
    //Add database reference.
    var firebaseReference : DatabaseReference!
    
    //Add storage reference for Firebase file storage.
    //Citation: https://code.tutsplus.com/tutorials/get-started-with-firebase-storage-for-ios--cms-30203
    var storageReference : StorageReference!
    
    //Logout button functionality.
    @IBAction func LogOutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(vc!, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    //viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()

        //Initialize reference variable for Firebase database.
        self.firebaseReference = Database.database().reference()
        
        //Initialize reference variable for Firebase storage.
        self.storageReference = Storage.storage().reference()
        
        //The loadBuildings() function is responsible for loading the list of buildings and their thumbnail image on the Buildings page.
        self.loadBuildings()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    //didReceiveMemoryWarning()
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Table View Data Source

    //numberOfSections()
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    //tableView()
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //The count of all the buildings in the array.
        return buildings.count
    }

    //tableView()
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "BuildingTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BuildingTableViewCell else {
            fatalError("The dequeued cell is not an instance of BuildingTableViewCell.")
        }

        //Fetch the appropriate building for the data source layout.
        let building = buildings[indexPath.row]
        
        cell.buildingNameLabel.text = building?.name
        
        //Asynchronously download the image with caching.
        //Built into Firebase StorageUI, using sd_setImage.
        //Automatically updates imageView when download completes.
        //On page reloads, it detects if there is a cached image.
        cell.buildingImageView.sd_setImage(with: building?.url, placeholderImage: nil, completed: {(image, error, cache, url) in
                //print(url)
            })

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation.
    //prepare()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //This passes the building name to the new Amenities View so that it will display when you navigate.
        if let destinationViewController = segue.destination as? AmenitiesViewController {
            if let cell = sender as? BuildingTableViewCell  {
                destinationViewController.name = cell.buildingNameLabel.text
            }
        }
    }
    
    //loadBuildings()
    private func loadBuildings() {
        
        //Set storage reference to be "building_data" folder in storage.
        let buildingsRef = self.storageReference.child("building_data")
        
        //Get to Buildings node in database. Get snapshot of Buildings interpreted as Dictionary (key - building name, value - everything else).
        firebaseReference?.child("Buildings").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
           
            if let actualValue = value {
                //Fill the array (at top of class) with nil images, as many as the temp count from storage.
                //For each key, value pair (buildingName, and all associated buildingInfoData), sort alphabetically.
                for (buildingName, buildingInfoData) in actualValue.sorted(by: {String(describing: $0.0)  < String(describing: $1.0)}) {
                    
                    //String : Any -> In database Buildings table, the first value is a string that can be mapped to any other type.
                    //https://stackoverflow.com/questions/42709132/retrieve-firebase-dictionary-data-in-swift?rq=1
                    let buildingInfo = buildingInfoData as! [String : Any]
                    
                    //Set the pathway, called buildingImage, to the string stored in ImageThumb column in database.
                    if let buildingImage = buildingInfo["ImageThumb"] as? String {
                        
                        //Build on the buildingsRef (/building_data) and add buildingImage string to the path. Now, have a new reference to the image.
                        let buildingsChildRef = buildingsRef.child(buildingImage)
                        
                        //Create a Building object with the buildingName (interpreted as a string) and the photo temporarily set to nil.
                        //This is important to make the list of buildings alphabetical.
                        guard let building = Building(name: buildingName as! String, photo: nil) else {
                            fatalError("Unable to instantiate building!")
                        }
                        
                        self.buildings.append(building)
                       
                        //I think this is all happening in the background. Images are being paired with the buildingNameString in the array as the downloads
                        //complete.
                        
                        //TODO: Look for a cleaner way to do this?
                        
                        //Citation: Downloading Image
                        //https://code.tutsplus.com/tutorials/get-started-with-firebase-storage-for-ios--cms-30203
                        buildingsChildRef.downloadURL(completion: {url, error in
                            //Find the index of the current building and set the URL for the building.
                            if let i = self.buildings.index(where : { $0?.name == building.name }) {
                                
                                //Go to that index in the buildings URL array, and set data (the url).
                                //For Debugging: https://stackoverflow.com/questions/2780793/xcode-debugging-displaying-images
                                self.buildings[i]?.url = url
                                
                                //Reload.
                                self.tableView.reloadData()
                            }
                        })
          
                        
                    }
                    
                    
                }
               
            }
        })

    }

    /*
     
    //This was the hardcoded version.
    
     private func loadDummyBuildings() {
        guard let building1 = Building(name: "Lawson", photo: nil) else {
            fatalError("Unable to instantiate building1")
        }
        guard let building2 = Building(name: "Physics", photo: nil) else {
            fatalError("Unable to instantiate building2")
        }
        guard let building3 = Building(name: "MSEE", photo: nil) else {
            fatalError("Unable to instantiate building3")
        }
        
        buildings += [building1, building2, building3]
        
    }
     
    */
}
