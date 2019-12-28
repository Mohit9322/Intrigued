//
//  WebServices.swift
//  Intrigued
//
//  Created by daniel helled on 21/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import AWSS3
import AWSCore


typealias WSCompletionBlock =  (_ data: NSDictionary?) ->()
typealias WSCompletionStringBlock =  (_ data: String?) ->()
extension WebServices {
    
    func POSTFunctiontoWO_Body(serviceType:String, showIndicator:Bool, completionBlock:@escaping WSCompletionBlock){
        
        //let request =  ["type": serviceType,"devicetype":"I"] as [String : Any]
        let userinfo =  ["coach_id":getUserId()] as? [String : Any]
        //let requestDict = NSMutableDictionary()
        //requestDict.setValue(request, forKey: "request")
        //requestDict.setValue(userinfo, forKey: "userinfo")
        postRequest(urlString: APP_URL + serviceType,bodyData: userinfo as! NSDictionary,completionBlock: completionBlock)
        
    }
    
    func POSTFunctiontoGetDetails(data:NSDictionary,serviceType:String, showIndicator:Bool, completionBlock:@escaping WSCompletionBlock){
        
        //let request =  ["type": serviceType,"devicetype":"I"]as [String : Any]
        //let requestDict =  ["coach_id":getUserId(),"stripe_connect":data] as? [String : Any]
        //let userinfo =  ["userid":getUserId(),"sessionid":getSessionId()] as [String : Any]
        //let requestDict = NSMutableDictionary()
        //requestDict.setValue(request, forKey: "request")
        //requestDict.setValue(userinfo, forKey: "")
        //requestDict.setValue(data, forKey: "")
        //requestDict.setValue(data, forKey: "requestinfo")
        postRequest(urlString: APP_URL + serviceType,bodyData: data,completionBlock: completionBlock)
    }
    
    func simpleFunctiontoGetDetails(data:NSDictionary,serviceType:String, completionBlock:@escaping WSCompletionBlock){
        let urlStr:String = APP_URL + serviceType
        print(urlStr)
        simple_postRequest(urlString: APP_URL + serviceType, bodyData: data,completionBlock: completionBlock)
    }
    
    
    func mainFunctiontoGetDetails(data:NSDictionary,serviceType:String, completionBlock:@escaping WSCompletionBlock){
        let urlStr:String = APP_URL + serviceType
        print(urlStr)
        postRequest(urlString: APP_URL + serviceType, bodyData: data,completionBlock: completionBlock)
    }
    
    func hitAPiTogetDetails(serviceType:String, completionBlock:@escaping WSCompletionBlock){
        getRequest(urlString: APP_URL + serviceType,completionBlock: completionBlock)
    }
    
    func mainFunctiontoUploadImage(imageURl:URL, completionBlock:@escaping WSCompletionStringBlock){
        uploadImageonServer(imageURL: imageURl ,completionBlock: completionBlock)
        
    }
}

