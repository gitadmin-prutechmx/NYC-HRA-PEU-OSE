//
//  SurveyUnit+CoreDataProperties.swift
//  
//
//  Created by Kamal on 05/07/17.
//
//

import Foundation
import CoreData


extension SurveyUnit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SurveyUnit> {
        return NSFetchRequest<SurveyUnit>(entityName: "SurveyUnit");
    }

    @NSManaged public var actionStatus: String?
    @NSManaged public var assignmentId: String?
    @NSManaged public var assignmentLocId: String?
    @NSManaged public var assignmentLocUnitId: String?
    @NSManaged public var locationId: String?
    @NSManaged public var surveyId: String?
    @NSManaged public var unitId: String?

}
