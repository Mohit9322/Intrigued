//
//  StripeManager.swift
//  Pawpular
//
//  Created by daniel helled on 18/01/18.
//  Copyright © 2018 IBCMobile. All rights reserved.
//

import Foundation
import SystemConfiguration

typealias StripeCompletionBlock =  (_ data: NSDictionary?, _ responseCode: Int) ->()

extension StripeManager{
    
    
    func addCardOnStripe(data:NSDictionary, completionBlock:@escaping StripeCompletionBlock){
        
        let customerId = getUserStripe_CustomerId()
        print(customerId)
        let post_Url = NSString(format:"%@%@/sources",STRIPE_URL, customerId)
        postStripeResponseWithParameters(data: data, withPostType:true, postUrl:post_Url as String, completionBlock: completionBlock)
    }
    
    func getCardsListFromStripe(completionBlock:@escaping StripeCompletionBlock){
        let method = "GET"
        let get_Url = NSString(format:"%@%@/sources?object=card",STRIPE_URL,getUserStripe_CustomerId())
        getStripeResponseWithParameters(getUrl:get_Url as String,methodType:method, completionBlock: completionBlock)
    }
    
    func deleteCardFromStripe(cardId:String, completionBlock:@escaping StripeCompletionBlock){
        
        let method = "DELETE"
        let delete_URl = NSString(format:"%@%@/sources/%@",STRIPE_URL,getUserStripe_CustomerId(),cardId)
        getStripeResponseWithParameters(getUrl:delete_URl as String,methodType:method, completionBlock: completionBlock)
    }
    
    func makePaymentFromStripe(data:NSDictionary, completionBlock:@escaping StripeCompletionBlock){
        //let post_Url = NSString(format:"%@%@/sources",STRIPE_URL, customerId)
        postStripeRequestToMakePayment(data: data, postUrl:STRIPE_Charge_URL as String, completionBlock: completionBlock)
    }
    
    
    //    func makePaymentFromBackend(data:NSDictionary, completionBlock:@escaping StripeCompletionBlock){
    //        //let post_Url = NSString(format:"%@%@/sources",STRIPE_URL, customerId)
    //        postStripeRequestToMakePayment(data: data, postUrl:STRIPE_Charge_URL as String, completionBlock: completionBlock)
    //    }
    
    
}

class StripeManager : URLSession {
    
    
    func postStripeRequestToMakePayment(data: NSDictionary? , postUrl:String, completionBlock:@escaping StripeCompletionBlock) {
        
        // func postStripeToken(token: STPToken) {
        
        //  let URL = "http://localhost/donate/payment.php"
        //            let params = ["stripeToken": token.tokenId,
        //                          "amount": self.amountTextField.text.toInt()!,
        //                          "currency": "usd",
        //                          "description": self.emailTextField.text]
        
        
        
        //AppDelegate.getAppDelegate().showIndicator()
        let status = isInternetAvailable()
        print(status)
        if !(status) {
            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            completionBlock([:],0)
            return
        }
        
        guard let requestUrl = URL(string:postUrl) else { return }
        
        let session = URLSession.shared
        var request = URLRequest(url: requestUrl as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        
        let body1 : String = data?["BODY"] as? String ?? ""
        if body1 == "YES" {
            //let str1 : String = "card_id=\(data?["card_id"] as? String ?? "")"
            request.httpMethod = "POST"
            let body : NSMutableData = NSMutableData()
            let str1 : String = "card_id=\(data?["card_id"] as? String ?? "")"
            print(str1)
            let data1 = str1.data(using: String.Encoding.utf8)
            
            let str2 : String = "pay_amount=\(data?["pay_amount"] as? Int ?? 0)"
            print(str2)
            let data2 = str2.data(using: String.Encoding.utf8)
            
            //            let str3 : String = "currency=\(data?["currency"] as? String ?? "")"
            //            print(str3)
            //            let data3 = str3.data(using: String.Encoding.utf8)
            
            let description : String = "user_id=\(data?["user_id"] as? String ?? "")"
            print(description)
            let descriptiondata = description.data(using: String.Encoding.utf8)
            
            let customer : String  = "stripe_customerId=\(data?["stripe_customerId"] as? String ?? "")"
            print(customer)
            let customerData  = customer.data(using: String.Encoding.utf8)
            
            
            body.append(data1!)
            body.append(data2!)
            //body.append(data3!)
            body.append(descriptiondata!)
            body.append(customerData!)
            
            request.httpBody = body as Data
            
        }
        request.setValue("Bearer \(STRIPE_SECRET_KEY)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            if let responseError = error{
                completionBlock([:],0)
                
                //AppDelegate.getAppDelegate().hideIndicator()
                print("Response error: \(responseError)")
            }
            else
            {
                do {
                    
                    var statusCode : Int = 0
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        statusCode = httpResponse.statusCode
                        print("error \(httpResponse.statusCode)")
                    }
                    else
                    {
                        statusCode = 0
                    }
                    
                    let dictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    print(dictionary)
                    DispatchQueue.main.async(execute: {
                        //AppDelegate.getAppDelegate().hideIndicator()
                        completionBlock(dictionary,statusCode)
                    })
                }
                catch let jsonError as NSError{
                    print("JSON error: \(jsonError.localizedDescription)")
                    
                    DispatchQueue.main.async(execute: {
                        //AppDelegate.getAppDelegate().hideIndicator()
                        completionBlock([:],0)
                    })
                }
            }
        }
        // self.serverResponse(response: data, error: error! as NSError, completionBlock: completionBlock)
        // check for any errors
        