class WebServices: URLSession {
    func postRequest(urlString:String,bodyData:NSDictionary,completionBlock:@escaping WSCompletionBlock) -> () {
        
        let status = isInternetAvailable()
        print(status)
        if !(status) {
            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            completionBlock([:])
            return
        }
        print("Hitting URL with Post Request : \n \(urlString) \n\n params : \n \(bodyData)")
        let jsonData = try? JSONSerialization.data(withJSONObject: bodyData)
        guard let requestUrl = URL(string:urlString) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: requestUrl as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 1000)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        //Tejveer 09/3/18
        // let userinfo =  ["userid":getUserId(),"sessionid":getSessionId()] as [String : Any]
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(getSessionId())", forHTTPHeaderField: "authorization")
        request.setValue("\(getUserId())", forHTTPHeaderField: "user_id")
        ///
        let task = session.dataTask(with: request) {
            (data, response, error) in
           
            if let responseError = error{
                     completionBlock([:])
                     stopProgressIndicator()
                     print("Response error: \(responseError)")
            }
            else
            {
                do {
                    
                    let dictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                      print(dictionary)
                    let code = dictionary["code"] as? Int ?? 0
                    if code == 303 {
                        DispatchQueue.main.async(execute: {
                            removeUserDetails()
                            GIDSignIn.sharedInstance().signOut()
                            let STORYBOARD = UIStoryboard(name: "Main", bundle: nil)
                            let mainNavigation = STORYBOARD.instantiateViewController(withIdentifier:"MainNavigation") as! UINavigationController
                            let loginVC = STORYBOARD.instantiateViewController(withIdentifier:"LaunchViewController") as! LaunchViewController
                            mainNavigation.viewControllers = [loginVC]
                           
                            APPDELEGATE.window?.rootViewController = mainNavigation
                            return
                        })
                    }
                    else{
                        DispatchQueue.main.async(execute: {
                            completionBlock(dictionary)
                        })
                    }
                }
                catch let jsonError as NSError{
                    print("JSON error: \(jsonError.localizedDescription)")
                    completionBlock([:])
                 }
             }
        }
           // self.serverResponse(response: data, error: error! as NSError, completionBlock: completionBlock)
            // check for any errors
        
