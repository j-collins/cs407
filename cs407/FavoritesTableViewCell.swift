//
//  FavoritesTableViewCell.swift
//  cs407
//
//  Created by Kazi Rahma on 3/28/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {

    //MARK: Properties
    
    @IBOutlet weak var favoritesNameLabel: UILabel!
    @IBOutlet weak var favoritesImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