        task.resume()
        
    }
    
    func postStripeResponseWithParameters(data: NSDictionary, withPostType postType : Bool , postUrl:String, completionBlock:@escaping StripeCompletionBlock) {
        
       
      //  appDelegateRef.showIndicator()
        
        let status = isInternetAvailable()
        print(status)
        if !(status) {
            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            completionBlock([:],0)
            return
        }
        
        
        guard let requestUrl = URL(string:postUrl) else { return }
        
        let session = URLSession.shared
        var request = URLRequest(url: requestUrl as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        request.httpMethod = "POST"
        
        if postType {
            let body : NSMutableData = NSMutableData()
            let str : String = "source=\(data["source"]! as! String)"
            print(str)
            let data = str.data(using: String.Encoding.utf8)
            body.append(data!)
            request.httpBody = body as Data
        }
        
        request.setValue("Bearer \(STRIPE_SECRET_KEY)", forHTTPHeaderField: "Authorization")
        
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            if let responseError = error{
                completionBlock([:],0)
                appDelegateRef.hideIndicator()
                //AppDelegate.getAppDelegate().hideIndicator()
                print("Response error: \(responseError)")
            }
            else
            {
                do {
                    
                    var statusCode : Int = 0
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        statusCode = httpResponse.statusCode
                        print("error \(httpResponse.statusCode)")
                    }
                    else
                    {
                        statusCode = 0
                    }
                    
                    let dictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    print(dictionary)
                    DispatchQueue.main.async(execute: {
                        appDelegateRef.hideIndicator()
                        //AppDelegate.getAppDelegate().hideIndicator()
                        completionBlock(dictionary,statusCode)
                    })
                }
                catch let jsonError as NSError{
                    print("JSON error: \(jsonError.localizedDescription)")
                    
                    DispatchQueue.main.async(execute: {
                        appDelegateRef.hideIndicator()
                        //AppDelegate.getAppDelegate().hideIndicator()
                        completionBlock([:],0)
                    })
                }
            }
        }
        // self.serverResponse(response: data, error: error! as NSError, completionBlock: completionBlock)
        // check for any errors
        
        task.resume()
    }
    
    
    
    func getStripeResponseWithParameters(getUrl:String,methodType:String, completionBlock:@escaping StripeCompletionBlock) {
        
        ////AppDelegate.getAppDelegate().showIndicator()
        
        
        let status = isInternetAvailable()
        print(status)
        if !(status) {
            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            completionBlock([:],0)
            return
        }
        
        
        guard let requestUrl = URL(string:getUrl) else { return }
        
        let session = URLSession.shared
        var request = URLRequest(url: requestUrl as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        request.httpMethod = methodType
        request.setValue("Bearer \(STRIPE_SECRET_KEY)", forHTTPHeaderField: "Authorization")
        
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            if let responseError = error{
                completionBlock([:],0)
                
                //AppDelegate.getAppDelegate().hideIndicator()
                print("Response error: \(responseError)")
            }
            else
            {
                do {
                    
                    var statusCode : Int = 0
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        statusCode = httpResponse.statusCode
                        print("error \(httpResponse.statusCode)")
                    }
                    else
                    {
                        statusCode = 0
                    }
                    
                    let dictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    print(dictionary)
                    DispatchQueue.main.async(execute: {
                        //AppDelegate.getAppDelegate().hideIndicator()
                        completionBlock(dictionary,statusCode)
                    })
                }
                catch let jsonError as NSError{
                    print("JSON error: \(jsonError.localizedDescription)")
                    
                    DispatchQueue.main.async(execute: {
                        //AppDelegate.getAppDelegate().hideIndicator()
                        completionBlock([:],0)
                    })
                }
            }
        }
        // self.serverResponse(response: data, error: error! as NSError, completionBlock: completionBlock)
        // check for any errors
        
        task.resume()
    }
}


