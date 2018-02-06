//
//  AssignmentDetailAPI.swift
//  EngageNYCDev
//
//  Created by Kamal on 11/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore

final class AssignmentDetailAPI : SFCommonAPI
{
    
    private static var sharedInstance: AssignmentDetailAPI = {
        let instance = AssignmentDetailAPI()
        return instance
    }()
    
    class var shared:AssignmentDetailAPI!{
        get{
            return sharedInstance
        }
    }
    
    /// Get All Data related to assignemnt from rest api. We are saving these to core data for offline use.
    ///
    /// - Parameters:
    ///   - callback: callback block.
    ///   - failure: failure block.
    //func syncDownWithCompletion(completion: @escaping (()->()), failure: @escaping ((String)->()))
    func syncDownWithCompletion(completion: @escaping (()->()))
    {
        var externalIdParams : [String:String] = [:]
        
        let req = SFRestRequest(method: .POST, path: SalesforceRestApiUrl.assignmentDetail, queryParams: nil)
        
        if let userObject = UserDetailAPI.shared.getUserDetail(){
            externalIdParams["externalId"] = userObject.externalId
        }
        
        
        do {
            
            let bodyData = try JSONSerialization.data(withJSONObject: externalIdParams, options: [])
            req.setCustomRequestBodyData(bodyData, contentType: "application/json")
        }
        catch{
            
            
        }
        
        req.endpoint = ""
        
        self.sendRequest(request: req, callback: { (response) in
            self.AssignmentsFromJSONList(jsonResponse: response)
            completion()
        }) { (error) in
            Logger.shared.log(level: .error, msg: error)
            Utility.displayErrorMessage(errorMsg: error)
            //failure(error)
        }
    }
    
    
    /// Get all the assignments from core data.
    ///
    /// - Returns: array of events.
    func getAllAssignments()->[Assignment]? {
        
        let assignmentResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.assignment.rawValue ,isPredicate:false) as? [Assignment]
        
        return assignmentResults
    }
    
    
    
    /// Convert the provided JSON into array of Events objects.
    ///
    /// - Parameter jsonResponse: json fetched from api.
    /// - Returns: nothing.
    private func AssignmentsFromJSONList(jsonResponse:Any){
        
        //First Delete all event records from Core data then insert
        
        
        ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.assignment.rawValue,completion: { isSuccess in
            
            ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.location.rawValue,completion: { isSuccess in
                
                ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.assignmentLocation.rawValue,completion: { isSuccess in
                    
                    ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.assignmentnotes.rawValue,completion: { isSuccess in
                        
                        ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.locationUnit.rawValue,completion: { isSuccess in
                            
                            ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.assignmentLocationUnit.rawValue,completion: { isSuccess in
                                
                                ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.contact.rawValue,completion: { isSuccess in
                                    
                                    ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.cases.rawValue,completion: { isSuccess in
                                        
                                        ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.issues.rawValue,completion: { isSuccess in
                                            
                                            ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.caseNotes.rawValue,completion: { isSuccess in
                                                
                                                ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.issueNotes.rawValue,completion: { isSuccess in
                                                    
                                                    ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.surveyQuestion.rawValue,completion: { isSuccess in
                                                        
                                                        
                                                        if(isSuccess){
                                                            
                                                            guard let jsonArray = (jsonResponse as? NSDictionary)?.value(forKey: "AssignmentData") as? NSArray else { return }
                                                            
                                                            for responseObject in jsonArray{
                                                                if let json = responseObject as? NSDictionary{
                                                                    AssignmentDetailAPI.fromJSONObject(jsonObject: json)
                                                                }
                                                            }
                                                        }
                                                    })
                                                    
                                                })
                                            })
                                        })
                                    })
                                })
                            })
                        })
                    })
                })
            })
        })
        
        
        
    }
    
    
}

extension AssignmentDetailAPI {
    
    class func fromJSONObject(jsonObject:NSDictionary){
        
        
        // Assignment object
        let assignmentObject = Assignment(context: context)
        assignmentObject.assignmentId = jsonObject["assignmentId"] as? String  ?? ""
        assignmentObject.assignmentName = jsonObject["assignmentName"] as? String  ?? ""
        
