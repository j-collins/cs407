//
//  FloorplanViewController.swift
//  cs407
//
//  Created by Johanna Collins on 3/28/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

//Note to other group members reading my code: This code is adapted from the AmenitiesViewController. Because it was so similiar, I didn't bother to comment it as thoroughly. If you want really thorough comments and citations, go to the AmenitiesViewController file.

class FloorplanViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //MARK: Properties
    @IBOutlet weak var buildingNameLabel: UILabel!
    @IBOutlet weak var floorplanCollectionView: UICollectionView!
    @IBOutlet weak var floorplanPageControl: UIPageControl!
  
    @IBAction func LogoutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(vc!, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    //Database reference.
    var firebaseReference : DatabaseReference!
    var storageReference : StorageReference!
    
    var name : String? = "Default"
    
    //Array of floorplan images for the collection view.
    var floorplanImages = [UIImage?]()
    
    //FIX button added these.
    
    //Image count.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //https://stackoverflow.com/questions/47745936/how-to-connect-uipagecontrol-to-uicollectionview-swift?rq=1
        self.floorplanPageControl.numberOfPages = floorplanImages.count
        return floorplanImages.count
    }
    
    //Update image in cell.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //https://medium.com/yay-its-erica/creating-a-collection-view-swift-3-77da2898bb7c
        
        //Following code reused from Sprint 1 in BuildingsTableViewController. Original Apple Developer "Getting Started with iOS" Tutorial.
        //Try to get the current cell as a BuildingCollectionViewCell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BuildingCollectionViewCell", for: indexPath) as? BuildingCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of BuildingCollectionViewCell.")
        }
        
        //Find the image in the floorplanImages array and set the cell to display that image.
        //If this assignment takes place, the floorplanImages[indexPath.row] was not nil.
        if let image = floorplanImages[indexPath.row] {
            cell.displayContent(image: image)
        }
        
        //Return cell to display.
        return cell
    }
    
    //Whenever there was a scroll, find the current page control dot to highlight.
    //https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619417-scrollviewdidenddecelerating?language=objc
    //https://stackoverflow.com/questions/39549398/my-scrollviewdidscroll-function-is-not-receiving-calls
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //https://stackoverflow.com/questions/40975302/how-to-add-pagecontrol-inside-uicollectionview-image-scrolling/40982168
        let x_offset = scrollView.contentOffset.x
        let average_width = scrollView.contentSize.width/CGFloat(floorplanImages.count)
        
        //print(x_offset)
        //print(average_width)
        //print(x_offset/average_width)
        
        self.floorplanPageControl.currentPage = Int(round(x_offset/average_width))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Initialize reference variable for Firebase database.
        self.firebaseReference = Database.database().reference()
        
        //Initialize reference variable for Firebase storage.
        self.storageReference = Storage.storage().reference()
        
        //Get reference to building_data directory.
        let buildingsRef = self.storageReference.child("building_data")
        
        //If only one image, don't show the page control.
        self.floorplanPageControl.hidesForSinglePage = true
        
        //Set the name of the building.
        buildingNameLabel.text = name
        
        //Get snapshot. Dictionary (key, value) is (building name, information associated with building).
        //Set the Amenities page text as the "Information" value, interpreted as a String, from database.
        self.firebaseReference?.child("Buildings").child(name!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let actualValue = value {
                
                //Citation: Downloading Image
                //https://code.tutsplus.com/tutorials/get-started-with-firebase-storage-for-ios--cms-30203
                
                //Download the images from Firebase.
                if let floorplanImageArray = actualValue["Floorplans"] as? NSArray {
                    
                    //Preallocate buildingImages with space for the total number of images.
                    //https://stackoverflow.com/questions/41812385/swift-3-expression-type-uiimage-is-ambiguous-without-more-context?rq=1
                    self.floorplanImages = [UIImage?](repeating: nil, count: floorplanImageArray.count)
                    
                    //For each array index and imageName at that index...
                    //https://stackoverflow.com/questions/24028421/swift-for-loop-for-index-element-in-array
                    for (index, imageName) in floorplanImageArray.enumerated() {
                        
                        //Set up path to image.
                        let floorplanChildRef = buildingsRef.child(imageName as! String)
                        
                        //Get the image, up to 5MB.
                        floorplanChildRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                            if let error = error {
                                print("Error \(error)")
                            } else {
                                //Update the image at this index in the array.
                                if let image = UIImage(data: data!) {
                                    self.floorplanImages[index] = image
                                }
                                
                                //Collection view needs to reload.
                                self.floorplanCollectionView.reloadData()
                                
                            }
                        }
                    }
                }
            }
        })
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
        return CGSize(width: itemWidth, height: self.floorplanCollectionView.frame.height)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //If going back to the Amenities page, must set and pass name.
        if let destinationViewController = segue.destination as? AmenitiesViewController {
            destinationViewController.name = self.name
        }
    }
}
