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

class ViewController: UIViewController{

    let systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer

    @IBAction func tap(_ sender: Any) {
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
        authUI?.providers = providers
        if let authViewController = authUI?.authViewController()
        {
            present(authViewController, animated:true, completion:nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        Auth.auth().addStateDidChangeListener { (auth, user) in
            user?.getIDToken(completion: { (token:String?, err:Error?) in
                guard err != nil else
                {
                    ToucanAPI.firebaseToken = token!
                    self.initializeKeys()
                    return
                }
            })
            user?.getIDTokenForcingRefresh(true, completion: { (token:String?, err:Error?) in
                guard err != nil else
                {
                    ToucanAPI.firebaseToken = token!
                    return
                }
            })
        }
    }
    
    func initializeKeys()
    {
        MusicAPI.setAppleDeveloperToken(completion: {
            self.appleMusicCheckIfDeviceCanPlayback(completion: {
                MusicAPI.setMusicUserToken(completion: {
                    MusicAPI.setStorefrontId(completion: {
                       self.executeTestFunctions()
                    })
                })
            })
        })
    }
    
    func executeTestFunctions()
    {
        self.getUserData(limit: "100", offset: "0")
        //self.playSong(search: "mariah carey christmas")
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

extension ViewController: FUIAuthDelegate
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
