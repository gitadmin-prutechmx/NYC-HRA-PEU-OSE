//
//  ManageCoreData.swift
//  Knock
//
//  Created by Kamal on 12/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation
import CoreData

class ManageCoreData{
    
    
    static func fetchData(salesforceEntityName:String,predicateFormat:String?=nil,predicateValue:String?=nil,predicateValue2:String?=nil,predicateValue3:String?=nil,predicateValue4:String?=nil,predicateValue5:String?=nil,predicateValue6:String?=nil,isPredicate:Bool) -> [Any]{
        
        var results = [Any]()
        
        //"companyName = PEU"
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: salesforceEntityName)
        
        if(isPredicate)
        {
            if(predicateValue2 == nil){
                // fetchRequest.predicate = NSPredicate(format: predicateFormat)
                fetchRequest.predicate = NSPredicate(format: predicateFormat!, predicateValue!)
                
            }
            else if(predicateValue3 == nil){
                fetchRequest.predicate = NSPredicate(format: predicateFormat!, predicateValue!,predicateValue2!)
            }
            else if(predicateValue4 == nil){
                fetchRequest.predicate = NSPredicate(format: predicateFormat!, predicateValue!,predicateValue2!,predicateValue3!)
            }
            else if(predicateValue5 == nil){
                fetchRequest.predicate = NSPredicate(format: predicateFormat!, predicateValue!,predicateValue2!,predicateValue3!,predicateValue4!)
            }
            else if(predicateValue6 == nil){
                fetchRequest.predicate = NSPredicate(format: predicateFormat!, predicateValue!,predicateValue2!,predicateValue3!,predicateValue4!,predicateValue5!)
            }
            else if(predicateValue6 != nil){
                fetchRequest.predicate = NSPredicate(format: predicateFormat!, predicateValue!,predicateValue2!,predicateValue3!,predicateValue4!,predicateValue5!,predicateValue6!)
            }
            
        }
        
        
        
        do {
            results = try context.fetch(fetchRequest)
            return results
            
        } catch {
            
            let nserror = error as NSError
            Utility.showSwiftErrorMessage(error: "ManageCoreData:- Fetch Data issue:- \(nserror.userInfo)")
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            
        }
        
        
    }
    
   
    
    
    
    static func updateRecord(salesforceEntityName:String,updateKeyValue:[String:AnyObject],predicateFormat:String?=nil,predicateValue:String?=nil,predicateValue2:String?=nil,predicateValue3:String?=nil,predicateValue4:String?=nil,predicateValue5:String?=nil,predicateValue6:String?=nil,isPredicate:Bool){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: salesforceEntityName)
        
        if(isPredicate)
        {
            if(predicateValue2 == nil){
                fetchRequest.predicate = NSPredicate(format: predicateFormat!, predicateValue!)
                
            }
            else if(predicateValue3 == nil){
                fetchRequest.predicate = NSPredicate(format: predicateFormat!, predicateValue!,predicateValue2!)
            }
            else if(predicateValue4 == nil){
                fetchRequest.predicate = NSPredicate(format: predicateFormat!, predicateValue!,predicateValue2!,predicateValue3!)
            }
            else if(predicateValue5 == nil){
                fetchRequest.predicate = NSPredicate(format: predicateFormat!, predicateValue!,predicateValue2!,predicateValue3!,predicateValue4!)
            }
            else if(predicateValue6 == nil){
                fetchRequest.predicate = NSPredicate(format: predicateFormat!, predicateValue!,predicateValue2!,predicateValue3!,predicateValue4!,predicateValue5!)
            }
            else if(predicateValue6 != nil){
                fetchRequest.predicate = NSPredicate(format: predicateFormat!, predicateValue!,predicateValue2!,predicateValue3!,predicateValue4!,predicateValue5!,predicateValue6!)
            }
            
        }
        
       
        do
        {
            let salesforceConfigData = try context.fetch(fetchRequest)
            if salesforceConfigData.count == 1
            {
                let objectUpdate = salesforceConfigData[0] as! NSManagedObject
                
                for (key,value) in updateKeyValue{
                    
                    objectUpdate.setValue(value, forKey: key)
                }
                
                
                
                do{
                    
                    try context.save()
                }
                catch
                {
                    Utility.showSwiftErrorMessage(error: "ManageCoreData:- UpdateAnyObjectRecord issue:- \(error.localizedDescription)")
                    print(error.localizedDescription)
                }
            }
        }
        catch
        {
              Utility.showSwiftErrorMessage(error: "ManageCoreData:- Outside Catch:- UpdateAnyObjectRecord issue:- \(error.localizedDescription)")
            print(error.localizedDescription)
        }
        
        
        
    }
    
   
    
    static func deleteRecord(salesforceEntityName:String,predicateFormat:String?=nil,predicateValue:String?=nil,predicateValue2:String?=nil,isPredicate:Bool){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: salesforceEntityName)
        
        if(isPredicate)
        {
            if(predicateValue2 == nil){
                fetchRequest.predicate = NSPredicate(format: predicateFormat!, predicateValue!)
                
            }
            else {
                fetchRequest.predicate = NSPredicate(format: predicateFormat!, predicateValue!,predicateValue2!)
            }

        }

        
        let result = try? context.fetch(fetchRequest)
        
     
        
        if(salesforceEntityName == "SurveyResponse"){
            let resultData = result as! [SurveyResponse]
            
            for object in resultData {
                context.delete(object)
            }
            
        }
        else if(salesforceEntityName == "SurveyQuestion"){
            let resultData = result as! [SurveyQuestion]
            
            for object in resultData {
                context.delete(object)
            }
            
        }
        else if(salesforceEntityName == "Cases"){
            let resultData = result as! [Cases]
            
            for object in resultData {
                context.delete(object)
            }
            
        }
        else if(salesforceEntityName == "Issues"){
            let resultData = result as! [Issues]
            
            for object in resultData {
                context.delete(object)
            }
            
        }
       
        
        do{
            
            try context.save()
        }
        catch
        {
            Utility.showSwiftErrorMessage(error: "ManageCoreData:- Delete Record issue:- \(error.localizedDescription)")
            print(error.localizedDescription)
        }
        
        
    }
    
    
    static func DeleteAllRecords(salesforceEntityName:String,completion: @escaping ((Bool)->())){
        
      
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: salesforceEntityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            
            try context.execute(request)
            completion(true)
            
        } catch {
            let nserror = error as NSError
            Utility.showSwiftErrorMessage(error: "ManageCoreData:- Delete All Records issue:- \(nserror.userInfo)")
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            completion(false)
            
            
        }
        
    }
    
    
    
    
    
}
