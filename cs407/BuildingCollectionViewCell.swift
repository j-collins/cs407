//
//  BuildingCollectionViewCell.swift
//  cs407
//
//  Created by Johanna Collins on 3/27/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import UIKit

//https://medium.com/yay-its-erica/creating-a-collection-view-swift-3-77da2898bb7c
class BuildingCollectionViewCell: UICollectionViewCell {
    
    //Outlet for the UIImage in the cell. Controls what is displayed on the phone in the cell.
    @IBOutlet weak var buildingImage: UIImageView!
    
    //This function sets the current image in the cell to the one provided as an argument.
    func displayContent(image : UIImage ) {
        buildingImage.image = image
    }
}