        task.resume()
        
    }
    
    func getRequest(urlString:String,completionBlock:@escaping WSCompletionBlock) -> () {
        
        let status = isInternetAvailable()
        print(status)
        if !(status) {
            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            completionBlock([:])
            return
        }
       
        guard let requestUrl = URL(string:urlString) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: requestUrl as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 1000)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            if let responseError = error{
                completionBlock([:])
                stopProgressIndicator()
                print("Response error: \(responseError)")
            }
            else
            {
                do {
                    
                    let dictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    print(dictionary)
                    DispatchQueue.main.async(execute: {
                        completionBlock(dictionary)
                    })
                }
                catch let jsonError as NSError{
                    print("JSON error: \(jsonError.localizedDescription)")
                    completionBlock([:])
                }
            }
        }
        // self.serverResponse(response: data, error: error! as NSError, completionBlock: completionBlock)
        // check for any errors
        
        task.resume()
        
    }
    
    
    
    func simple_postRequest(urlString:String,bodyData:NSDictionary,completionBlock:@escaping WSCompletionBlock) -> () {
        
        let status = isInternetAvailable()
        print(status)
        if !(status) {
            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            completionBlock([:])
            return
        }
        print("Hitting URL with Post Request : \n \(urlString) \n\n params : \n \(bodyData)")
        let jsonData = try? JSONSerialization.data(withJSONObject: bodyData)
        guard let requestUrl = URL(string:urlString) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: requestUrl as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 1000)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        //Tejveer 09/3/18
        // let userinfo =  ["userid":getUserId(),"sessionid":getSessionId()] as [String : Any]
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        ///
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            if let responseError = error{
                completionBlock([:])
                stopProgressIndicator()
                print("Response error: \(responseError)")
            }
            else
            {
                do {
                    
                    
                    let dictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    print(dictionary)
                    
                    
                    DispatchQueue.main.async(execute: {
                        completionBlock(dictionary)
                    })
                }
                catch let jsonError as NSError{
                    print("JSON error: \(jsonError.localizedDescription)")
                    completionBlock([:])
                }
            }
        }
        // self.serverResponse(response: data, error: error! as NSError, completionBlock: completionBlock)
        // check for any errors
        
        task.resume()
        
    }
    func uploadImageonServer(imageURL:URL,completionBlock:@escaping WSCompletionStringBlock) -> () {
        
        let status = isInternetAvailable()
        print(status)
        if !(status) {
            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            completionBlock(nil)
            return
        }
        print("Hitting imageURL : \n \(imageURL) ")
        
       
        let UUIdKey = generateUUID()
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = "wystap"
        uploadRequest?.key = "media-photo-\(UUIdKey)"
        uploadRequest?.contentType = "image/jpeg"
        uploadRequest?.body = imageURL as URL!
        
        //upload progress
        uploadRequest?.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
            DispatchQueue.main.async(execute: {
                //let totalByte = totalBytesSent // To show the updating data status in label.
                let totalByteSend = totalBytesExpectedToSend
                print("total byte send",totalByteSend)
            })
        }
        
        // Start upload
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error {
                DispatchQueue.main.async {
                    completionBlock(nil)
                    stopProgressIndicator()
                    print("Response error: \(error)")
                }
                //                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error._code) {
                //                    switch code {
                //                    case .cancelled, .paused:
                //                        break
                //                    default:
                //                        print("Error uploading: \(String(describing: uploadRequest?.key)) Error: \(error)")
                //                    }
                //                } else {
                //                    print("Error uploading: \(String(describing: uploadRequest?.key)) Error: \(error)")
                //                }
                return nil
            }
            let uploadOutput = task.result
            print("Upload complete for: \(String(describing: uploadRequest?.key))")
            let url = AWSS3.default().configuration.endpoint.url
            let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
                DispatchQueue.main.async {
                    let uploadUrl = publicURL?.absoluteString ?? ""
                     DispatchQueue.main.async(execute: {
                         completionBlock(uploadUrl)
                     })
                    //completion(nil, publicURL?.absoluteString)
               
            }
            print("Uploaded to:\(String(describing: publicURL))")
            return nil
        })
      }
    
    func uploadVideoonServer(imageURL:URL,completionBlock:@escaping WSCompletionStringBlock) -> () {
        
        let status = isInternetAvailable()
        print(status)
        if !(status) {
            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            completionBlock(nil)
            return
        }
        print("Hitting imageURL : \n \(imageURL) ")
       

        
        let UUIdKey = generateUUID()
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = "wystap"
        uploadRequest?.key = "media-Video-\(UUIdKey)"
        uploadRequest?.contentType = "video/mp4"
        uploadRequest?.body = imageURL
        
        uploadRequest?.acl = AWSS3ObjectCannedACL.publicRead
        //upload progress
        uploadRequest?.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
            DispatchQueue.main.async(execute: {
                //let totalByte = totalBytesSent // To show the updating data status in label.
                let totalByteSend = totalBytesExpectedToSend
                print("total byte send",totalByteSend)
            })
        }
        
        // Start upload
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error {
                DispatchQueue.main.async {
                    completionBlock(nil)
                    stopProgressIndicator()
                    print("Response error: \(error)")
                }
             
                return nil
            }
            let uploadOutput = task.result
            print("Upload complete for: \(String(describing: uploadRequest?.key))")
            let url = AWSS3.default().configuration.endpoint.url
            let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
            DispatchQueue.main.async {
                let uploadUrl = publicURL?.absoluteString ?? ""
                DispatchQueue.main.async(execute: {
                    completionBlock(uploadUrl)
                })
                //completion(nil, publicURL?.absoluteString)
                
            }
            print("Uploaded to:\(String(describing: publicURL))")
            return nil
        })
    }
    
    
    //MARK: SERVER RESPONSE
    
//    func serverResponse(response:Any?,error:Error?,completionBlock: WSCompletionBlock?){
//        
//        guard error == nil else {
//            return
//        }
//        // make sure we got data
//        guard let responseData = response else {
//            print("Error: did not receive data")
//            return
//        }
//        // parse the result as JSON, since that's what the API provides
//        do {
//            guard let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
//                print("error trying to convert data to JSON")
//                return
//            }
//            // now we have the todo, let's just print it to prove we can access it
//            print("The todo is: " + todo.description)
//            
//            // the todo object is a dictionary
//            // so we just access the title using the "title" key
//            // so check for a title and print it if we have one
//            guard let todoTitle = todo["title"] as? String else {
//                print("Could not get todo title from JSON")
//                return
//            }
//            print("The title is: " + todoTitle)
//        } catch  {
//            print("error trying to convert data to JSON")
//            return
//        }
//    }
//    
    
}
