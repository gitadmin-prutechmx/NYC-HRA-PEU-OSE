//
//  Unit+CoreDataProperties.swift
//  
//
//  Created by Kamal on 01/07/17.
//
//

import Foundation
import CoreData


extension Unit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Unit> {
        return NSFetchRequest<Unit>(entityName: "Unit");
    }

    @NSManaged public var actionStatus: String?
    @NSManaged public var apartment: String?
    @NSManaged public var assignmentId: String?
    @NSManaged public var assignmentLocId: String?
    @NSManaged public var assignmentLocUnitId: String?
    @NSManaged public var floor: String?
    @NSManaged public var id: String?
    @NSManaged public var locationId: String?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var surveyStatus: String?
    @NSManaged public var syncDate: String?
    @NSManaged public var unitLocR: Location?

}
