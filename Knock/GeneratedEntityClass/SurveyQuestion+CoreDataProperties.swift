//
//  SurveyQuestion+CoreDataProperties.swift
//  
//
//  Created by Kamal on 05/07/17.
//
//

import Foundation
import CoreData


extension SurveyQuestion {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SurveyQuestion> {
        return NSFetchRequest<SurveyQuestion>(entityName: "SurveyQuestion");
    }

    @NSManaged public var assignmentId: String?
    @NSManaged public var surveyId: String?
    @NSManaged public var surveyName: String?
    @NSManaged public var surveyQuestionData: String?

}
