//
//  Tenant+CoreDataProperties.swift
//  
//
//  Created by Kamal on 17/10/17.
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
    @NSManaged public var aptFloor: String?
    @NSManaged public var aptNo: String?
    @NSManaged public var assignmentId: String?
    @NSManaged public var assignmentLocId: String?
    @NSManaged public var assignmentLocUnitId: String?
    @NSManaged public var attempt: String?
    @NSManaged public var borough: String?
    @NSManaged public var contact: String?
    @NSManaged public var contactOutcome: String?
    @NSManaged public var dob: String?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var id: String?
    @NSManaged public var lastName: String?
    @NSManaged public var locationId: String?
    @NSManaged public var middleName: String?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var phone: String?
    @NSManaged public var sourceList: String?
    @NSManaged public var streetName: String?
    @NSManaged public var streetNum: String?
    @NSManaged public var suffix: String?
    @NSManaged public var unitId: String?
    @NSManaged public var virtualUnit: String?
    @NSManaged public var zip: String?

}
