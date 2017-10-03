//
//  Chart+CoreDataProperties.swift
//  
//
//  Created by Kamal on 05/07/17.
//
//

import Foundation
import CoreData


extension Chart {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Chart> {
        return NSFetchRequest<Chart>(entityName: "Chart");
    }

    @NSManaged public var chartField: String?
    @NSManaged public var chartLabel: String?
    @NSManaged public var chartType: String?
    @NSManaged public var chartValue: String?

}
