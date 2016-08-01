//
//  UserModelViewController.swift
//  GitHubAPIDemo
//
//  Created by Nignesh on 2016-07-31.
//  Copyright © 2016 patel.nignesh2108@gmail.com. All rights reserved.
//

import UIKit
import AlamofireImage

class UserModelViewController: UIViewController {
    
    var userDict : Dictionary<String, AnyObject>!

    @IBOutlet var imgViewUser: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
            print("\(self.userDict)")
        #endif
        
        if userDict != nil && userDict!["login"] != nil {
        
            self.title = "\(userDict!["login"]!)"
        }else{
            self.title = "Anonymous"
        }
        
        // User Image
        if userDict != nil && userDict!["avatar_url"] != nil {
            
            self.imgViewUser.af_setImageWithURL(
                NSURL(string: userDict!["avatar_url"] as! String)!,
                placeholderImage: UIImage(named: "user_blank"),
                filter: CircleFilter(),
                imageTransition: .CrossDissolve(0.2),
                completion: { response in })
            
        }else{
            
            self.imgViewUser.image = UIImage(named: "user_blank")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}