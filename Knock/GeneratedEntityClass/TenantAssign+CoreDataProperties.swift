//
//  TenantAssign+CoreDataProperties.swift
//  
//
//  Created by Kamal on 01/07/17.
//
//

import Foundation
import CoreData


extension TenantAssign {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TenantAssign> {
        return NSFetchRequest<TenantAssign>(entityName: "TenantAssign");
    }

    @NSManaged public var actionStatus: String?
    @NSManaged public var assignmentId: String?
    @NSManaged public var assignmentLocId: String?
    @NSManaged public var assignmentLocUnitId: String?
    @NSManaged public var locationId: String?
    @NSManaged public var tenantId: String?
    @NSManaged public var unitId: String?

}