//ravi 14Feb2018

//#pragma mark ///////////////****** StripeErrorHandler ******////////////////

let BAD_REQUEST = "Bad Request"
let UNAUTHORIZED = "Unauthorized"
let REQUEST_FAILED = "Request Failed"
let NOT_FOUND = "Not Found"
let REQUEST_ERROR = "Conflict"
let SERVER_BUSY = "Too Many Requests"
let SERVER_ERROR = "Server Error"


typealias requestCompletion = (_ : Any, _: String) -> Void
typealias errorHandlerCompletion = (_: String, _: String) -> Void

class StripeConnection: NSObject {
    
    // Method to attach your Stripe account from Merchant account to get any payment
    
    class func addYourAccountToMerchantAccount(withParameters parameters: [AnyHashable: Any], requestCompletionWithResponse getResponse: @escaping requestCompletion) {
        
     //   appDelegateRef.showIndicator()
        let status = isInternetAvailable()
        print(status)
        if !(status) {
            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            //requestCompletion([:], REQUEST_FAILED)
            return
        }
        
        
        guard let requestUrl = URL(string:STRIPE_OAUTH_URL) else { return }
        
        let session = URLSession.shared
        var request = URLRequest(url: requestUrl as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        request.httpMethod = "POST"
        
        
        let body : NSMutableData = NSMutableData()
        let str1 : String = "client_id=\(parameters["client_id"]! as? String ?? "")"
        print(str1)
        let data1 = str1.data(using: String.Encoding.utf8)
        
        
        let str3 : String = "&client_secret=\(parameters["client_secret"]! as? String ?? "")"
        print(str3)
        let data3 = str3.data(using: String.Encoding.utf8)
        
        let description : String = "&grant_type=\(parameters["grant_type"]! as? String ?? "")"
        print(description)
        let descriptiondata = description.data(using: String.Encoding.utf8)
        
        let customer : String  = "&code=\(parameters["code"]! as? String ?? "")"
        print(customer)
        let customerData  = customer.data(using: String.Encoding.utf8)
        
        
        
        body.append(data1!)
        body.append(data3!)
        body.append(descriptiondata!)
        body.append(customerData!)
        
        request.httpBody = body as Data
        
        request.setValue("Bearer \(STRIPE_SECRET_KEY)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            if let responseError = error{
                //completionBlock([:], REQUEST_FAILED)
                
                appDelegateRef.hideIndicator()
                print("Response error: \(responseError)")
            }
            else
            {
                do {
                    
                    var statusCode : Int = 0
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        statusCode = httpResponse.statusCode
                        print("error \(httpResponse.statusCode)")
                    }
                    else
                    {
                        statusCode = 0
                    }
                    
                    let dictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    print(dictionary)
                    DispatchQueue.main.async(execute: {
                        appDelegateRef.hideIndicator()
                        getResponse(dictionary, SUCCESS_MESSAGE)
                        
                    })
                }
                catch let jsonError as NSError{
                    print("JSON error: \(jsonError.localizedDescription)")
                    
                    DispatchQueue.main.async(execute: {
                        appDelegateRef.hideIndicator()
                        //completionBlock([:], REQUEST_FAILED)
                    })
                }
            }
        }
        // self.serverResponse(response: data, error: error! as NSError, completionBlock: completionBlock)
        // check for any errors
        
