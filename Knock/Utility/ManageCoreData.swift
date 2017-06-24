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
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
           
        }
        
       
    }
    
    static func updateData(salesforceEntityName:String,valueToBeUpdate:String,updatekey:String,predicateFormat:String?=nil,predicateValue:String?=nil,isPredicate:Bool){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: salesforceEntityName)
        
       

        
        
        fetchRequest.predicate = NSPredicate(format: predicateFormat!, predicateValue!)
        
        do
        {
            let salesforceConfigData = try context.fetch(fetchRequest)
            if salesforceConfigData.count == 1
            {
                let objectUpdate = salesforceConfigData[0] as! NSManagedObject
                objectUpdate.setValue(valueToBeUpdate, forKey: updatekey)
                
                do{
                    try context.save()
                }
                catch
                {
                    print(error.localizedDescription)
                }
            }
        }
        catch
        {
            print(error.localizedDescription)
        }
        
        
        
    }
    
    
    static func updateRecord(salesforceEntityName:String,updateKeyValue:[String:String],predicateFormat:String?=nil,predicateValue:String?=nil,predicateValue2:String?=nil,predicateValue3:String?=nil,predicateValue4:String?=nil,predicateValue5:String?=nil,predicateValue6:String?=nil,isPredicate:Bool){
        
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
        
       // fetchRequest.predicate = NSPredicate(format: predicateFormat!, predicateValue!)
        
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
                    print(error.localizedDescription)
                }
            }
        }
        catch
        {
            print(error.localizedDescription)
        }
        
        
        
    }

    
    
    
    static func DeleteAllRecords(salesforceEntityName:String){
        
                            //delete records
        //                if let result = try? context.fetch(fetchRequest) {
        //                    for object in result {
        //                        context.delete(object)
        //                    }
        //                }
        
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: salesforceEntityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            
            try context.execute(request)

            
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            
        }
        
    }
    
    static func DeleteAllDataFromEntities(){
        DeleteAllRecords(salesforceEntityName: "Event")
        DeleteAllRecords(salesforceEntityName: "Assignment")
        DeleteAllRecords(salesforceEntityName: "Location")
        DeleteAllRecords(salesforceEntityName: "Unit")
        DeleteAllRecords(salesforceEntityName: "SurveyQuestion")
        DeleteAllRecords(salesforceEntityName: "SurveyUnit")
        DeleteAllRecords(salesforceEntityName: "SurveyResponse")
        DeleteAllRecords(salesforceEntityName: "Tenant")
        
        DeleteAllRecords(salesforceEntityName: "TenantAssign")
        DeleteAllRecords(salesforceEntityName: "EditUnit")
        DeleteAllRecords(salesforceEntityName: "EditLocation")
    }
    
}
