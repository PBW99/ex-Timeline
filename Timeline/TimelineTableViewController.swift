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
    
    var ref:DatabaseReference?          //Firebase Database 루트를 가리키는 레퍼런스
    
    var posts = [Post]()                //테이블 뷰에 표시될 포스트들을 담는 배열
    var loadedPosts = [Post]()          //Firebase에서 로드된 포스트들
    
    @IBOutlet weak var FooterLabel: UILabel!    //loading..메세지를 표시할 라벨
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        loadPosts()     //Firebase에서 포스트들을 불러들임
        
        refreshControl = UIRefreshControl()         //최신글을 불러 들이기 위한 refreshControl
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(TimelineTableViewController.refresh), for: UIControlEvents.valueChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    // MARK: -  Load posts
    func loadPosts(){
        var orderedQuery:DatabaseQuery?
        orderedQuery = ref?.child("posts").queryOrdered(byChild: "date")
        
        orderedQuery?.observeSingleEvent(of: .value, with: { (snapshot) in

            var snapshotData = snapshot.children.allObjects
            snapshotData = snapshotData.reversed()
            
            for anyDatum in snapshotData{
                let snapshotDatum = anyDatum as! DataSnapshot
                let dicDatum = snapshotDatum.value as! [String:String]
                if let text = dicDatum["text"],
                    let date = Int(dicDatum["date"]!),
                    let imageURL = dicDatum["imageURL"]{
                    let post = Post(text,date,imageURL)
                    
                    //Get Image from URL
                    let image_url = post.imageURL
                    if let url = URL(string: image_url){
                        let request = URLRequest(url:url)
                        
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
            }
            
            self.posts += self.loadedPosts.prefix(g_NumPerOneLoad)
            self.tableView.reloadData()
        })
    }
    
    func loadFreshPosts(){
        var filteredQuery:DatabaseQuery?
        if let latestDate = self.posts.first?.date{
            filteredQuery = ref?.child("posts").queryOrdered(byChild: "date").queryStarting(atValue: "\(latestDate + 1)")
        }else{
            filteredQuery = ref?.child("posts").queryOrdered(byChild: "date").queryStarting(atValue: "\(0)")
        }
        
        filteredQuery?.observeSingleEvent(of: .value, with: { (snapshot) in
            var snapshotData = snapshot.children.allObjects
            snapshotData = snapshotData.reversed()
            
            var freshPostsChunk = [Post]()
            
            for anyDatum in snapshotData{
                let snapshotDatum = anyDatum as! DataSnapshot
                let dicDatum = snapshotDatum.value as! [String:String]
                if let text = dicDatum["text"],
                    let date = Int(dicDatum["date"]!),
                    let imageURL = dicDatum["imageURL"]{
                    let post = Post(text,date,imageURL)
                    
                    //Get Image from URL
                    let image_url = post.imageURL
                    if let url = URL(string: image_url){
                        let request = URLRequest(url:url)
                        
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
                    if freshPostsChunk.count >= g_NumPerOneLoad{
                        break
                    }
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
    
    // MARK: - Reload Posts
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
            loadPastPosts()
        }
    }
}
