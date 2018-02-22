//
//  BuildingTableViewCell.swift
//  cs407
//
//  Created by Johanna Collins on 2/21/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import UIKit

class BuildingTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var buildingImageView: UIImageView!
    @IBOutlet weak var buildingNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
