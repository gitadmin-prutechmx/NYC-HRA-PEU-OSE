//
//  Tenant+CoreDataProperties.swift
//  
//
//  Created by Kamal on 05/07/17.
//
//

import Foundation
import CoreData


extension Tenant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tenant> {
        return NSFetchRequest<Tenant>(entityName: "Tenant");
    }

    @NSManaged public var actionStatus: String?
    @NSManaged public var age: String?
    @NSManaged public var assignmentId: String?
    @NSManaged public var assignmentLocUnitId: String?
    @NSManaged public var dob: String?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var id: String?
    @NSManaged public var lastName: String?
    @NSManaged public var locationId: String?
    @NSManaged public var name: String?
    @NSManaged public var phone: String?
    @NSManaged public var unitId: String?

}
