//
//  PinDictionary.swift
//  iMachiLive
//
//  Created by RIVER on 2018/12/22.
//  Copyright © 2018 Reverse. All rights reserved.
//

import Foundation

struct PinInfomations {
    
    var user_name:          String
    var location_tatitude:  String
    var location_longitude: String
    var music_title:        String
    var music_artwork:      String
    var music_pass:         String
    
    
    static func pinInformationFromNSDictionary(dictionary: NSDictionary?) -> PinInfomations {
        let user_nameVal            = dictionary?["user_name"]          as? String ?? "nothing"
        let location_tatitudeVal    = dictionary?["location_tatitude"]  as? String ?? "nothing"
        let location_longitudeVal   = dictionary?["location_longitude"] as? String ?? "nothing"
        let music_titleVal          = dictionary?["music_title"]        as? String ?? "nothing"
        let music_artworkVal        = dictionary?["music_artwork"]      as? String ?? "nothing"
        let music_passVal           = dictionary?["music_pass"]         as? String ?? "nothing"
        
        return PinInfomations(
            user_name:          user_nameVal,
            location_tatitude:  location_tatitudeVal,
            location_longitude: location_longitudeVal,
            music_title:        music_titleVal,
            music_artwork:      music_artworkVal,
            music_pass:         music_passVal
        )
    }
    
    func nsdictionaryForNSUserDefaults() -> NSDictionary {
        let dictionary: NSDictionary = [
            "user_name":            self.user_name,
            "location_tatitude":    self.location_tatitude,
            "location_longitude":   self.location_longitude,
            "music_title":          self.music_title,
            "music_artwork":        self.music_artwork,
            "music_pass":           self.music_pass
            ]
        return dictionary
    }
}


// usage
//class PinDictionary {
//
//    let userDefaults = UserDefaults.standard
//    var informations: PinInfomations
//
//    init() {
//        // SaveData = user_name + location_tatitude + location_longitude
//        let dictionary = self.userDefaults.value(forKey: "SaveData") as? NSDictionary
//        self.informations = PinInfomations.pinInformationFromNSDictionary(dictionary: dictionary)
//    }
//
//    func save() {
//        let informationDictionary = self.informations.nsdictionaryForNSUserDefaults()
//        self.userDefaults.setValue(informationDictionary, forKey: "SaveData")
//    }
//
//}
