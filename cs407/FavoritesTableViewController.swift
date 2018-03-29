//
//  FavoritesTableViewController.swift
//  cs407
//
//  Created by Kazi Rahma on 3/28/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController {
    
    //MARK: Properties
    var favoriteBuildings = [Building]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //load the sample data
        
        loadSampleBuildings()
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
        // #warning Incomplete implementation, return the number of rows
        return favoriteBuildings.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "FavoritesTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as? FavoritesTableViewCell else{
            
            fatalError("The dequeued cell is not an instance of FavoritesTableViewCell")
        }
        
        let favoriteBuilding = favoriteBuildings[indexPath.row]
        
        cell.favoritesNameLabel.text = favoriteBuilding.name
        cell.favoritesImageView.image = favoriteBuilding.photo

        // Configure the cell...

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MArK: Private Methods
    
    private func loadSampleBuildings(){
        
        guard let building1 = Building(name: "Lawson", photo: nil) else {
            fatalError("Unable to instantiate building1")
        }
        
        guard let building2 = Building(name: "Physics", photo: nil) else {
            fatalError("Unable to instantiate building2")
        }
        
        guard let building3 = Building(name: "MSEE", photo: nil) else {
            fatalError("Unable to instantiate building3")
        }
        
        favoriteBuildings += [building1, building2, building3]
    }
}
