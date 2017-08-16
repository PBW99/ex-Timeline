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
    
    @IBOutlet weak var FooterLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        loadPosts()
        
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: Selector("refresh"), for: UIControlEvents.valueChanged)
        
        //        self.FooterLabel.isHidden = true
        
        
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
        
        orderdQuery = ref?.child("posts").queryOrdered(byChild: "date")
        
        orderdQuery?.observeSingleEvent(of: .value, with: { (snapshot) in
            //Take the value from the snapshot and added it to the jokbosData array
            var snapshotData = snapshot.children.allObjects
            snapshotData = snapshotData.reversed()
            
            for anyDatum in snapshotData{
                let snapshotDatum = anyDatum as! DataSnapshot
                let dicDatum = snapshotDatum.value as! [String:String]
                var post = Post(dicDatum["text"]!, Int(dicDatum["date"]!)!, dicDatum["imageURL"]!)
                
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
            
        })
    }
    
    func loadFreshPosts(){
        let filteredQuery = ref?.child("posts").queryOrdered(byChild: "date").queryStarting(atValue: "\((self.posts.first?.date)! + 1)")
        
        filteredQuery?.observeSingleEvent(of: .value, with: { (snapshot) in
            //Take the value from the snapshot and added it to the jokbosData array
            var snapshotData = snapshot.children.allObjects
            snapshotData = snapshotData.reversed()
            
            var freshPostsChunk = [Post]()
            
            for anyDatum in snapshotData{
                let snapshotDatum = anyDatum as! DataSnapshot
                let dicDatum = snapshotDatum.value as! [String:String]
                if let text = dicDatum["text"],
                    let date = Int(dicDatum["date"]!),
                    let imageURL = dicDatum["imageURL"]{
                    var post = Post(text,date,imageURL)
                    
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
                    freshPostsChunk += [post]
                }
            }
            
            self.loadedPosts.insert(contentsOf: freshPostsChunk, at: 0)
            self.posts.insert(contentsOf: freshPostsChunk, at: 0)
            self.tableView.reloadData()
            
        })
        
    }
    func loadPastPosts(){
        let pastPosts = self.loadedPosts.filter{$0.date < (self.posts.last?.date)!}
        let pastChunkPosts = pastPosts.prefix(g_NumPerOneLoad)
        if pastChunkPosts.count > 0{
            self.posts += pastChunkPosts
            sleep(1)
            self.tableView.reloadData()
        }
        self.FooterLabel.isHidden = true
        
    }
    
    func refresh(){
        print("refresh")
        self.loadFreshPosts()
        self.refreshControl?.endRefreshing()
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            print(" you reached end of the table")
            self.FooterLabel.isHidden = false
            //            scrollView.contentOffset.y = scrollView.contentOffset.y + self.FooterLabel.frame.height
            loadPastPosts()
        }
    }
}
