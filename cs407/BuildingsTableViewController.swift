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

class BuildingsTableViewController: UITableViewController {

    //MARK: Properties
    var buildings = [Building]()
    var firebaseReference : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Define reference variable for firebase database.
        self.firebaseReference = Database.database().reference()
        
        
        self.loadBuildings()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buildings.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "BuildingTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BuildingTableViewCell else {
            fatalError("The dequeued cell is not an instance of BuildingTableViewCell.")
        }

        //Fetches the appropriate building for the data source layout.
        let building = buildings[indexPath.row]
        
        cell.buildingNameLabel.text = building.name
        cell.buildingImageView.image = building.photo

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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let destinationViewController = segue.destination as? AmenitiesViewController {
            if let cell = sender as? BuildingTableViewCell  {
                destinationViewController.name = cell.buildingNameLabel.text
            }
        }
    }
    
    private func loadBuildings() {
        self.firebaseReference?.child("Buildings").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let actualValue = value {
                for (buildingName, _) in actualValue {
                    //print(otherStuff)
                    guard let building = Building(name: buildingName as! String, photo: nil) else {
                        fatalError("Unable to instantiate building!")
                    }
                    self.buildings.append(building)
                }
                self.tableView.reloadData()
            }
        })

    }

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

}
