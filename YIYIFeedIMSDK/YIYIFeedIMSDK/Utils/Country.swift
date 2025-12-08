//
//  Country.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2024/12/30.
//

import Foundation
import UIKit

struct Country: Equatable {
    
    var name: String?
    var phoneCode: String?
    var flagImage: UIImage?
    var isoCode: String?
    
    static var all: [Country] {
        let sortedCodes = IsoCountries.allCountries.map { $0.alpha2 }
        let countries = sortedCodes.compactMap { Country(isoCode: $0) }
        return countries
    }
    
    static var `default`: Country {
        return Country(isoCode: "MY")!
    }
    
    init?(isoCode: String) {
        guard let flagImage = UIImage(named: "ic_flag_\(isoCode.lowercased())") else {
            return nil
        }
        self.name = Locale.current.localizedString(forRegionCode: isoCode)
        self.phoneCode = IsoCountryCodes.find(key: isoCode).calling
        self.flagImage = flagImage
        self.isoCode = isoCode
    }
    
    init?(phoneCode: String) {
        let isoCode = IsoCountryCodes.searchByCallingCode(calllingCode: phoneCode).alpha2
        self.init(isoCode: isoCode)
    }
    

    static func ==(lhs: Country, rhs: Country) -> Bool {
        return lhs.isoCode?.lowercased() == rhs.isoCode?.lowercased()
    }
}
