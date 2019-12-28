//
//  IntriguedConstant.swift
//  Intrigued
//
//  Created by daniel helled on 21/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import Foundation
let APP_URL:String = "http://13.228.52.104:3002"
let kREGISTER_USER:String = "/userSignup"
let kLOGIN_USER:String = "/login"
let kLOGIN_COACH:String = "/coachLogin"
let kADD_NEWORDER:String = "/newOrder"
let kFORGOT_PASSWORD:String = "/forgotpass"
let kCHANGE_PASSWORD:String = "/changepassword"
let kCHECK_USEREXISTENCE:String = "/check_userExistence"
let kUPDATE_USER_DETAILS:String = "/edit_profile"
let kSEND_MESSAGE:String = "/sendMessage"
let kCHAT_MESSAGES:String = "/chatmessages"
let kMESSAGE_LIST:String = "/messages"
let kGET_CoachPricingDetails:String = "/get_price"
let KComplete_Profile_Mail:String = "/complete_mail"

// ******* Coach Request
//let kUPDATE_COACH_DETAILS:String = "/coach_editProfile"
//let kGET_COACH_LISTING:String = "/coachListing"
//let kGET_COACH_REQUEST:String = "/coachRequests"
///let kGET_USER_REQUEST:String = "/userRequests"
let kCOACH_RESPOND_REQUEST:String = "/coaches/respondtoReq"
let kLOGOUT:String = "/logout"
let kSEARCH:String = "/search"
let kGETALL_CATEGORY:String = "/getAllCategory"
let kADD_REVIEW:String = "/addReview"
let kEDIT_REVIEW:String = "/editReview"
let kGET_REVIEW_LIST:String = "/reviewListing"
//let kNotification_ON_OFF:String = "/open_close_notification"
//let kTransaction_KEY:String = "/GetAlluserPayments"
//let k_USER_Profile:String = "/userProfile"


//***************** Coach Request Api for session maintain ********************
let kUPDATE_COACH_DETAILS:String = "/coaches/coach_editProfile"
let kGET_COACH_LISTING:String = "/coaches/coachListing"
let kGET_COACH_REVIEW:String = "/coaches/order_review"
let kGET_COACH_LISTING_simple:String = "/coachListing"
let kGET_COACH_REQUEST:String = "/coaches/coachRequests"
let kGET_COACH_EARNINGS:String = "/coaches/coach_transaction"
let kNotification_Coach_ON_OFF:String = "/coaches/open_close_notification"
let k_GET_COACH_SERVICE_TAX:String = "/coaches/GetServiceTax"
let kCOACH_USER_REFUND:String = "/coaches/user_refund"
// *************** User Api for session expired *******
let kNotification_ON_OFF:String = "/users/open_close_notification"
let kGET_Coach_User_LISTING:String = "/users/coachListing"
let kGET_USER_REQUEST:String = "/users/userRequests"
let kTransaction_KEY:String = "/users/GetAlluserPayments"
let k_USER_Profile:String = "/userProfile"
let k_User_State_Listing = "/users/GetAllStates"
let k_USER_RESPONSETIME:String = "/users/response_time"
let k_USER_UpdateOrder:String = "/users/update_order"
let k_GET_USER_SERVICE_TAX:String = "/users/GetServiceTax"

//MARK:- **************** Alert Message ******************
let kEMAIL_BLANK: String = "Please enter your email"
let kUSERNMAE_BLANK: String = "Please enter your name"
let kLASTNMAE_BLANK: String = "Please enter your last name"
let kFIRSTNMAE_BLANK: String = "Please enter your first name"
let kPHONE_BLANK: String = "Please enter your phone number"
let kVALID_PHONE: String = "Please enter valid phone number"
let kADDRESS_BLANK: String = "Please enter your address"
let kOLD_PASSWORD_BLANK: String = "Please enter old password"
let kNEW_PASSWORD_BLANK: String = "Please enter new password"
let kVALID_EMAIL: String = "Please enter valid email Id"
let kPASSWORD_NOT_MATCH: String = "Your password doesn't match"
let kABOUTYOU_BLANK: String = "Please write something about yourself"
let kABOUTCATEGO_BLANK: String = "Please write something about your services"
let kQUESTION_BLANK: String = "Please write your question"
let kCATEGORY_BLANK: String = "Please select atleast one category"
let kCATEGORY_AboutThousandCh: String = "Please Enter atleast 1000 charcters about yourself"
