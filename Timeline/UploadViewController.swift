//
//  UploadViewController.swift
//  Timeline
//
//  Created by pbw on 2017. 8. 12..
//  Copyright © 2017년 pbw. All rights reserved.
//

import UIKit
import FirebaseCore
import Firebase
import FirebaseDatabase
import FirebaseStorage


class UploadViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var TextView: UITextView!
    var image = UIImage()
    
    var ref: DatabaseReference?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TextView.delegate = self
        ref = Database.database().reference()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(uploadPost))
        self.navigationItem.rightBarButtonItem = addButton
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
        self.TextView.textColor = UIColor.lightGray
        self.TextView.text = "하고 싶은 말이 있나요?"
        
        self.ImageView.image = image
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(self.ImageView)
        self.navigationController?.isNavigationBarHidden = true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("begin")
        textView.textColor = UIColor.black
        textView.text = ""
    }
    
    @objc func uploadPost(){
        var curRef = self.ref?.child("posts").childByAutoId()
        if self.TextView.text != "하고 싶은 말이 있나요?"{
            curRef?.child("text").setValue(self.TextView.text)
        }else{
            curRef?.child("text").setValue("")
        }
        
        let date = Date()
        let IntValueOfDate = Int(date.timeIntervalSince1970)
        curRef?.child("date").setValue("\(IntValueOfDate)")
        
        var storageRef:StorageReference
        
        storageRef = Storage.storage().reference().child((curRef?.key)!+".jpg")
        guard var uploadData = UIImageJPEGRepresentation(self.image, 0.1) else{
            guard var uploadData = UIImagePNGRepresentation(self.image) else{
                return
            }
            return
        }
        storageRef.putData(uploadData, metadata: nil, completion:{ metadata, error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                if let downloadURL = metadata!.downloadURL(){
                    curRef?.child("imageURL").setValue("\(downloadURL)")
                }
            }
        })
        self.tabBarController?.selectedIndex = 0
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
