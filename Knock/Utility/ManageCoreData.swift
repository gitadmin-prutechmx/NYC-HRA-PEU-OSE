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
    
    
    static func fetchData(salesforceEntityName:String,predicateFormat:String?=nil,predicateValue:String?=nil,isPredicate:Bool) -> [Any]{
        
        var results = [Any]()
        
        //"companyName = PEU"
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: salesforceEntityName)
        
        if(isPredicate){
            // fetchRequest.predicate = NSPredicate(format: predicateFormat)
            fetchRequest.predicate = NSPredicate(format: predicateFormat!, predicateValue!)

        }
      
      
        do {
            results = try context.fetch(fetchRequest)
            return results
            
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
           
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
    
}
