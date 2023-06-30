//
//  FacilitiesDataParser.swift
//  RadiusAgent
//
//  Created by Lalitha Guru Jyothi Nandiraju on 29/06/23.
//

import Foundation

class FacilitiesDataParser {
    
    static let facilitiesURLString = "https://my-json-server.typicode.com/iranjith4/ad-assignment/db"
    
    static func parseFacilitiesData(completion: @escaping (FacilitiesAndExclusions) -> Void ) {
        guard let url = URL(string: facilitiesURLString) else {
            return
        }
        
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, urlError in
            if let jsonData = data, urlError == nil {
                do {
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                    let facilitiesAndExclusions = try jsonDecoder.decode(FacilitiesAndExclusions.self, from: jsonData)
                    completion(facilitiesAndExclusions)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}
