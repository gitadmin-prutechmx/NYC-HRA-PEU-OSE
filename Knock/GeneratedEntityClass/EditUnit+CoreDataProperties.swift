//
//  EditUnit+CoreDataProperties.swift
//  
//
//  Created by Kamal on 30/08/17.
//
//

import Foundation
import CoreData


extension EditUnit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EditUnit> {
        return NSFetchRequest<EditUnit>(entityName: "EditUnit");
    }

    @NSManaged public var actionStatus: String?
    @NSManaged public var assignmentId: String?
    @NSManaged public var assignmentLocId: String?
    @NSManaged public var assignmentLocUnitId: String?
    @NSManaged public var attempt: String?
    @NSManaged public var inTake: String?
    @NSManaged public var isContact: String?
    @NSManaged public var lastCanvassedBy: String?
    @NSManaged public var locationId: String?
    @NSManaged public var reason: String?
    @NSManaged public var reKnockNeeded: String?
    @NSManaged public var surveyId: String?
    @NSManaged public var tenantId: String?
    @NSManaged public var unitId: String?
    @NSManaged public var unitNotes: String?

}
