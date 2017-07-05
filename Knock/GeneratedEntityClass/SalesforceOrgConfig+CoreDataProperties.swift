//
//  SalesforceOrgConfig+CoreDataProperties.swift
//  
//
//  Created by Kamal on 05/07/17.
//
//

import Foundation
import CoreData


extension SalesforceOrgConfig {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SalesforceOrgConfig> {
        return NSFetchRequest<SalesforceOrgConfig>(entityName: "SalesforceOrgConfig");
    }

    @NSManaged public var accessToken: String?
    @NSManaged public var clientId: String?
    @NSManaged public var clientSecret: String?
    @NSManaged public var companyName: String?
    @NSManaged public var endPointUrl: String?
    @NSManaged public var password: String?
    @NSManaged public var userName: String?

}
