//
//  Building.swift
//  cs407
//
//  Created by Johanna Collins on 2/21/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import UIKit

class Building {
    
    //MARK: Properties
    
    //The name of the building and a photo, i.e. thumbnail image of exterior.
    var name : String
    var photo: UIImage?
    
    //MARK: Initialization
    init?(name: String, photo: UIImage?) {
        //Initialization should fail if there is no name.
        if name.isEmpty {
            return nil
        }
        
        //Initialize stored properties.
        self.name = name
        self.photo = photo
        
    }
}
