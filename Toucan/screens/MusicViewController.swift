//
//  MusicViewController.swift
//  Toucan
//
//  Created by Vikram Mullick on 12/28/18.
//  Copyright © 2018 Vikram Mullick. All rights reserved.
//

import UIKit
import MediaPlayer
import StoreKit
import Alamofire
import SwiftyJSON
import Firebase
import FirebaseUI

class MusicViewController: UIViewController{
    
    @IBOutlet weak var MusicButton: SwapColorButton!
    @IBOutlet weak var PlaylistButton: SwapColorButton!
    @IBOutlet weak var AlbumButton: SwapColorButton!
    @IBOutlet weak var ArtistButton: SwapColorButton!
    
    @IBOutlet weak var scrollView: ButtonEnabledScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize
            = CGSize(width: view.frame.width, height: 2000)
        
        // Do any additional setup after loading the view, typically from a nib
    }
    @IBAction func signOut(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "LoginScreenSegue", sender: self)
        }
        catch{}
    }
}
