//
//  Assignment+CoreDataProperties.swift
//  
//
//  Created by Kamal on 05/07/17.
//
//

import Foundation
import CoreData


extension Assignment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Assignment> {
        return NSFetchRequest<Assignment>(entityName: "Assignment");
    }

    @NSManaged public var completePercent: String?
    @NSManaged public var eventId: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var status: String?
    @NSManaged public var totalCanvassed: String?
    @NSManaged public var totalLocations: String?
    @NSManaged public var totalSurvey: String?
    @NSManaged public var totalUnits: String?
    @NSManaged public var assignmentEventR: Event?
    @NSManaged public var assignmentLocR: NSSet?

}

// MARK: Generated accessors for assignmentLocR
extension Assignment {

    @objc(addAssignmentLocRObject:)
    @NSManaged public func addToAssignmentLocR(_ value: Location)

    @objc(removeAssignmentLocRObject:)
    @NSManaged public func removeFromAssignmentLocR(_ value: Location)

    @objc(addAssignmentLocR:)
    @NSManaged public func addToAssignmentLocR(_ values: NSSet)

    @objc(removeAssignmentLocR:)
    @NSManaged public func removeFromAssignmentLocR(_ values: NSSet)

}