        assignmentObject.status = jsonObject["status"] as? String  ?? ""
        assignmentObject.eventId = jsonObject["eventId"] as? String  ?? ""
        assignmentObject.eventName = jsonObject["eventName"] as? String ?? ""
        
        assignmentObject.totalLocations = String(jsonObject["totalLocation"] as! Int)
        assignmentObject.totalUnits = String(jsonObject["totalLocationUnit"] as! Int)
        assignmentObject.totalSurvey = String(jsonObject["totalSurvey"] as! Int)
        assignmentObject.totalCanvassed = String(jsonObject["totalCanvassed"] as! Int)
        assignmentObject.completePercent = String(jsonObject["totalCanvassed"] as! Int)
        assignmentObject.totalContacts = String(jsonObject["numberOfClients"] as! Int)
        
        let assignedDate = jsonObject["assignedStatusDate"] as? String  ?? ""
        let completedDate = jsonObject["completeStatusDate"] as? String  ?? ""
        
        if(assignedDate != ""){
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date = dateFormatter.date(from: assignedDate)
            assignmentObject.assignedDate = date as NSDate?
            
        }
        else{
            assignmentObject.assignedDate = nil
        }
        
        if(completedDate != ""){
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date = dateFormatter.date(from: completedDate)
            assignmentObject.completedDate = date as NSDate?
            
        }
        else{
            
            assignmentObject.completedDate = assignmentObject.assignedDate?.addDays(daysToAdd: -3)
        }
        
        appDelegate.saveContext()
        
        
        //AssignmentSurvey
        
        guard let assignmentSurveyArray =  jsonObject.value(forKey: "AssignmentSurvey") as? NSArray else { return }
        
        for assignmentSurvey in assignmentSurveyArray{
            
            let surveyId = (assignmentSurvey as AnyObject).value(forKey: "surveyId") as? String ?? ""
            let surveyName = (assignmentSurvey as AnyObject).value(forKey: "surveyName") as? String ?? ""
            let isDefault = (assignmentSurvey as AnyObject).value(forKey: "isDefault") as? Bool ?? false
            
            let convertedJsonString = Utility.jsonToString(json: assignmentSurvey as AnyObject)
            
            
            
            let surveyObject = SurveyQuestion(context: context)
            surveyObject.assignmentId = assignmentObject.assignmentId
            surveyObject.surveyId = surveyId
            surveyObject.surveyName = surveyName
            surveyObject.surveyQuestionData = convertedJsonString
            
            surveyObject.isDefault = String(isDefault)
            
            
            appDelegate.saveContext()
            
        }
        
        //AssignmentLocation
        
