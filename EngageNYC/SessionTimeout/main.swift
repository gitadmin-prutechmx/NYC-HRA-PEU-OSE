//
//  main.swift
//  EngageNYC
//
//  Created by Kamal on 23/03/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv)
        .bindMemory(
            to: UnsafeMutablePointer<Int8>.self,
            capacity: Int(CommandLine.argc)),
    NSStringFromClass(TimerApplication.self),
    NSStringFromClass(AppDelegate.self)
)
