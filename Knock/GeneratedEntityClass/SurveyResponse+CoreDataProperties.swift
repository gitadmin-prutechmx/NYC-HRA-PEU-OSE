//
//  SurveyResponse+CoreDataProperties.swift
//  
//
//  Created by Kamal on 05/07/17.
//
//

import Foundation
import CoreData


extension SurveyResponse {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SurveyResponse> {
        return NSFetchRequest<SurveyResponse>(entityName: "SurveyResponse");
    }

    @NSManaged public var actionStatus: String?
    @NSManaged public var assignmentLocUnitId: String?
    @NSManaged public var surveyId: String?
    @NSManaged public var surveyQuestionRes: NSObject?
    @NSManaged public var unitId: String?

}
