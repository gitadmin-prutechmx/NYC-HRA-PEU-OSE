//
//  Location+CoreDataProperties.swift
//  
//
//  Created by Kamal on 01/07/17.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location");
    }

    @NSManaged public var assignmentId: String?
    @NSManaged public var assignmentLocId: String?
    @NSManaged public var city: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var state: String?
    @NSManaged public var street: String?
    @NSManaged public var zip: String?
    @NSManaged public var locAssignmentR: Assignment?
    @NSManaged public var locUnitR: NSSet?

}

// MARK: Generated accessors for locUnitR
extension Location {

    @objc(addLocUnitRObject:)
    @NSManaged public func addToLocUnitR(_ value: Unit)

    @objc(removeLocUnitRObject:)
    @NSManaged public func removeFromLocUnitR(_ value: Unit)

    @objc(addLocUnitR:)
    @NSManaged public func addToLocUnitR(_ values: NSSet)

    @objc(removeLocUnitR:)
    @NSManaged public func removeFromLocUnitR(_ values: NSSet)

}
