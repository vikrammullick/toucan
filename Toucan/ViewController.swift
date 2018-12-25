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

class ViewController: UIViewController {

    let systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        
        MusicAPI.setAppleDeveloperToken(completion: {
            self.appleMusicCheckIfDeviceCanPlayback(completion: {
                MusicAPI.setMusicUserToken(completion: {
                    MusicAPI.setStorefrontId(completion: {
                        self.getUserData(limit: "100", offset: "0")
                    })
                })
            })
        })
    }
    
    func playSong(){
        MusicAPI.getSong(search: "christmas", completion: { (response : JSON) in
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

