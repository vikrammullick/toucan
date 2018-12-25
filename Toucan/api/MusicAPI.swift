//
//  Music.swift
//  Toucan
//
//  Created by Vikram Mullick on 12/24/18.
//  Copyright © 2018 Vikram Mullick. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import MediaPlayer
import StoreKit

struct MusicAPI {
    static var appleDevToken = ""
    static var musicUserToken = ""
    static var storefrontId = ""
    
    // set apple developer token to access apple music apis
    // tokens are generated on firebase server
    // GET /appleDevToken
    static func setAppleDeveloperToken(completion: @escaping (() -> Void))
    {
        Alamofire.request("https://us-central1-toucan-40cc1.cloudfunctions.net/toucan/appleDevToken", method: .get, encoding: URLEncoding.default).responseJSON {responseData in
            let response = JSON(responseData.result.value!)
            if let appleDevToken = response["token"].string
            {
                MusicAPI.appleDevToken = appleDevToken
            }
            completion()
        }
    }
    
    // set music user token to access user specific music apis
    // tokens are generated through StoreKit
    static func setMusicUserToken(completion: @escaping (() -> Void))
    {
        let serviceController = SKCloudServiceController()
        serviceController.requestUserToken(forDeveloperToken: MusicAPI.appleDevToken)
        { (userToken: String?, err:Error?) in
            
            guard err == nil else {
                print("An error occured. Handle it here.")
                return
            }
            MusicAPI.musicUserToken = userToken!
            completion()
        }
    }
    
    // set storefront for user
    // apple music api
    // GET /me/storefront
    static func setStorefrontId(completion: @escaping (() -> Void))
    {
        let Auth_header : [String : String] = [ "Authorization" : "Bearer \(MusicAPI.appleDevToken)", "Music-User-Token": MusicAPI.musicUserToken]
        Alamofire.request("https://api.music.apple.com/v1/me/storefront", method: .get, encoding: URLEncoding.default, headers:Auth_header).responseJSON {responseData in
            let response = JSON(responseData.result.value!)
            if let storefrontId = response["data"][0]["id"].string
            {
                MusicAPI.storefrontId = storefrontId
            }
            completion()
        }

    }
    
    // search for song
    // apple music api
    // GET /catalog/{storefront}/search
    static func getSong(search: String, completion: @escaping ((JSON) -> Void))
    {
        let Auth_header = [ "Authorization" : "Bearer \(appleDevToken)" ]
        let parameters : Parameters = [ "term" : search, "types": "songs" ]
        Alamofire.request("https://api.music.apple.com/v1/catalog/\(storefrontId)/search", method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers:Auth_header).responseJSON {responseData in
            let response = JSON(responseData.result.value!)
            completion(response)
        }
    }
    
    // get user library
    // apple music api
    // GET /me/library/songs
    static func getUserLibrary(limit: String, offset: String, completion: @escaping ((JSON) -> Void))
    {
        let Auth_header = [ "Authorization" : "Bearer \(appleDevToken)", "Music-User-Token": MusicAPI.musicUserToken ]
        let parameters : Parameters = [ "limit": limit, "offset": offset]
        Alamofire.request("https://api.music.apple.com/v1/me/library/songs", method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers:Auth_header).responseJSON {responseData in
            let response = JSON(responseData.result.value!)
            completion(response)
        }
    }
}


