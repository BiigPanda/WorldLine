//
//  DetailViewModel.swift
//  WorldlineMonuments
//
//  Created by Marc Gallardo on 06/09/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import SwiftyJSON

class DetailViewModel {
    
    var refreshData = { () -> () in}
    
    var dataDetailMonument: DetailMonumentModel = DetailMonumentModel() {
        didSet{
            refreshData()
        }
    }
    
    var context: NSManagedObjectContext?
    
    func callDetailApi(idDetail: String, completionHandler: @escaping (_ result: DetailMonumentModel, _ error: Error?) -> Void)  {
        var monumentDetail : DetailMonumentModel = DetailMonumentModel()
        let endpoints = "http://t21services.herokuapp.com/points/\(idDetail)"
        
        AF.request(endpoints).responseJSON { (response) in
            switch response.result {
            case .success(_):
                guard let result = response.value as? [String:Any] else{
                    assertionFailure()
                    return
                }
                let json = JSON(result)
                monumentDetail = self.parsedDetailMonument(json: json)
                completionHandler(monumentDetail,nil)
                break
            case .failure(let error):
                completionHandler(monumentDetail,error)
                break
            }
        }
    }
    
    
    func parsedDetailMonument(json: JSON) -> DetailMonumentModel {
        let monumentDetail = DetailMonumentModel()
            monumentDetail.id = json["id"].stringValue
            monumentDetail.title = json["title"].stringValue
            monumentDetail.geocoordinates = json["geocoordinates"].stringValue
            monumentDetail.address = json["address"].stringValue
            monumentDetail.description = json["description"].stringValue
            monumentDetail.email = json["email"].stringValue
            monumentDetail.phone = json["phone"].stringValue
            monumentDetail.transport = json["transport"].stringValue
        return monumentDetail
    }
    
    func convertStringLocation(locations: String) -> [Double]  {
        var doubleNumbers: [Double] = []
        let fullNameArr = locations.components(separatedBy: ",")
        let latDouble: Double = Double(fullNameArr[0]) ?? 0.0
        let longDouble: Double = Double(fullNameArr[1]) ?? 0.0
        doubleNumbers.append(latDouble)
        doubleNumbers.append(longDouble)
        return doubleNumbers
    }
    
    
    
    
    
    
}
