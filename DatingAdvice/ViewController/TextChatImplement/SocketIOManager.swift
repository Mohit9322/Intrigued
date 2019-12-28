//
//  SocketIOManager.swift
//  WyseTap
//
//  Created by SWS on 22/06/17.
//  Copyright © 2017 Test Org. All rights reserved.
//

import UIKit
import AVFoundation
import SocketIO

//protocol SocketIOManagerDelegate {
//    func getNewSingleChatMessage(messageObj: ChatMessage)
//    func getNotifiedWhenSocketIsConnected()
//}

/*
class SocketIOManager: NSObject {
    
    //MARK: Singlton Instance
    static let sharedInstance = SocketIOManager()
    //var delegate: SocketIOManagerDelegate?
    //Socket IOClient
    var socket: SocketIOClient?
    let Token = "7166A88F0FA2C8DA4DF1C181D73AD755AA4FD55098C6BF69A53BCB66BE86CB91"
    var lastDate : NSDate?
    var roomId : String?
    var messageid = ""
    var duplicatemessageid : String = ""
    
    override init() {
        super.init()
        setUpSocket()
    }
    private func setUpSocket() {
        //let myClone = Person.decode()
//        let deviceToken = UserDefaults.standard.object(forKey: "deviceToken")
 let dict_Requestinfo = ["id": "",
                        "deviceToken":"",
      "deviceId": "1",
         "deviceType": "I",
        ]
        let options = SocketIOClientOption.connectParams(dict_Requestinfo)
        
        
        
        socket = SocketIOClient.init(manager: URL(string: "http://13.228.52.104:5000/)")! as! SocketManagerSpec, nsp: [options,.forceWebsockets(true)])
        socket?.joinNamespace("/wysetap")
    }
    
    
    //MARK: Socket Connection
    func establishConnection() {
        self.setUpSocket()
        addHandlers()
        
        socket?.connect()
        socket?.on("connect") { data, ack in
            print("ravi-->socket connect with app \(data) \(ack)")
            appDelegate.isSocketConnected = true
            
            if let delegate = self.delegate {
                delegate.getNotifiedWhenSocketIsConnected()
            }
        }
        
        socket?.on(clientEvent: .connect) {data, ack in
            print("socket connect")
        }
        
        socket?.on("error") {data, ack in
            appDelegate.isSocketConnected = false
            print("ravi-->socket error \(data) \(ack)")

        }
        
        
        
    }
    
    //MARK: Close Connection
    func closeConnection() {
        socket?.disconnect()
    }
    
    
    // Send message delivered
    func sendMessage(message: [String : Any], nickname: String) {
        
        socket?.emitWithAck("message",with: [message]).timingOut(after:0, callback: { data in
            
           // print("send message \(data)")
        })
    }
    
    // read message ack sent
    func sendReadMessageAck(message: [NSObject : AnyObject], nickname: String) {
        socket?.emitWithAck("markmessageasread", with: [message]).timingOut(after: 0, callback: { data in
        })
       
    }

    
    func addHandlers() {
        
        socket?.onAny { ack in
            
        }
        //when socket is connected
        socket?.on("connected") { data,ack in
            appDelegate.isSocketConnected = true
            print("ravi-->socket connected \(data) \(ack)")
        }
        
        
        //when somebody disconnect socket
        socket?.on("disconnect")   { data, ack in
            appDelegate.isSocketConnected = false
            
            let date = Date()
            let currentdate = changeToServerDateFromLocaleDate(date: date)
            UserDefaults.standard.set(currentdate, forKey: "lastDate")
            self.establishConnection()
        }
        
        // when user isonline socket
        socket?.on("isonline") { data, ack in
            
        }
        // when somebody left socket
        socket?.on("user left") { data, ack in
            
        }
        
        // when somebody typing
        socket?.on("istyping")   { data, ack in
            
        }
        
        // when stop typing
        socket?.on("stoptyping")  { data, ack in
            
        }
        
        // when message edited
        socket?.on("editmsg")  { data, ack in
            
        }
        // when delivery ack received
        socket?.on("delivery_ack")  { data, ack in
            
        }
        // when read ack received
        socket?.on("read_ack") { data, ack in
            
        }
        
        // when we got messages from other
        socket?.on("handlemessage") { data, ack in
            //print(data)
            let msgArray = data as Array
            
    
           //IANotificationBar.sharedInstance.showMessage(title: "Hello", description: "Hello This is a Simple Text Message to notify Your User's")
            
            if (msgArray.count > 0) {
                
                
                self.saveSingleChatMessages(messages: msgArray as Array)
            }
         }
        
        func showNotifificationAlert(text:String,bgColor:UIColor,textColor:UIColor){
            let l = UILabel()
            l.textColor = textColor
            l.backgroundColor = bgColor
            l.font = UIFont(name: "Poppins-Regular" , size:14)
            l.text = text
            l.textAlignment = .center
            l.numberOfLines = 0
            if let window :UIWindow = UIApplication.shared.keyWindow {
                l.frame = CGRect(x:0,y:0,width: SCREEN_WIDTH,height: 64)
                window.addSubview(l)
            }
            l.center.y -= 50
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
                
                l.center.y += 50
                
            }, completion: {_ in
                
                UIView.animate(withDuration: 0.5, animations: {
                    l.center.y -= 40
                }, completion: { (_) in
                    l.removeFromSuperview()
                    
                })
                
            })
            
        }
        
        // when refreshroom
        socket?.on("refreshroom") { data, ack in
            
            if (data.count>0)
            {
                print("refreshroom calling with data")
                appDelegate.msgCounts = data.count
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OfflineMessage"), object: nil)
                self.getOfflineSingleChatMessagesOfRoomIds(roomIds: data as [Any])
            }
        }
    }
    
    
    //MARK: Get lastDate
    func lastDateExist() -> Bool {
        return UserDefaults.standard.string(forKey: "lastDate") != nil
    }
    
    
    //MARK: -  Save Messages from handle message
    private func saveSingleChatMessages(messages : [Any]) {
        
        for i in (0..<messages.count).reversed() {
            
            let msgDict = messages[i] as! [String:Any]
            self.saveChatMessage(msgDict: msgDict)
        }
    }
    
    private func saveChatMessage(msgDict : [String:Any]) {
        
        appDelegate.roomId = msgDict["room"] as! String
        
        var msgObject: ChatMessage = ChatMessage()
        msgObject = msgObject.setRecentMessageDetail(msgInfo: msgDict)
        messageid = msgObject.message_Id ?? ""
        let myClone = Person.decode()
        let userId = msgObject.message_From?["user_id"] as? String ?? ""
        
        if myClone?.loginID == userId {
            Chat.sharedInstance.updateSingleChatMessage(Object: msgObject)
        }
        else {
            if messageid == duplicatemessageid {
                return
            }
            else {
                Chat.sharedInstance.setChatHistoryInDatabase(message: msgObject)
                print(msgObject.message_RoomId ?? "")
                duplicatemessageid = messageid
            }
            if let delegate = delegate {
                delegate.getNewSingleChatMessage(messageObj: msgObject)
            }
        }
    }
    // End save chat messages
    
    
    //MARK: - Get and Save Offline Refresh Room Msgs
    private func getOfflineSingleChatMessagesOfRoomIds(roomIds : [Any]) {// appDelegate.isChatView = true
        
        for temp in roomIds {
            let tempDict = temp as? [String: Any]
            roomId  = tempDict?["room_id"] as? String
            appDelegate.refreshRoom = roomId!
            
            if appDelegate.refreshRoom == appDelegate.duplicaterefreshroom {
                return
            }
            appDelegate.duplicaterefreshroom = appDelegate.refreshRoom
            var dict_Parameters = NSMutableDictionary()
            let myClone = Person.decode()
            
            let dateExist:Bool = self.lastDateExist()
            var lastDateStr = ""
            
            if dateExist {
                lastDateStr = UserDefaults.standard.object(forKey: "lastDate") as? String ?? ""
            }
            else {
                let date = Date()
                lastDateStr = changeToServerDateFromLocaleDate(date: date)!
            }
            dict_Parameters = ["user_id" : myClone?.loginID ?? "", "room_id":roomId ?? ""]//, "message_id" : messageid]
            
            // Hit webservice to get chat messages is Connected To Network
            let manager = NetworkManager()
            //manager.delegate     = self
            manager.getServerDataWith(dict_Parameters: dict_Parameters, withPostType: "users/chatmessages"){ (response,responseCode,nil) in
                
                if responseCode!.intValue == 200
                {
                    let msgArray  = response?["result"] as? NSArray
                    if ((msgArray?.count)! > 0) {
                        self.saveOfflineSingleChatMessagesOfARoom(messages: msgArray!)
                    }
                }
                //end response success
            }
        }
    }
    
    func saveOfflineSingleChatMessagesOfARoom(messages : NSArray) {
        for i in (0..<messages.count).reversed() {
            
            if let offlineMsgDict = messages[i] as? [String:Any] {
                self.saveSingleOfflineMessage(msgDict: offlineMsgDict)
            }
        }
    }
    
    private func saveSingleOfflineMessage(msgDict : [String:Any]) {
        
        var firstName: String?
        var lastName: String?
        
        var msgObj : ChatMessage = ChatMessage()
        let messageDict = msgDict["chat_id"] as? [String: Any]
        appDelegate.roomId = messageDict?["room"] as? String ?? ""
        let message_id     = msgDict["_id"] as? String ?? ""
        let client_msg_id  = msgDict["client_msg_id"] as? String ?? ""
        let message        = msgDict["message"] as? String
        let time           = msgDict["created_at"] as? String
        
        // Get User Detail from User_id Dictionary
        let User_IdDict = msgDict["user_id"] as? [String: Any]
        let profileImg   = User_IdDict?["user_image"] as? String
        let user_id      = User_IdDict?["_id"] as? String
        if let f_Name = User_IdDict?["firstName"] as? String {
            firstName = f_Name
        }
        if let last_Name = User_IdDict?["lastName"] as? String {
            lastName = last_Name
        }
//        let firstName    = User_IdDict?["firstName"] as? String
//        let lastName     = User_IdDict?["lastName"] as? String
        let name  = "\(firstName) \(lastName)"
        
        var userinfo = [String: Any]()
        userinfo = ["name":name ,"profileImg": profileImg ?? "", "user_id": user_id ?? ""]
        messageid = message_id
        
        // Refresh room Dict
        var refreshRoomDict = [String: Any]()
        refreshRoomDict = ["client_msg_id":client_msg_id,"message":message ?? "","message_id":message_id, "room":appDelegate.roomId, "time":time ?? "", "userinfo":userinfo]
        
        msgObj = msgObj.setRecentMessageDetail(msgInfo: refreshRoomDict)
        
        if messageid == duplicatemessageid { return }
            
        else {
            Chat.sharedInstance.setChatHistoryInDatabase(message: msgObj)
            duplicatemessageid = messageid
        }
    }
    
    //End Socket class
}
*/
