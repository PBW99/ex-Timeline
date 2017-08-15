//
//  AddImageViewController.swift
//  Timeline
//
//  Created by pbw on 2017. 8. 12..
//  Copyright © 2017년 pbw. All rights reserved.
//

import UIKit
import Fusuma

class AddNavigationController: UINavigationController, FusumaDelegate {
    let fusuma = FusumaViewController()
    var uploadController = UploadViewController()
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fusumaTintColor = UIColor.black
        fusumaBaseTintColor = UIColor.black
        fusumaBackgroundColor = UIColor.white
        
        fusuma.delegate = self
        fusuma.hasVideo = false // If you want to let the users allow to use video.
        fusuma.cropHeightRatio = 0.6 // Height-to-width ratio. The default value is 1, which means a squared-size photo.
        fusuma.allowMultipleSelection = false // You can select multiple photos from the camera roll. The default value is false.
        fusuma.defaultMode = .library // The first choice to show (.camera, .library, .video). The default value is .camera.
        fusuma.hidesBottomBarWhenPushed = true
        
        uploadController = storyBoard.instantiateViewController(withIdentifier: "UploadViewController") as! UploadViewController
        uploadController.navigationItem.title = "업로드"
        fusuma.hidesBottomBarWhenPushed = true
        self.pushViewController(fusuma, animated: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.isNavigationBarHidden = true
        self.popToViewController(fusuma, animated: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Return the image which is selected from camera roll or is taken via the camera.
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        uploadController.image = image
        self.pushViewController(uploadController, animated: true)
    }
    
    func fusumaWillClosed() {
        self.tabBarController?.selectedIndex = 0
    }
    
    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(image: UIImage, source: FusumaMode) {
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
    }
    
    // Return selected images when you allow to select multiple photos.
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
    }
    
    // Return an image and the detailed information.
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode, metaData: ImageMetadata) {
    }
    
}
