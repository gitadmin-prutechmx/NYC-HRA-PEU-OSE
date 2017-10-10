//
//  ClientDO.swift
//  Knock
//
//  Created by Kamal on 26/09/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation

class ClientDO{
    
    var firstName:String
    var lastName:String
    var middleName:String
    var suffix:String
    var phone:String
    var email:String
    var dob:String
    var age:String
    
    init(firstName:String,lastName:String,middleName:String,suffix:String,phone:String,email:String,dob:String,age:String) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        self.suffix = suffix
        self.phone = phone
        self.email = email
        self.dob = dob
        self.age = age
        
    }
    
}
