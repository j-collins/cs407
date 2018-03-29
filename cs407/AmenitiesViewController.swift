//
//  AmenitiesViewController.swift
//  cs407
//
//  Created by Johanna Collins on 2/21/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

//Extension to bold Amenities Page sections.
//https://stackoverflow.com/questions/28496093/making-text-bold-using-attributed-string-in-swift
extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.boldSystemFont(ofSize: 18)]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: 16.0)]
        let normal = NSAttributedString(string: text, attributes: attrs)
        append(normal)
        
        return self
    }
}

//TODO: FlowLayout from Git Repo that resizes photo to span entire width of screen.
class AmenitiesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    //MARK: Properties
    
    //Database and Storage references.
    var firebaseReference : DatabaseReference!
    var storageReference : StorageReference!
    
    @IBOutlet weak var buildingNameLabel: UILabel!
    @IBOutlet weak var amenitiesLabel: UILabel!
    @IBOutlet weak var amenitiesTextView: UITextView!
    @IBOutlet weak var amenitiesCollectionView: UICollectionView!
    
    //Paging Help:
    //https://stackoverflow.com/questions/47745936/how-to-connect-uipagecontrol-to-uicollectionview-swift?rq=1
    //https://stackoverflow.com/questions/40975302/how-to-add-pagecontrol-inside-uicollectionview-image-scrolling/40982168
    @IBOutlet weak var amenitiesPageControl: UIPageControl!
    
    var name : String? = "Default"
    
    //Array of building images for the collection view.
    //FIX. Question mark is used because may be nil or image - I think.
    var buildingImages = [UIImage?]()
    
    //FIX button added the following two functions.
    
    //collectionView() - returns image count.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //https://stackoverflow.com/questions/47745936/how-to-connect-uipagecontrol-to-uicollectionview-swift?rq=1
        
        self.amenitiesPageControl.numberOfPages = buildingImages.count
        return buildingImages.count
    }
    
    //collectionView() - updates image in cell.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //https://medium.com/yay-its-erica/creating-a-collection-view-swift-3-77da2898bb7c
        
        //Following code reused from Sprint 1 in BuildingsTableViewController. Original Apple Developer "Getting Started with iOS" Tutorial.
        //Try to get the current cell as a BuildingCollectionViewCell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BuildingCollectionViewCell", for: indexPath) as? BuildingCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of BuildingCollectionViewCell.")
        }
        
        //Finds the image in the buildingImages array and sets the cell to display that image.
        //If this assignment takes place, the buildingImages[indexPath.row] was not nil.
        //If image is nil, don't try to show it or it will fail.
        if let image = buildingImages[indexPath.row] {
            cell.displayContent(image: image)
        }
        
        //Return cell to display.
        return cell
    }
    
    //Whenever there was a scroll, find the current page view dot to highlight.
    //https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619417-scrollviewdidenddecelerating?language=objc
    //https://stackoverflow.com/questions/39549398/my-scrollviewdidscroll-function-is-not-receiving-calls
    //https://stackoverflow.com/questions/40975302/how-to-add-pagecontrol-inside-uicollectionview-image-scrolling/40982168
    
    //The scrollViewDidScroll() function is determing which PageControl dot to highlight when scrolling through the list of building images.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
        let x_offset = scrollView.contentOffset.x
        let average_width = scrollView.contentSize.width/CGFloat(buildingImages.count)
        
        //print(x_offset)
        //print(average_width)
        //print(x_offset/average_width)
        
        self.amenitiesPageControl.currentPage = Int(round(x_offset/average_width))
    }
    
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
    
    //Citation: Scroll View on Amenities Page
    //https://spin.atomicobject.com/2014/03/05/uiscrollview-autolayout-ios/
    
    //viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize reference variable for Firebase database.
        self.firebaseReference = Database.database().reference()

        //Initialize reference variable for Firebase storage.
        self.storageReference = Storage.storage().reference()
        
        //Get reference to building_data directory.
        let buildingsRef = self.storageReference.child("building_data")
        
        //If only one image, don't show the page control.
        self.amenitiesPageControl.hidesForSinglePage = true
        
        //Set the name of the building.
        buildingNameLabel.text = name
        
        //Get snapshot. Dictionary (key, value) is (building name, information associated with building).
        //Go to Buildings in database, go to building name.
        self.firebaseReference?.child("Buildings").child(name!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            if let actualValue = value {
                
                //self.amenitiesTextView.text = actualValue["Information"] as! String
                //Get the information under the Amenities node and interpret as a dictionary with key, value pairs.
                if let amenitiesInfo = actualValue["Amenities"] as? NSDictionary {
                    
                    //Display the amenities with formatting (extensions at top of file).
                    let amenitiesString = NSMutableAttributedString()
                    for (amenityKey, amenityString) in amenitiesInfo {
                        amenitiesString.bold(amenityKey as! String)
                        amenitiesString.normal("\n")
                        amenitiesString.normal(amenityString as! String)
                        amenitiesString.normal("\n\n")
                    }
                    self.amenitiesTextView.attributedText = amenitiesString
                    
                }
                
                //Citation: Downloading Image
                //https://code.tutsplus.com/tutorials/get-started-with-firebase-storage-for-ios--cms-30203
                
                //Download the images from Firebase.
                //This array is index:string, index:string, with the string being the address to the image.
                if let buildingImageArrayTemp = actualValue["Images"] as? NSArray {
                    
                    //Preallocate buildingImages with space for the total number of images going to be downloaded.
                    //https://stackoverflow.com/questions/41812385/swift-3-expression-type-uiimage-is-ambiguous-without-more-context?rq=1
                    
                    //Fill the array (at top of class) with nil images, as many as the temp count from storage.
                    self.buildingImages = [UIImage?](repeating: nil, count: buildingImageArrayTemp.count)
                    
                    //For each array index and imageName at that index...
                    //https://stackoverflow.com/questions/24028421/swift-for-loop-for-index-element-in-array
                    for (index, imageName) in buildingImageArrayTemp.enumerated() {
                        
                        //Setting up pathway to image.
                        let buildingsChildRef = buildingsRef.child(imageName as! String)
                        
                        //Get the image, up to 5MB.
                        buildingsChildRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                            if let error = error {
                                print("Error \(error)")
                            } else {
                                
                                //Download was successful.
                                //Update the image at this index in the array.
                                if let image = UIImage(data: data!) {
                                    
                                    //Add image to the buildingsImages array.
                                    self.buildingImages[index] = image
                                    
                                }
                                
                                //Collection view needs to reload.
                                self.amenitiesCollectionView.reloadData()
                                
                                //buildingImageArrayTemp are the string names of images. buildingImages is an array of the downloaded images.
                                
                            }
                        }
                    }
                }
            }
        })
    }

    //This is for you, Kazi. Currently just prints to screen. This is where logic will go for Favorites Button.
    @IBAction func FavoritesButtonPress(_ sender: Any) {
        //print("Favorites button pressed.")
        
        //https://stackoverflow.com/questions/15911165/create-an-empty-child-record-in-firebase/15912083
        //https://stackoverflow.com/questions/37405149/how-do-i-check-if-a-firebase-database-value-exists
        firebaseReference?.child("Favorites").observeSingleEvent(of: .value, with: { (snapshot) in
            
            //Get the user.
            let user = Auth.auth().currentUser
            
            //See if the user exists in the Favorites list.
            if snapshot.hasChild((user?.uid)!) {
                print("User exists!")
                //Do nothing, the user already exists in the database.
            }
            else {
                //User does not exist, so add them to the Favorites list using updateChildValues.
                //https://www.raywenderlich.com/139322/firebase-tutorial-getting-started-2
                self.firebaseReference?.child("Favorites").updateChildValues([user?.uid as! String: user?.email as! String])
                //print("Added user.")
            }
            
            //Now add the building to the Favorites list for the given user.
            self.firebaseReference?.child("Favorites").child((user?.uid)!).observeSingleEvent(of: .value, with: {(userFavoritesSnapshot) in
                //Try to get the current list of user Favorites as a dictionary.
                if let userFavorites = userFavoritesSnapshot.value as? NSDictionary {
                    //print("User has favorites.")
                    //print(userFavorites)
                    
                    //Add the current building to the list of favorites using updateChildValues.
                    self.firebaseReference?.child("Favorites").child((user?.uid)!).updateChildValues([self.name as! String : self.name as! String])
                    
                    //print("Added building to favorites")
                    
                }
                else {
                    
                    //User does not have any favorites. Make the list and add the current building.
                    self.firebaseReference?.child("Favorites").child((user?.uid)!).setValue([self.name as! String : self.name as! String])
                    
                    //print("User did not have favorites, added building to favorites")
                }
            })
        })
        
    }
    
    //didReceiveMemoryWarning()
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //The following code dontrols the spacing and width of the images in the collection view on the Amenities page.
    //This code was found online and used to make the image span the full width of the phone.
    //Citation: https://stackoverflow.com/questions/43165636/uicollectionviewdelegateflowlayout-edge-insets-not-getting-recognized-by-sizefor
    
    //Start Code.
    
    fileprivate let cellsPerRow: CGFloat = 1.0
    fileprivate let margin: CGFloat = 10.0
    fileprivate let topMargin: CGFloat = 2.0
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = customize(collectionViewLayout, margin: margin)
        let itemWidth = cellWidth(collectionView, layout: flowLayout, cellsPerRow: cellsPerRow)
        return CGSize(width: itemWidth, height: 200)
    }
    
    /*
     Customizes the layout of a collectionView with space to the left and right of each cell that is
     specified with the parameter margin
     */
    private func customize(_ collectionViewLayout: UICollectionViewLayout, margin: CGFloat) -> UICollectionViewFlowLayout {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        // Interitem spacing affects the horrizontal spacing between cells
        flowLayout.minimumInteritemSpacing = margin
        // Line spacing affects the vertical space between cells
        flowLayout.minimumLineSpacing = margin
        // Section insets affect the entire container for the collectionView cells
        flowLayout.sectionInset = UIEdgeInsets(top: topMargin, left: margin, bottom: 0, right: margin)
        return flowLayout
    }
    
    /*
     Calculates the proper size of an individual cell with the specified number of cells in a row desired,
     along with the layout of the collectionView
     */
    private func cellWidth(_ collectionView: UICollectionView, layout flowLayout: UICollectionViewFlowLayout, cellsPerRow: CGFloat) -> CGFloat {
        // Calculate the ammount of "horizontal space" that will be needed in a row
        let marginsAndInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing * (cellsPerRow - 1)
        let itemWidth = (collectionView.bounds.size.width - marginsAndInsets) / cellsPerRow
        return itemWidth
    }
    
    //End Code.

    // MARK: Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //Pass the name of the building to the Floorplan page. 
        if let destinationViewController = segue.destination as? FloorplanViewController {
            destinationViewController.name = self.name
        }
    }
 

}