        task.resume()
        
        
    }
    
    
    // ***************       Disconnect     *******************
    
    // Method to Disconnect your Stripe account from Merchant account
    class func disconnectCustomerStripeAccountToMerchantAccount(withParameters parameters: [AnyHashable: Any], requestCompletionWithResponse getResponse: @escaping requestCompletion) {
        
     //   appDelegateRef.showIndicator()
        let status = isInternetAvailable()
        print(status)
        if !(status) {
            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            //requestCompletion([:], REQUEST_FAILED)
            return
        }
        
        
        guard let requestUrl = URL(string:STRIPE_DEOAUTH_URL) else { return }
        
        let session = URLSession.shared
        var request = URLRequest(url: requestUrl as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        request.httpMethod = "POST"
        
        
        let body : NSMutableData = NSMutableData()
        let str1 : String = "client_id=\(parameters["client_id"]! as? String ?? "")"
        print(str1)
        let data1 = str1.data(using: String.Encoding.utf8)
        
        
        let str3 : String = "&stripe_user_id=\(parameters["stripe_user_id"]! as? String ?? "")"
        print(str3)
        let data3 = str3.data(using: String.Encoding.utf8)
        
        body.append(data1!)
        body.append(data3!)
        
        request.httpBody = body as Data
        
        request.setValue("Bearer \(STRIPE_SECRET_KEY)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            if let responseError = error{
                //completionBlock([:], REQUEST_FAILED)
                
                appDelegateRef.hideIndicator()
                print("Response error: \(responseError)")
            }
            else
            {
                do {
                    
                    var statusCode : Int = 0
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        statusCode = httpResponse.statusCode
                        print("error \(httpResponse.statusCode)")
                    }
                    else
                    {
                        statusCode = 0
                    }
                    
                    let dictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    print(dictionary)
                    DispatchQueue.main.async(execute: {
                        appDelegateRef.hideIndicator()
                        getResponse(dictionary, SUCCESS_MESSAGE)
                        
                    })
                }
                catch let jsonError as NSError{
                    print("JSON error: \(jsonError.localizedDescription)")
                    
                    DispatchQueue.main.async(execute: {
                        appDelegateRef.hideIndicator()
                        //completionBlock([:], REQUEST_FAILED)
                    })
                }
            }
        }
        // self.serverResponse(response: data, error: error! as NSError, completionBlock: completionBlock)
        // check for any errors
        
        task.resume()
        
        
    }
}


class StripeErrorHandler: NSObject {
    //Error handling of Stripe error response
    
    class func getMessageFor(_ response: URLResponse, handlerCompletedWith message: errorHandlerCompletion) {
        
        var statusCode: Int = 0
        let httpResponse = response as? HTTPURLResponse
        statusCode = httpResponse?.statusCode ?? 0
        if statusCode == 400 {
            message(BAD_REQUEST, "The request was unacceptable,Please try again")
        }
        else if statusCode == 401 {
            message(UNAUTHORIZED, "The request was unauthorized")
        }
        else if statusCode == 402 {
            message(REQUEST_FAILED, "")
        }
        else if statusCode == 404 {
            message(NOT_FOUND, "")
        }
        else if statusCode == 409 {
            message(REQUEST_ERROR, "")
        }
        else if statusCode == 429 {
            message(SERVER_BUSY, "")
        }
        else {
            message(SERVER_ERROR, "")
        }
    }
}







