//
//  SalesforceRestApiUrl.swift
//  Knock
//
//  Created by Kamal on 12/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation

class SalesforceRestApiUrl{
    
    static let assignmentDetail = "/services/apexrest/assignmentdetail"

    static let submitSurveyResponse = "/services/apexrest/surveyresponse"
    
    static let updateAssignmentLocation = "/services/apexrest/updateLocation"
    
    static let updateAssignmentLocationUnit = "/services/apexrest/updateUnit"
    
    static let createContact = "/services/apexrest/createTenant"
    
    static let createLocationUnit = "/services/apexrest/createUnit"
    
    static let assignmentdetailchart = "/services/apexrest/assignmentdetailchart"
    
    static let userDetail = "/services/apexrest/userDetail"
    
    static let picklistValue = "/services/apexrest/picklistValue/"
    
    static let caseConfiguration = "/services/apexrest/caseconfiguration"
    
    static let createCase = "/services/apexrest/createcase"
    
    static let createIssue = "/services/apexrest/createissue"
    
    static let events = "/services/apexrest/eventdetail/"
    
    static let eventsConfig = "/services/apexrest/eventconfiguration"
    
    static let assignmentHistory = "/services/apexrest/assignmenthistory"
    
    static let createNewEventReg = "/services/apexrest/createNewEventRegistration"
    
    
    
    //Core_Picklist_Value_API
    //urlMapping = picklistValue
    
    //these apis are not used --deprecated
    static let assignTenant = "/services/apexrest/assignTenant"
    static let getAllSurveyData = "/services/apexrest/assignmentSurvey"
    
    
    
}
