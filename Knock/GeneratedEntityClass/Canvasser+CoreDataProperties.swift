//
//  Canvasser+CoreDataProperties.swift
//  
//
//  Created by Kamal on 01/07/17.
//
//

import Foundation
import CoreData


extension Canvasser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Canvasser> {
        return NSFetchRequest<Canvasser>(entityName: "Canvasser");
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var type: String?

}
