//
//  TimelineTableViewController.swift
//  Timeline
//
//  Created by pbw on 2017. 7. 27..
//  Copyright © 2017년 pbw. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class TimelineTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineCell", for: indexPath) as! TimelineTableViewCell
        cell.TextLabel.text = "hello"

        // Configure the cell...

        return cell
    }
    
    /*
    
    @IBAction func AddButtonPressed(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: "메모하세요", preferredStyle: .alert)
        actionSheet.view.tintColor = UIColor.darkGray
        
        let addAction = UIAlertAction(title: "", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        let image = UIImage(named: "add_2x.png")
        addAction.setValue(image, forKey: "image")
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            let firstTextField = actionSheet.textFields![0] as UITextField
            
            print("firstName \(firstTextField.text)")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in
            
        })

        
        actionSheet.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "하고 싶은 말이 있나요"
        }
    
        actionSheet.addAction(addAction)
        actionSheet.addAction(saveAction)
        actionSheet.addAction(cancelAction)

        self.present(actionSheet, animated: true, completion: nil)
    }
*/
    

}
