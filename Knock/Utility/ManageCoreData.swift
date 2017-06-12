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
    
    
    static func fetchData(salesforceEntityName:String,predicateFormat:String,predicateValue:String,isPredicate:Bool) -> [Any]{
        
        var results = [Any]()
        
        //"companyName = PEU"
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: salesforceEntityName)
        
        if(isPredicate){
            // fetchRequest.predicate = NSPredicate(format: predicateFormat)
            fetchRequest.predicate = NSPredicate(format: predicateFormat, predicateValue)

        }
      
      
        do {
            results = try context.fetch(fetchRequest)
            return results
            
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
           
        }
        
       
    }
    
}
