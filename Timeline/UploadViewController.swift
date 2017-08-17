//
//  UploadViewController.swift
//  Timeline
//
//  Created by pbw on 2017. 8. 12..
//  Copyright © 2017년 pbw. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class UploadViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var TextView: UITextView!
    
    var image = UIImage()
    let placeHolder = "하고 싶은 말이 있나요?"
    
    var ref: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        self.TextView.delegate = self
        textViewDidEndEditing(TextView)
        var tapDismiss = UITapGestureRecognizer(target:self,action:"dismissKeyboard")
        self.view.addGestureRecognizer(tapDismiss)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(uploadPost))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - TextView PlaceHolder
    func dismissKeyboard(){
        TextView.resignFirstResponder()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text == ""){
            textView.text = placeHolder
            textView.textColor = UIColor.lightGray
        }
        textView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textView.text == placeHolder){
            textView.text = ""
            textView.textColor = UIColor.black
        }
        textView.becomeFirstResponder()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.TextView.isEditable = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.TextView.isEditable = false
    }
    
    //MARK: - ImageView
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.ImageView.image = image
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true

    }
    @objc func uploadPost(){
        var curRef = self.ref?.child("posts").childByAutoId()
        if self.TextView.text != placeHolder{
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
                // 에러 발생
            } else {
                // Metadata는 size, content-type, download URL과 같은 컨텐트의 메타데이터를 가진다
                if let downloadURL = metadata!.downloadURL(){
                    curRef?.child("imageURL").setValue("\(downloadURL)")
                }
            }
        })
        self.tabBarController?.selectedIndex = 0
    }
    
}
