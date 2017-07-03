//
//  Event+CoreDataProperties.swift
//  
//
//  Created by Kamal on 01/07/17.
//
//

import Foundation
import CoreData


extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event");
    }

    @NSManaged public var endDate: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var startDate: String?
    @NSManaged public var eventAssignementR: NSSet?

}

// MARK: Generated accessors for eventAssignementR
extension Event {

    @objc(addEventAssignementRObject:)
    @NSManaged public func addToEventAssignementR(_ value: Assignment)

    @objc(removeEventAssignementRObject:)
    @NSManaged public func removeFromEventAssignementR(_ value: Assignment)

    @objc(addEventAssignementR:)
    @NSManaged public func addToEventAssignementR(_ values: NSSet)

    @objc(removeEventAssignementR:)
    @NSManaged public func removeFromEventAssignementR(_ values: NSSet)

}
