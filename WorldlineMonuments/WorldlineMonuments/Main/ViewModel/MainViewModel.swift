//
//  MainViewModel.swift
//  WorldlineMonuments
//
//  Created by Marc Gallardo on 06/09/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import SwiftyJSON


class MainViewModel {
    
    var refreshData = { () -> () in}
    
    var dataArray: [MonumentModel] = [] {
        didSet{
            refreshData()
        }
    }
    
    var filterArray: [MonumentModel] = [] {
        didSet{
            refreshData()
        }
    }

    
    var context: NSManagedObjectContext?
    
    // MARK: Service Methods
    
    func callStartApi(completionHandler: @escaping (_ result: [MonumentModel], _ error: Error?) -> Void)  {
        var monumentsArray : [MonumentModel] = []
        let endpoints = "http://t21services.herokuapp.com/points"
        
        AF.request(endpoints).responseJSON { (response) in
            switch response.result {
            case .success(_):
                guard let result = response.value as? [String:Any] else{
                    assertionFailure()
                    return
                }
                let json = JSON(result)
                monumentsArray = self.parsedMonument(json: json)
                completionHandler(monumentsArray,nil)
                break
            case .failure(let error):
                completionHandler(monumentsArray,error)
                break
            }
            
        }
    }
    
    
    func parsedMonument(json: JSON) -> [MonumentModel] {
        var monumentMain = MonumentModel()
        var monumentsMainArray : [MonumentModel] = []
        
        for (_,subJson):(String, JSON) in json["list"] {
            monumentMain.id = subJson["id"].stringValue
            monumentMain.title = subJson["title"].stringValue
            monumentMain.geocoordinates = subJson["geocoordinates"].stringValue
            saveCoreData(objectMonument: monumentMain)
            monumentsMainArray.append(monumentMain)
            monumentMain = MonumentModel()
        }
        return monumentsMainArray
    }
    
    // MARK: Core Data Methods
    
    func saveCoreData(objectMonument: MonumentModel) {
        guard let heroeEntity = NSEntityDescription.entity(forEntityName: "MainMonument", in: self.context!) else {
            return
        }
        let heroeTask = NSManagedObject(entity: heroeEntity, insertInto: self.context!)
        heroeTask.setValue(objectMonument.id, forKey: "id")
        heroeTask.setValue(objectMonument.title, forKey: "title")
        heroeTask.setValue(objectMonument.geocoordinates, forKey: "geocoordinates")
        do {
            try self.context!.save()
        } catch let error as NSError {
            print("Error al guardar", error.localizedDescription)
        }
    }
    
    func loadMonuments() -> [MonumentModel] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        var arrayMonuments : [MonumentModel] = []
        var emptyMonument: MonumentModel = MonumentModel()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MainMonument")
        
        do {
            let records = try managedContext.fetch(fetchRequest)
            
            if let records = records as? [NSManagedObject]{
                for record in records {
                    emptyMonument.id = record.value(forKey: "id") as? String ?? ""
                    emptyMonument.title = record.value(forKey: "title") as? String ?? ""
                    emptyMonument.geocoordinates = record.value(forKey: "geocoordinates") as? String ?? ""
                    arrayMonuments.append(emptyMonument)
                    emptyMonument = MonumentModel()
                }
                
                return arrayMonuments
            }
        } catch let error as NSError {
            print("No ha sido posible cargar \(error), \(error.userInfo)")
            return []
        }
        return []
        
    }
    
    // MARK: Search bar Methods
    
    func searchMonumentByName (nameMonument: String) {
        guard !nameMonument.isEmpty else {
            return
        }
        filterArray = dataArray.filter({ (monument) -> Bool in
            return (monument.title?.contains(nameMonument))!
        })
    }
    
    
}
