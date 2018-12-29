//
//  ViewController.swift
//  Toucan
//
//  Created by Vikram Mullick on 12/23/18.
//  Copyright © 2018 Vikram Mullick. All rights reserved.
//

import UIKit
import MediaPlayer
import StoreKit
import Alamofire
import SwiftyJSON
import Firebase
import FirebaseUI

class LoginViewController: UIViewController{

    let systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var loginStatusLabel: UILabel!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var logoView: UIView!
    
    @IBAction func signIn(_ sender: Any) {
        if let authUI = FUIAuth.defaultAuthUI()
        {
            authUI.delegate = self
            let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
            authUI.providers = providers
            let authViewController = authUI.authViewController()
            present(authViewController, animated:true, completion:nil)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser
        {
            self.signInButton.isHidden = true
            self.loginActivityIndicator.isHidden = false
            user.getIDTokenForcingRefresh(true, completion: { (token:String?, err:Error?) in
                guard err != nil else
                {
                    ToucanAPI.firebaseToken = token!
                    self.initializeKeys()
                    return
                }
                self.signInButton.isHidden = false
                self.loginActivityIndicator.isHidden = true
            })
        }
        else
        {
            self.signInButton.isHidden = false
            self.loginActivityIndicator.isHidden = true
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginActivityIndicator.isHidden = false
        self.signInButton.isHidden = true
        self.signInButton.layer.cornerRadius = 10
        self.signInButton.layer.borderWidth = 2
        self.signInButton.layer.backgroundColor = UIColor(red: CGFloat(70/255.0), green: CGFloat(102/255.0), blue: CGFloat(255/255.0), alpha: CGFloat(0.5)).cgColor
        self.signInButton.layer.borderColor = UIColor(red: CGFloat(70/255.0), green: CGFloat(102/255.0), blue: CGFloat(255/255.0), alpha: CGFloat(1.0)).cgColor
        self.loginStatusLabel.text = ""
        self.logoView.layer.cornerRadius = 100
        self.logoView.layer.borderWidth = 5
        self.logoView.layer.borderColor = UIColor.white.cgColor
        // Do any additional setup after loading the view, typically from a nib
    }
    
    func initializeKeys()
    {
        self.loginStatusLabel.text = "Accessing Apple Music"
        MusicAPI.setAppleDeveloperToken(completion: {
            self.loginStatusLabel.text = "Verifying Permissions"
            self.appleMusicCheckIfDeviceCanPlayback(completion: {
                self.loginStatusLabel.text = "Verifying Apple Music Account"
                MusicAPI.setMusicUserToken(completion: {
                    self.loginStatusLabel.text = "Logging in!"
                    MusicAPI.setStorefrontId(completion: {
                        self.performSegue(withIdentifier: "RootScreenSegue", sender: self)
                    })
                })
            })
        })
    }
    
    func executeTestFunctions()
    {
        self.getUserData(limit: "100", offset: "0")
        self.playSong(search: "mariah carey christmas")
    }
    
    func playSong(search: String){
        MusicAPI.getSong(search: search, completion: { (response : JSON) in
            if let trackId = response["results"]["songs"]["data"][0]["attributes"]["playParams"]["id"].string
            {
                self.systemMusicPlayer.setQueue(with: [trackId])
                self.systemMusicPlayer.play()
            }
        })
    }
    
    func getUserData(limit: String, offset: String){
        MusicAPI.getUserLibrary(limit: limit, offset: offset, completion: { (response : JSON) in
            if let data = response["data"].array
            {
                print(data.count)
            }
            if let next = response["next"].string
            {
                if let nextPagination = urlUtil.getURLQueryValueFor(key: "offset", url: next)
                {
                    self.getUserData(limit: limit, offset: nextPagination)
                }
            }
        })
    }

    func appleMusicCheckIfDeviceCanPlayback(completion: @escaping (() -> Void)) {
        let serviceController = SKCloudServiceController()
        serviceController.requestCapabilities { (capability:SKCloudServiceCapability, err:Error?) in
            if capability.contains(SKCloudServiceCapability.musicCatalogPlayback) {
                print("The user has an Apple Music subscription and can playback music!")
                self.appleMusicRequestPermission(completion: {
                    completion()
                })
            } else if  capability.contains(SKCloudServiceCapability.addToCloudMusicLibrary) {
                print("The user has an Apple Music subscription, can playback music AND can add to the Cloud Music Library")
                self.appleMusicRequestPermission(completion: {
                    completion()
                })
            } else {
                print("The user doesn't have an Apple Music subscription available. Now would be a good time to prompt them to buy one?")
            }
        }
    }
    
    func appleMusicRequestPermission(completion: @escaping (() -> Void)) {
        SKCloudServiceController.requestAuthorization { (status:SKCloudServiceAuthorizationStatus) in
            switch status {
                case .authorized:
                    print("All good - the user tapped 'OK', so you're clear to move forward and start playing.")
                    completion()
                case .denied:
                    print("The user tapped 'Don't allow'. Read on about that below...")
                case .notDetermined:
                    print("The user hasn't decided or it's not clear whether they've confirmed or denied.")
                case .restricted:
                    print("User may be restricted; for example, if the device is in Education mode, it limits external Apple Music usage. This is similar behaviour to Denied.")
                default: break
            }
        }
    }
}

extension LoginViewController: FUIAuthDelegate
{
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
    }
}
