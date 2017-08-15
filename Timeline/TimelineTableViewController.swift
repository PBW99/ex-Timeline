///
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
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    var orderdQuery:DatabaseQuery?
    
    var posts = [Post]()
    var loadedPosts = [Post]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        loadPosts()
        
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: Selector("refresh"), for: UIControlEvents.valueChanged)
        
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
        return self.posts.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineCell", for: indexPath) as! TimelineTableViewCell
        let post = posts[indexPath.row]
        cell.TextLabel.text = post.text
        if let image = post.image {
            cell.ImageView.image = image
        }
        
        return cell
    }
    
    func loadPosts(){
        //TODO: detach data search to just function
        
        orderdQuery = ref?.child("posts").queryOrdered(byChild: "date")
        
        orderdQuery?.observeSingleEvent(of: .value, with: { (snapshot) in
            //Take the value from the snapshot and added it to the jokbosData array
            var snapshotData = snapshot.children.allObjects
            snapshotData = snapshotData.reversed()
            
            for anyDatum in snapshotData{
                let snapshotDatum = anyDatum as! DataSnapshot
                let dicDatum = snapshotDatum.value as! [String:String]
                var post = Post()
                post.text = dicDatum["text"]!
                post.date = Int(dicDatum["date"]!)!
                post.imageURL = dicDatum["imageURL"]!
                
                //Get Image from URL
                let image_url = post.imageURL
                if var url = URL(string: image_url){
                    var request = URLRequest(url:url)
                    
                    URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                        DispatchQueue.main.async {
                            post.image = UIImage(data: data!)
                            self.tableView.reloadData()
                        }
                        if(error != nil){
                            print(error)
                        }
                    }).resume()
                }
                self.loadedPosts += [post]
            }
            
            self.posts += self.loadedPosts.prefix(g_NumPerOneLoad)
            self.tableView.reloadData()
            
            /*
             if let data = snapshot.value as? [String:AnyObject]{
             var dataValues = [AnyObject](data.values)
             dataValues.reverse()
             print(dataValues[0..<3])
             var threePosts = [Post]()
             for datum in dataValues{
             let dicDatum = datum as! [String:String]
             var post = Post()
             post.text = dicDatum["text"]!
             post.date = Int(dicDatum["date"]!)!
             post.imageURL = dicDatum["imageURL"]!
             threePosts += [post]
             }
             threePosts.sort(by: {$0.date > $1.date})
             self.posts.append(contentsOf: threePosts)
             self.tableView.reloadData()
             
             }
             */
            
        })
        
        /*
         if var limitedQuery = orderdQuery?.queryLimited(toLast: 3){
         limitedQuery.observeSingleEvent(of: .value, with: { (snapshot) in
         //Take the value from the snapshot and added it to the jokbosData array
         if let data = snapshot.value as? [String:AnyObject]{
         var dataValues = [AnyObject](data.values)
         var threePosts = [Post]()
         for datum in dataValues{
         let dicDatum = datum as! [String:String]
         var post = Post()
         post.text = dicDatum["text"]!
         post.date = Int(dicDatum["date"]!)!
         post.imageURL = dicDatum["imageURL"]!
         threePosts += [post]
         }
         threePosts.sort(by: {$0.date > $1.date})
         self.posts.append(contentsOf: threePosts)
         self.tableView.reloadData()
         
         }
         
         })
         }
         
         */
        
    }
    
    func loadPastPosts(){
        let pastPosts = self.loadedPosts.filter{$0.date < (self.posts.last?.date)!}
        let pastChunkPosts = pastPosts.prefix(g_NumPerOneLoad)
        self.posts += pastChunkPosts
        self.tableView.reloadData()
    }
    
    func refresh(){
        print("refresh")
        self.refreshControl?.endRefreshing()
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            print(" you reached end of the table")
            loadPastPosts()
        }
    }
    
}
