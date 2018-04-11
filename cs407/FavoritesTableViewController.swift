//
//  FavoritesTableViewController.swift
//  cs407
//
//  Created by Kazi Rahma on 3/28/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class FavoritesTableViewController: UITableViewController {
    
    //MARK: Properties
    
    //Array of Favorite buildings.
    var favoriteBuildings = [Building]()
    
    //Add database reference.
    var firebaseReference : DatabaseReference!
    
    //Add storage reference for Firebase file storage.
    //Citation: https://code.tutsplus.com/tutorials/get-started-with-firebase-storage-for-ios--cms-30203
    var storageReference : StorageReference!
  
    //Logout button functionality.
    @IBAction func LogoutAction(_ sender: Any) {
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
       
        //allows editting for delete functionality
        tableView.allowsMultipleSelectionDuringEditing = true

    }
    //delete functionality to edit the row at this index
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //code which deletes from the table and the firebase
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //print(indexPath.row)
        //get the current user
        let user = Auth.auth().currentUser
        
        //get the current building at this index
        let currentBuilding = self.favoriteBuildings[indexPath.row]
        
        firebaseReference?.child("Favorites").child((user?.uid)!).child(currentBuilding.name).removeValue(completionBlock: { (error, ref) in
            
            if error != nil {
                print("Failed to delete building: ", error!)
                return
            }
            
            self.favoriteBuildings.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        })
    }

    //didReceiveMemoryWarning()
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table View Data Source

    //numberOfSections()
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    //tableView()
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Return number of Favorite buildings in array.
        return favoriteBuildings.count
    }

    //tableView()
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "FavoritesTableViewCell"
        
        //BUG: No quotes around the cellIdentifier variable.
        //A cell needs to be displayed. This is the way to get the cell - get as FavoritesTableViewCell.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FavoritesTableViewCell else{
            fatalError("The dequeued cell is not an instance of FavoritesTableViewCell")
        }
        
        //Fetch the appropriate building for the data source layout.
        let favoriteBuilding = favoriteBuildings[indexPath.row]
        
        //Set name and image.
        cell.favoritesNameLabel.text = favoriteBuilding.name
        cell.favoritesImageView.image = favoriteBuilding.photo

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation.
    //prepare()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //This passes the building name to the new Amenities View (of the favorite building you select) so that it will display when you navigate.
        if let destinationViewController = segue.destination as? AmenitiesViewController {
            if let cell = sender as? FavoritesTableViewCell  {
                destinationViewController.name = cell.favoritesNameLabel.text
            }
        }
    }
    
    
    //Mark: Private Methods
    
    //loadBuildings()
    private func loadBuildings() {
        
        //Set storage reference to be "building_data" folder in storage. This is to go get the thumbnail image to display on Favorites page.
        let buildingsRef = self.storageReference.child("building_data")
    
        //Get the user.
        let user = Auth.auth().currentUser
        
        firebaseReference?.child("Favorites").child((user?.uid)!).observeSingleEvent(of: .value, with: { (userFavoritesSnapshot) in
            //Try to get the current list of user Favorites as a dictionary.
            if let userFavorites = userFavoritesSnapshot.value as? NSDictionary {
                //The _ is because we don't use the second buildingName in the database. Ignore this.
                for (buildingName, _) in userFavorites.sorted(by: {String(describing: $0.0)  < String(describing: $1.0)}) {
                    
                    //Get the building info from the database to grab the thumbnail path.
                    //Go get this building in the Buildings node in order to obtain the thumbnail image.
                    self.firebaseReference?.child("Buildings").child(buildingName as! String).observeSingleEvent(of: .value, with: { (building_snapshot) in
                        let buildingInfo = building_snapshot.value as? NSDictionary
                    
                        //Get the pathway to the thumbnail image.
                        if let buildingImage = buildingInfo!["ImageThumb"] as? String {
                            
                            //Build on the buildingsRef (/building_data) and add buildingImage string to the path. Now, have a new reference to the image.
                            let buildingsChildRef = buildingsRef.child(buildingImage)
                            
                            //I think this is all happening in the background. Images are being paired with the buildingNameString in the array as the downloads
                            //complete.
                            
                            //TODO: Look for a cleaner way to do this?
                            
                            //Citation: Downloading Image
                            //https://code.tutsplus.com/tutorials/get-started-with-firebase-storage-for-ios--cms-30203
                            
                            //Download the image (up to 5 MB).
                            buildingsChildRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                                if let error = error {
                                    print("Error \(error)")
                                } else {
                                    //Image was downloaded.
                                    
                                    //Interpret the buildingName as a string.
                                    let buildingNameString = buildingName as! String
                                    
                                    //Citation: Getting Index
                                    //https://stackoverflow.com/questions/28727845/find-an-object-in-array
                                    //Get the index of the building (buildingNameString).
                                    if let i = self.favoriteBuildings.index(where : { $0.name == buildingNameString }) {
                                        
                                        //Go to that index in the favoriteBuildin array, and set data (the image) as a UIImage.
                                        //For Debugging: https://stackoverflow.com/questions/2780793/xcode-debugging-displaying-images
                                        self.favoriteBuildings[i].photo = UIImage(data: data!)
                                        
                                        //Reload.
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                        
                        //Create a Building object with the buildingName (interpreted as a string) and the photo temporarily set to nil.
                        guard let building = Building(name: buildingName as! String, photo: nil) else {
                            fatalError("Unable to instantiate building!")
                        }
                        
                        //Append the building to the list.
                        self.favoriteBuildings.append(building)
                        
                        //Reload.
                        self.tableView.reloadData()
                    })
                }
            }
            else {
                return
            }
        })
        
    }
    
    
}