        guard let assignmentLocationArray =  jsonObject.value(forKey: "assignmentLocation") as? NSArray else { return }
        
        
        for assignmentLocation in assignmentLocationArray{
            
            //Location
            let locationObject = Location(context: context)
            locationObject.locationId = (assignmentLocation as AnyObject).value(forKey: "locId") as? String ?? ""
            locationObject.locationName = (assignmentLocation as AnyObject).value(forKey: "name") as? String ?? ""
            locationObject.state = (assignmentLocation as AnyObject).value(forKey: "state") as? String ?? ""
            locationObject.city = (assignmentLocation as AnyObject).value(forKey: "city") as? String ?? ""
            locationObject.zip = (assignmentLocation as AnyObject).value(forKey: "zip") as? String ?? ""
            
            let streetNumber = (assignmentLocation as AnyObject).value(forKey: "streetNumber") as? String ?? ""
            let streetName = (assignmentLocation as AnyObject).value(forKey: "street") as? String ?? ""
            
            locationObject.streetNumber = streetNumber
            locationObject.streetName = streetName
            
            locationObject.street = streetNumber + " " + streetName
            
            locationObject.borough = (assignmentLocation as AnyObject).value(forKey: "borough") as? String ?? ""
            
            
            
            locationObject.assignmentId = assignmentObject.assignmentId
            locationObject.assignmentLocId = (assignmentLocation as AnyObject).value(forKey: "AssignLocId") as? String ?? ""
            
            locationObject.locStatus = (assignmentLocation as AnyObject).value(forKey: "status") as? String ?? ""
            locationObject.totalUnits = (assignmentLocation as AnyObject).value(forKey: "totalUnits") as? String ?? "0"
            
            let totalClients = (assignmentLocation as AnyObject).value(forKey: "numberOfClients") as! Int
            let totalUnits = (assignmentLocation as AnyObject).value(forKey: "numberOfUnitsAttempted") as! Int
            
            locationObject.totalClients = String(totalClients)
            locationObject.noOfUnitsAttempt  = String(totalUnits)
            locationObject.lastModifiedName  = (assignmentLocation as AnyObject).value(forKey: "lastModifiedName") as? String ?? ""
            
            
            appDelegate.saveContext()
            
            //AssignmentLocation
            
            let assignmnetLocationObject = AssignmentLocation(context: context)
            assignmnetLocationObject.assignmentLocId = locationObject.assignmentLocId
            assignmnetLocationObject.attempt = (assignmentLocation as AnyObject).value(forKey: "attempt") as? String ?? ""
            assignmnetLocationObject.notes = (assignmentLocation as AnyObject).value(forKey: "notes") as? String ?? ""
            assignmnetLocationObject.locStatus = locationObject.locStatus
            assignmnetLocationObject.totalUnits =  locationObject.totalUnits
            assignmnetLocationObject.actionStatus = ""
            
            appDelegate.saveContext()
            
            //AssignmentLNotes
            
            guard let assignmentLocNoteArray =  (assignmentLocation as AnyObject).value(forKey: "assignmentNoteInfo") as? NSArray else { return }
            
            for assignmentLocNote in assignmentLocNoteArray{
                
                
                let assignmentLocNoteObject = AssignmentNotes(context:context)
                assignmentLocNoteObject.assignmentLocId = locationObject.assignmentLocId
                assignmentLocNoteObject.notes = (assignmentLocNote as AnyObject).value(forKey: "name") as? String ?? ""
                assignmentLocNoteObject.createdDate = (assignmentLocNote as AnyObject).value(forKey: "createDate") as? String ?? ""
                assignmentLocNoteObject.canvasserId = (assignmentLocNote as AnyObject).value(forKey: "canvasserNameId") as? String ?? ""
                assignmentLocNoteObject.canvasserName = (assignmentLocNote as AnyObject).value(forKey: "canvasserName") as? String ?? ""
                assignmentLocNoteObject.locStatus = (assignmentLocNote as AnyObject).value(forKey: "status") as? String ?? ""
                
                appDelegate.saveContext()
                
            }
            
            
            //AssignmentLocationUnit
            
            guard let assignmentLocationUnitArray =  (assignmentLocation as AnyObject).value(forKey: "assignmentLocUnit") as? NSArray else { return }
            
            for assignmentLocationUnit in assignmentLocationUnitArray{
                
                
                //Location Unit
                let locationUnitObject = LocationUnit(context: context)
                
                locationUnitObject.locationUnitId = (assignmentLocationUnit as AnyObject).value(forKey: "locationUnitId") as? String ?? ""
                locationUnitObject.unitName = (assignmentLocationUnit as AnyObject).value(forKey: "Name") as? String ?? ""
                
                locationUnitObject.assignmentId = assignmentObject.assignmentId
                locationUnitObject.locationId = locationObject.locationId
                locationUnitObject.assignmentLocId = locationObject.assignmentLocId
                locationUnitObject.assignmentLocUnitId = (assignmentLocationUnit as AnyObject).value(forKey: "assignmentLocUnitId") as? String ?? ""
                
                locationUnitObject.actionStatus = ""
                locationUnitObject.syncDate = (assignmentLocationUnit as AnyObject).value(forKey: "unitSyncDate") as? String ?? ""
                
                let virtualUnit = (assignmentLocationUnit as AnyObject).value(forKey: "virtualUnit") as? Bool ?? false
                locationUnitObject.isVirtualUnit = String(virtualUnit)
                locationUnitObject.isPrivateHome = (assignmentLocationUnit as AnyObject).value(forKey: "privateHome") as? String ?? ""
                
                
                appDelegate.saveContext()
                
                
                
                //AssignmentLocationUnit
                
                let assignmentLocationUnitObj = AssignmentLocationUnit(context: context)
                assignmentLocationUnitObj.assignmentLocUnitId = locationUnitObject.assignmentLocUnitId
                assignmentLocationUnitObj.assignmentId = assignmentObject.assignmentId
                
                assignmentLocationUnitObj.actionStatus = ""
                assignmentLocationUnitObj.attempted = (assignmentLocationUnit as AnyObject).value(forKey: "attempt") as? String ?? ""
                assignmentLocationUnitObj.contacted = (assignmentLocationUnit as AnyObject).value(forKey: "isContact") as? String ?? ""
                assignmentLocationUnitObj.contactId = (assignmentLocationUnit as AnyObject).value(forKey: "tenant") as? String ?? ""
                
                if(assignmentLocationUnitObj.contacted == boolVal.yes.rawValue){
                    assignmentLocationUnitObj.contactOutcome = (assignmentLocationUnit as AnyObject).value(forKey: "reason") as? String ?? ""
                }
                else if(assignmentLocationUnitObj.contacted == boolVal.no.rawValue){
                    assignmentLocationUnitObj.contactOutcome = (assignmentLocationUnit as AnyObject).value(forKey: "contactOutcome") as? String ?? ""
                }
                else{
                    assignmentLocationUnitObj.contactOutcome = ""
                }
                
                assignmentLocationUnitObj.surveySyncDate = (assignmentLocationUnit as AnyObject).value(forKey: "surveySyncDate") as? String ?? ""
                
                // surveySyncDate
                
                assignmentLocationUnitObj.surveyed = (assignmentLocationUnit as AnyObject).value(forKey: "intake") as? String ?? ""
                assignmentLocationUnitObj.surveyId = (assignmentLocationUnit as AnyObject).value(forKey: "survey") as? String ?? ""
                assignmentLocationUnitObj.followUpDate = (assignmentLocationUnit as AnyObject).value(forKey: "followUpDate") as? String ?? ""
                assignmentLocationUnitObj.followUpType = (assignmentLocationUnit as AnyObject).value(forKey: "followUpType") as? String ?? ""
                assignmentLocationUnitObj.notes = (assignmentLocationUnit as AnyObject).value(forKey: "notes") as? String ?? ""
                
                appDelegate.saveContext()
                
                
                //AssignmentNotes
                
                guard let assignmentLocNoteArray =  (assignmentLocationUnit as AnyObject).value(forKey: "assignmentNoteInfo") as? NSArray else { return }
                
                for assignmentLocNote in assignmentLocNoteArray{
                    
                    
                    let assignmentLocNoteObject = AssignmentNotes(context:context)
                    assignmentLocNoteObject.assignmentLocUnitId = locationUnitObject.assignmentLocUnitId
                    assignmentLocNoteObject.notes = (assignmentLocNote as AnyObject).value(forKey: "name") as? String ?? ""
                    assignmentLocNoteObject.createdDate = (assignmentLocNote as AnyObject).value(forKey: "createDate") as? String ?? ""
                    assignmentLocNoteObject.canvasserId = (assignmentLocNote as AnyObject).value(forKey: "canvasserNameId") as? String ?? ""
                    assignmentLocNoteObject.canvasserName = (assignmentLocNote as AnyObject).value(forKey: "canvasserName") as? String ?? ""
                    assignmentLocNoteObject.unitOutcome = (assignmentLocNote as AnyObject).value(forKey: "UnitOutcome") as? String ?? ""
                    
                    
                    appDelegate.saveContext()
                    
                }
                
                
                
                //TenantInfo
                
                guard let contactInfoArray =  (assignmentLocationUnit as AnyObject).value(forKey: "TenantInfo") as? NSArray else { return }
                
                for contact in contactInfoArray {
                    let contactObject = Contact(context: context)
                    
                    contactObject.contactId = (contact as AnyObject).value(forKey: "tenantId") as? String ?? ""
                    contactObject.contactName = (contact as AnyObject).value(forKey: "name") as? String ?? ""
                    contactObject.firstName = (contact as AnyObject).value(forKey: "firstName") as? String ?? ""
                    contactObject.middleName = (contact as AnyObject).value(forKey: "middleName") as? String ?? ""
                    contactObject.lastName = (contact as AnyObject).value(forKey: "lastName") as? String ?? ""
                    contactObject.suffix = (contact as AnyObject).value(forKey: "suffix") as? String ?? ""
                    contactObject.phone = (contact as AnyObject).value(forKey: "phone") as? String ?? ""
                    contactObject.email = (contact as AnyObject).value(forKey: "email") as? String ?? ""
                    contactObject.dob = (contact as AnyObject).value(forKey: "dob") as? String ?? ""
                    contactObject.age = (contact as AnyObject).value(forKey: "age") as? String ?? ""
                    
                    contactObject.unitName = (contact as AnyObject).value(forKey: "aptNo") as? String ?? ""
                    contactObject.streetNum = (contact as AnyObject).value(forKey: "streetNum") as? String ?? ""
                    contactObject.streetName = (contact as AnyObject).value(forKey: "streetName") as? String ?? ""
                    contactObject.borough = (contact as AnyObject).value(forKey: "borough") as? String ?? ""
                    contactObject.zip = (contact as AnyObject).value(forKey: "zip") as? String ?? ""
                    contactObject.floor = (contact as AnyObject).value(forKey: "aptFloor") as? String ?? ""
                    
                    contactObject.locationUnitId = locationUnitObject.locationUnitId
                    
                    contactObject.assignmentId = assignmentObject.assignmentId
                    contactObject.assignmentLocId = locationObject.assignmentLocId
                    contactObject.assignmentLocUnitId = locationUnitObject.assignmentLocUnitId
                    contactObject.syncDate = (contact as AnyObject).value(forKey: "contactSyncDate") as? String ?? ""
                    contactObject.createdById = (contact as AnyObject).value(forKey: "CreatedById") as? String ?? ""
                    
                    contactObject.actionStatus = ""
                    
                    appDelegate.saveContext()
                }
                
                guard let caseInfoArray =  (assignmentLocationUnit as AnyObject).value(forKey: "caseInfo") as? NSArray else { return }
                
                for caseInfo in caseInfoArray {
                    
                    guard let caseListArray =  (caseInfo as AnyObject).value(forKey: "caseList") as? NSArray else { return }
                    
                    for caseData in caseListArray{
                        
                        let caseObject = Cases(context: context)
                        
                        caseObject.assignmentId = assignmentObject.assignmentId
                        caseObject.assignmentLocId = locationObject.assignmentLocId
                        
                        caseObject.caseId = (caseData as AnyObject).value(forKey: "Id") as? String ?? ""
                        caseObject.iOSCaseId = (caseData as AnyObject).value(forKey: "Id") as? String ?? ""
                        
                        caseObject.caseNo = (caseData as AnyObject).value(forKey: "CaseNumber") as? String ?? ""
                        caseObject.caseStatus = (caseData as AnyObject).value(forKey: "Status") as? String ?? ""
                        
                        caseObject.assignmentLocUnitId = locationUnitObject.assignmentLocUnitId
                        caseObject.actionStatus = ""
                        
                       // caseObject.caseNotes = (caseData as AnyObject).value(forKey: "Description") as? String ?? ""
                        
                        
                        if let contactResult = (caseData as AnyObject).value(forKey: "Contact") as? NSDictionary {
                            caseObject.clientId = contactResult.value(forKey: "Id") as? String ?? ""
                            //caseObject.clientName = contactResult.value(forKey: "Name") as? String ?? ""
                        }
                        
                        if let ownerResult = (caseData as AnyObject).value(forKey: "Owner") as? NSDictionary {
                            caseObject.caseOwnerId = ownerResult.value(forKey: "Id") as? String ?? ""
                            caseObject.caseOwner = ownerResult.value(forKey: "Name") as? String ?? ""
                        }
                        
                        
                        
                        
                        let dateOfIntake = (caseData as AnyObject).value(forKey: "Date_of_Intake__c") as? String ?? ""
                        
                        if(dateOfIntake.isEmpty){
                            caseObject.createdDate = ""
                        }
                        else{
                            
                            caseObject.createdDate =  Utility.convertToDateTimeFormat(dateVal: dateOfIntake)
                        }
                        
                        caseObject.caseDynamic = caseData as? NSObject
                        
                        appDelegate.saveContext()
                        
                        
                        
                        if let caseNotesRes = (caseData as AnyObject).value(forKey: "Case_Notes__r") as? NSDictionary {
                            
                            guard let caseNotesRecArray =  (caseNotesRes as AnyObject).value(forKey: "records") as? NSArray else { return }
                            
                            for caseNote in caseNotesRecArray{
                                
                                let caseNoteObject = CaseNotes(context:context)
                                
                                caseNoteObject.caseId = (caseNote as AnyObject).value(forKey: "Case__c") as? String ?? ""
                                
                                let createdDate = (caseNote as AnyObject).value(forKey: "CreatedDate") as? String ?? ""
                                
                                if(createdDate.isEmpty){
                                    caseNoteObject.createdDate = ""
                                }
                                else{
                                    
                                    caseNoteObject.createdDate =  Utility.convertToDateTimeFormat(dateVal: createdDate)
                                }
                                
                                
                                caseNoteObject.notes = (caseNote as AnyObject).value(forKey: "Case_Note_Description__c") as? String ?? ""
                                
                                caseNoteObject.assignmentLocUnitId = locationUnitObject.assignmentLocUnitId
                                
                                caseNoteObject.assignmentId = assignmentObject.assignmentId
                                
                                appDelegate.saveContext()
                            }
                            
                            
                        }
                        
                        
                    }
                    
                    
                    
                    guard let issueListArray =  (caseInfo as AnyObject).value(forKey: "issueList") as? NSArray else { return }
                    
                    for issueInfo in issueListArray {
                        
                        let issueObject = Issues(context: context)
                        issueObject.caseId = (issueInfo as AnyObject).value(forKey: "caseId") as? String ?? ""
                        issueObject.issueNo = (issueInfo as AnyObject).value(forKey: "issueNumber") as? String ?? ""
                        issueObject.issueId = (issueInfo as AnyObject).value(forKey: "issueId") as? String ?? ""
                        issueObject.issueType = (issueInfo as AnyObject).value(forKey: "issueType") as? String ?? ""
                        //issueObject.notes = (issueInfo as AnyObject).value(forKey: "issueNotes") as? String ?? ""
                    
                        
                        
                        issueObject.assignmentId = assignmentObject.assignmentId
                        issueObject.actionStatus = ""
                        
                        appDelegate.saveContext()
                        
                        guard let issueNotesResult =  (issueInfo as AnyObject).value(forKey: "issueNotesList") as? NSArray else { return }
                        
                        for issueNotesInfo in issueNotesResult{
                            
                            let issueNoteObject = IssueNotes(context: context)
                            issueNoteObject.issueId = issueObject.issueId
                            issueNoteObject.notes = (issueNotesInfo as AnyObject).value(forKey: "description") as? String ?? ""
                            issueNoteObject.createdDate = (issueNotesInfo as AnyObject).value(forKey: "createdDate") as? String ?? ""
                            issueNoteObject.assignmentId = assignmentObject.assignmentId
                            
                            appDelegate.saveContext()
                        }
                        
                        
                    }
                    
                }
                
            }
            
        }
        
        
        
        
    }
}
