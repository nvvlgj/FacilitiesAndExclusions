//
//  DataModel.swift
//  RadiusAgent
//
//  Created by Lalitha Guru Jyothi Nandiraju on 29/06/23.
//

import Foundation

struct FacilitiesAndExclusions: Codable {
    var facilities: [Facility]
    var exclusions: [[Exclusion]]
}

struct Facility: Codable {
    var facilityId: String
    var name: String
    var options: [FacilitiesOption]
    
    struct FacilitiesOption: Codable {
        var id: String
        var name: String
        var icon: String
    }
}

struct Exclusion: Codable {
    var facilityId: String
    var optionsId: String
}
