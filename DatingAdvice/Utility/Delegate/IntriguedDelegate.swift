//
//  IntriguedDelegate.swift
//  Intrigued
//
//  Created by daniel helled on 25/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import Foundation

@objc protocol IntriguedDelegate: class {
    func moveToScreen(index:NSInteger)
    func moveToUserReply(index:NSInteger)
     func moveToAdviserController(index:NSInteger)
    func playAdvisorVideoBtn(index:NSInteger)
    func getUpdatedDetails()
}

protocol LocationManagerDelegate : class{
    func getCurrentLocation(address:String, latitude: String, longitude: String)
    
}
