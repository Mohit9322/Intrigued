//
//  FacebookManager.swift
//  Intrigued
//
//  Created by daniel helled on 20/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import FBSDKLoginKit


typealias FacebookLoginCompletionHandler = (_ userDict: [AnyHashable: Any], _ error: Error?) -> Void
class FacebookManager: NSObject {
   
    func login(withPermissions permissionArray: [Any], viewController: UIViewController, completionHandler: @escaping FacebookLoginCompletionHandler) {
        
        
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        if self.isLoggedIn() {
             fbLoginManager.logOut()
        }
       
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: viewController, handler:{ (result, error) -> Void in
            if (error == nil)
            {
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        if((FBSDKAccessToken.current()) != nil){
                            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                                   if (error == nil){
                                    //  self.dict = result as! [String : AnyObject]
                                      completionHandler(result as! [AnyHashable : Any], error)
                                    }
                               })
                          }
                     }
                }
                else{
                    completionHandler([:], error)
                }
            }
            else{
                print("error ===", error?.localizedDescription ?? "")
                completionHandler([:], error)
            }
        })
    }
    func isLoggedIn() -> Bool {
        return (FBSDKAccessToken.current() != nil) ? true : false
    }
}
