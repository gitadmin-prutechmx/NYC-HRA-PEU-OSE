//
//  EditLocation+CoreDataProperties.swift
//  
//
//  Created by Kamal on 10/11/17.
//
//

import Foundation
import CoreData


extension EditLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EditLocation> {
        return NSFetchRequest<EditLocation>(entityName: "EditLocation")
    }

    @NSManaged public var actionStatus: String?
    @NSManaged public var assignmentId: String?
    @NSManaged public var assignmentLocId: String?
    @NSManaged public var attempt: String?
    @NSManaged public var canvassingStatus: String?
    @NSManaged public var lastModifiedName: String?
    @NSManaged public var locationId: String?
    @NSManaged public var noOfUnits: String?
    @NSManaged public var notes: String?

}
