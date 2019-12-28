//
//  EditUserProfileVC.swift
//  Intrigued
//
//  Created by daniel helled on 05/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import AWSS3
import AWSCore
import IQKeyboardManagerSwift

class EditUserProfileVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,LocationManagerDelegate,UITextFieldDelegate,UITextViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    @IBOutlet weak var editTbl_view: UITableView!
    var picker = UIImagePickerController()
    var uploadUrl = ""
    var flag = Bool()
    var firstName = ""
    var lastName = ""
    var phoneNumber = ""
    var user_address = ""
    var aboutyou = "Briefly tell us why you became a coach and what services you provide?"
    var aboutcategory = "Write here 500 character"
    var directMessage = ""
    var rushDirectMessage = ""
    var liveChat = ""
    
    var locationArray = NSArray()
    var isfromCoach = Bool()
    var categoryArray = NSMutableArray()
    var pricingArray = NSMutableArray()
    var BasicCategoryArray = NSMutableArray()
    var BasicPricingArray = NSMutableArray()
    var selectedIndex = 0
    var direct_Status = "0"
    var rush_direct_Status = "0"
    var livechat_Status = "0"
   var categoryCellName = ""
    
    var categoryNameArray = NSArray()
    var categoryImageArray = NSArray()
    var catHighImageArray = NSArray()
    
    var categoryModelArray = NSMutableArray()
    var CoachPriceModelArray = NSMutableArray()
    
    var priceArray = NSMutableArray()
    var directMsg = NSMutableArray()
    var rushDelivery = NSMutableArray()
    var liveChat1 = NSMutableArray()
    var activeField : UITextField!
    var pickerView = UIPickerView()
//    var CategoryCollectionView = UICollectionView()
//    let flowLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    
    let CategoryCollectionView:UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
    let flowLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
      self.SetUpBasicDetails()
        
        if isCoach() {
            self.getServiceTax(type: k_GET_COACH_SERVICE_TAX)
        }else {
            self.getServiceTax(type: k_GET_USER_SERVICE_TAX)
        }
      

    }
    func getServiceTax(type:String) {
        
        
        let requestDict =   NSDictionary()
        print(requestDict)
        showProgressIndicator(refrenceView: self.view)
        WebServices().mainFunctiontoGetDetails(data: requestDict,serviceType:type) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    if let resultDict = responseData?["result"] as? NSDictionary {
                        
                        CloseChatDays = resultDict["close_chat"] as? String ?? ""
                        ServiceTaxValue = resultDict["service_tax"] as? String ?? ""
                       
                    }
                }
            }
            else{
                stopProgressIndicator()
            }
        }
    }
    
    func SetUpBasicDetails()  {
        
        self.BasicPricingArray = getPricingList() as! NSMutableArray
        print(self.BasicPricingArray)
        
        registerCellNib()
        self.editTbl_view.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0);
        
        if isfromCoach {
            self.showCoachPofileDetials()
        }
        else{
            showUserPofileDetials()
        }
        
        pickerView.delegate = self
        pickerView.dataSource  = self
        
        
        priceArray = directMsg
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        self.createCategoryArray()
        self.createCoachPricingArray()
        
        
        var limit_Dircect =   Double()
        var limit_RushDirect = Double()
        var limit_LiveChat = Double()
        var Start_LiveChat = Double()
        var Start_Direct = Double()
        var Start_RushDirect = Double()
        
        for item in self.BasicPricingArray {
            
            let dict = item as! NSDictionary
            
            if dict["service_name"] as! String == "Direct price" {
                limit_Dircect = Double(dict["end_price"] as! String )!
                Start_Direct =  Double(dict["start_price"] as! String)!
            }else if dict["service_name"] as! String == "Rush direct price" {
                limit_RushDirect = Double(dict["end_price"] as! String)!
                Start_RushDirect = Double(dict["start_price"] as! String)!
            }else if dict["service_name"] as! String == "Live chat price" {
                limit_LiveChat = Double(dict["end_price"] as! String)!
                Start_LiveChat = Double(dict["start_price"] as! String)!
            }
        }
        let interval = 1.0
        print(Start_LiveChat, limit_LiveChat, Start_RushDirect, limit_RushDirect, Start_Direct, limit_Dircect )
        
        //  let interval = 1.0
        for rangeArray in stride(from: Start_Direct, through: limit_Dircect, by: interval) {
            directMsg.add(rangeArray)
        }
        for rangeArray in stride(from: Start_RushDirect, through: limit_RushDirect, by: interval) {
            rushDelivery.add(rangeArray)
        }
        for rangeArray in stride(from: Start_LiveChat, through: limit_LiveChat, by: interval) {
            liveChat1.add(rangeArray)
        }
        self.editTbl_view.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        
        let space = 5.0 as CGFloat
        
        // Set view cell size
        flowLayout.itemSize = CGSize(width: 110, height: 110)
        
        // Set left and right margins
        flowLayout.minimumInteritemSpacing = space
        
        // Set top and bottom margins
        flowLayout.minimumLineSpacing = space
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        CategoryCollectionView.setCollectionViewLayout(flowLayout, animated: true)
        CategoryCollectionView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width , height: 100)
        CategoryCollectionView.delegate = self
        CategoryCollectionView.dataSource = self
        CategoryCollectionView.register(UINib(nibName: "CategoryCollectionCell", bundle:nil), forCellWithReuseIdentifier: "CategoryCollectionCell")
        CategoryCollectionView.backgroundColor = UIColor.clear
    }
    

    
    func createCategoryArray() {
        categoryNameArray = ["Single","New Relationship","Long Term" ]
        categoryImageArray = ["tarot_reading_unselect","psychic_reading_unsel", "relationship_reading_unselect"]
        catHighImageArray = ["tarot_reading_select","psychic_reading_sel","relationship_reading_select"]
        
        
        self.BasicCategoryArray = getCategoryList() as! NSMutableArray
        print(self.BasicCategoryArray)
       
        for dictCatDetail in self.BasicCategoryArray {
          
            let catDetail = dictCatDetail as! NSDictionary
            var catModel =  CategoryModel.init() as CategoryModel
            catModel.categoryName =       catDetail["name"] as! NSString
            catModel.CatSelectedImgName =  catDetail["catColorImage"] as! NSString
            catModel.CatUnSelectedImgName = catDetail["catSimpleImage"] as! NSString
            catModel.CatSelectedStatus = "NO"
              categoryModelArray.add(catModel)
            if categoryArray.contains(catDetail["name"] as! NSString) {
                catModel.CatSelectedStatus = "YES"
            }
        }
        
        print(categoryModelArray.count)
        print(categoryModelArray)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeField = textField
        let tag = textField.tag

        print(tag)
        
        if tag == 1000 || tag == 2000 || tag == 3000 || tag == 4000 {
            
        }else {
        var text  = activeField.text as! String

        if text == "$0.00" {
             self.pickerView.selectRow(0, inComponent: 0, animated: true)
            if tag == 0 {
                let str:String = "$" + String(describing: directMsg[0])
                PricingDictManage["DirectPricing"] = str
                print(PricingDictManage)
                
                weak var PriceModel1 = CoachPriceModelArray.object(at:  activeField.tag) as! CoachPricingModel
                var status1 =  PriceModel1?.coachPriceStatus as! String
                
                if status1 == "YES" {
                    PriceModel1?.coachPrice = str as NSString
                    let indexPath = IndexPath(row:activeField.tag , section: 4)
                    let cell = self.editTbl_view.cellForRow(at: indexPath) as! PricingSignUpTblCell
                    cell.priceTxtFld.text = str
                    //  self.editTbl_view.reloadRows(at: [IndexPath(row: activeField.tag, section: 3)], with: .none)
                    
                }
            //   activeField.text =  String(describing: directMsg[0])
            }else if tag == 1 {
                let str:String = "$" + String(describing: rushDelivery[0])
                PricingDictManage["RushDirectPricing"] = str
                print(PricingDictManage)
                
                weak var PriceModel2 = CoachPriceModelArray.object(at:  activeField.tag) as! CoachPricingModel
                var status2 =  PriceModel2?.coachPriceStatus as! String
                
                if status2 == "YES" {
                    PriceModel2?.coachPrice = str as NSString
                    let indexPath = IndexPath(row:activeField.tag , section: 4)
                    let cell = self.editTbl_view.cellForRow(at: indexPath) as! PricingSignUpTblCell
                    cell.priceTxtFld.text = str
                    //      self.editTbl_view.reloadRows(at: [IndexPath(row: activeField.tag, section: 3)], with: .none)
                    
                }
             //    activeField.text =  String(describing: rushDelivery[0])
            }else if tag == 2 {
                
                let str:String = "$" + String(describing: liveChat1[0])
                PricingDictManage["LiveChatPricing"] = str
                print(PricingDictManage)
                
                weak var PriceModel3 = CoachPriceModelArray.object(at:  activeField.tag) as! CoachPricingModel
                var status3 =  PriceModel3?.coachPriceStatus as! String
                
                if status3 == "YES" {
                    PriceModel3?.coachPrice = str as NSString
                    let indexPath = IndexPath(row:activeField.tag , section: 4)
                    let cell = self.editTbl_view.cellForRow(at: indexPath) as! PricingSignUpTblCell
                    cell.priceTxtFld.text = str
                    //       self.editTbl_view.reloadRows(at: [IndexPath(row: activeField.tag, section: 3)], with: .none)
                    
                }
            //     activeField.text =  String(describing: liveChat1[0])
            }
        }else {
            let result1 = String(text.dropFirst()) as String
            print(result1)
            
            var indexOfA: Int?
            print(indexOfA)
            
            if tag == 0 {
                for (index, element ) in directMsg.enumerated() {
                    let priceStr1 = String(describing: directMsg[index])
                    if priceStr1 == result1 {
                        indexOfA = index
                        print(indexOfA)
                        break
                        
                    }
                }
            }else if tag == 1 {
                for (index, element ) in rushDelivery.enumerated() {
                    let priceStr1 = String(describing: rushDelivery[index])
                    if priceStr1 == result1 {
                        indexOfA = index
                        print(indexOfA)
                        break
                        
                    }
                }
            }else if tag == 2 {
                for (index, element ) in liveChat1.enumerated() {
                    let priceStr1 = String(describing: liveChat1[index])
                    if priceStr1 == result1 {
                        indexOfA = index
                        print(indexOfA)
                        break
                        
                    }
                }
            }
            
            
            print(indexOfA)
            
            self.pickerView.reloadAllComponents()
            self.pickerView.selectRow(indexOfA!, inComponent: 0, animated: true)
        }
        
     

        //        switch textField.tag
        //        {
        //        case 0:
        //            priceArray = directMsg
        //            break;
        //        case 1:
        //            priceArray = rushDelivery
        //            break;
        //        case 2:
        //             priceArray = liveChat
        //            break;
        //        default:
        //            // do nothing
        //            break;
        //        }
    }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if activeField.tag == 0 {
            return directMsg.count
        }
        else if activeField.tag == 1 {
            return rushDelivery.count
        }
        else{
            return liveChat1.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if activeField.tag == 0 {
            let priceStr = String(describing: directMsg[row])
            return "$" + priceStr
        }
        else if activeField.tag == 1 {
            let priceStr = String(describing: rushDelivery[row])
            return "$" + priceStr
        }
        else{
            let priceStr = String(describing: liveChat1[row])
            return "$" + priceStr
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if activeField.tag == 0 {
            
            
            let str:String = "$" + String(describing: directMsg[row])
            PricingDictManage["DirectPricing"] = str
            print(PricingDictManage)
            
            weak var PriceModel1 = CoachPriceModelArray.object(at:  activeField.tag) as! CoachPricingModel
            var status1 =  PriceModel1?.coachPriceStatus as! String
            
            if status1 == "YES" {
                PriceModel1?.coachPrice = str as NSString
                let indexPath = IndexPath(row:activeField.tag , section: 4)
                let cell = self.editTbl_view.cellForRow(at: indexPath) as! PricingSignUpTblCell
                cell.priceTxtFld.text = str
              //  self.editTbl_view.reloadRows(at: [IndexPath(row: activeField.tag, section: 3)], with: .none)
                
            }
            
            //    tf_Price.text = PricingDictManage["DirectPricing"]
        }
        else if activeField.tag == 1 {
            
            let str:String = "$" + String(describing: rushDelivery[row])
            PricingDictManage["RushDirectPricing"] = str
            print(PricingDictManage)
            
            weak var PriceModel2 = CoachPriceModelArray.object(at:  activeField.tag) as! CoachPricingModel
            var status2 =  PriceModel2?.coachPriceStatus as! String
            
            if status2 == "YES" {
                PriceModel2?.coachPrice = str as NSString
                let indexPath = IndexPath(row:activeField.tag , section: 4)
                let cell = self.editTbl_view.cellForRow(at: indexPath) as! PricingSignUpTblCell
                cell.priceTxtFld.text = str
          //      self.editTbl_view.reloadRows(at: [IndexPath(row: activeField.tag, section: 3)], with: .none)
                
            }
            //   tf_Price.text = PricingDictManage["RushDirectPricing"]
        }
        else{
            
            let str:String = "$" + String(describing: liveChat1[row])
            PricingDictManage["LiveChatPricing"] = str
            print(PricingDictManage)
            
            weak var PriceModel3 = CoachPriceModelArray.object(at:  activeField.tag) as! CoachPricingModel
            var status3 =  PriceModel3?.coachPriceStatus as! String
            
            if status3 == "YES" {
                PriceModel3?.coachPrice = str as NSString
                let indexPath = IndexPath(row:activeField.tag , section: 4)
                let cell = self.editTbl_view.cellForRow(at: indexPath) as! PricingSignUpTblCell
                cell.priceTxtFld.text = str
         //       self.editTbl_view.reloadRows(at: [IndexPath(row: activeField.tag, section: 3)], with: .none)
                
            }
            //   tf_Price.text = PricingDictManage["LiveChatPricing"]
        }
    }
    
    func managePrice(tagValue : Int) {
        selectedIndex = tagValue
        if selectedIndex == 0 {
            
            weak var PriceModel1 = CoachPriceModelArray.object(at: 0) as! CoachPricingModel
            var status1 =  PriceModel1?.coachPriceStatus as! String
            
            if status1 == "YES" {
                PriceModel1?.coachPriceStatus = "NO"
                PriceModel1?.coachPrice = "$0.00"
                self.editTbl_view.reloadRows(at: [IndexPath(row: selectedIndex, section: 4)], with: .none)
                
                
            }else if status1 == "NO" {
                PriceModel1?.coachPriceStatus = "YES"
                self.editTbl_view.reloadRows(at: [IndexPath(row: selectedIndex, section: 4)], with: .none)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let indexPath = IndexPath(row:self.selectedIndex , section: 4)
                    let cell = self.editTbl_view.cellForRow(at: indexPath) as! PricingSignUpTblCell
                    cell.priceTxtFld.becomeFirstResponder()
                }
                
                
                
            }
            
            
        }else  if selectedIndex == 1 {
            
            weak var PriceModel2 = CoachPriceModelArray.object(at: 1) as! CoachPricingModel
            var status2 =  PriceModel2?.coachPriceStatus as! String
            
            if status2 == "YES" {
                PriceModel2?.coachPriceStatus = "NO"
                PriceModel2?.coachPrice = "$0.00"
                self.editTbl_view.reloadRows(at: [IndexPath(row: selectedIndex, section: 4)], with: .none)
                
            }else if status2 == "NO" {
                PriceModel2?.coachPriceStatus = "YES"
                self.editTbl_view.reloadRows(at: [IndexPath(row: selectedIndex, section: 4)], with: .none)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let indexPath = IndexPath(row:self.selectedIndex , section: 4)
                    let cell = self.editTbl_view.cellForRow(at: indexPath) as! PricingSignUpTblCell
                    cell.priceTxtFld.becomeFirstResponder()
                }
            }
            
        }else if selectedIndex == 2 {
            
            weak var PriceModel3 = CoachPriceModelArray.object(at: 2) as! CoachPricingModel
            var status3 =  PriceModel3?.coachPriceStatus as! String
            
            if status3 == "YES" {
                PriceModel3?.coachPriceStatus = "NO"
                PriceModel3?.coachPrice = "$0.00"
                self.editTbl_view.reloadRows(at: [IndexPath(row: selectedIndex, section: 4)], with: .none)
                
            }else if status3 == "NO" {
                PriceModel3?.coachPriceStatus = "YES"
                self.editTbl_view.reloadRows(at: [IndexPath(row: selectedIndex, section: 4)], with: .none)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let indexPath = IndexPath(row:self.selectedIndex , section: 4)
                    let cell = self.editTbl_view.cellForRow(at: indexPath) as! PricingSignUpTblCell
                    cell.priceTxtFld.becomeFirstResponder()
                }
            }
            
        }
    }
//    @objc func handlePricing(sender: UIButton){
//        selectedIndex = sender.tag
//        if selectedIndex == 0 {
//
//            weak var PriceModel1 = CoachPriceModelArray.object(at: 0) as! CoachPricingModel
//            var status1 =  PriceModel1?.coachPriceStatus as! String
//
//            if status1 == "YES" {
//                PriceModel1?.coachPriceStatus = "NO"
//                  PriceModel1?.coachPrice = "$0.00"
//                self.editTbl_view.reloadRows(at: [IndexPath(row: selectedIndex, section: 4)], with: .none)
//
//
//            }else if status1 == "NO" {
//                PriceModel1?.coachPriceStatus = "YES"
//                self.editTbl_view.reloadRows(at: [IndexPath(row: selectedIndex, section: 4)], with: .none)
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    let indexPath = IndexPath(row:self.selectedIndex , section: 4)
//                    let cell = self.editTbl_view.cellForRow(at: indexPath) as! PricingSignUpTblCell
//                    cell.priceTxtFld.becomeFirstResponder()
//                }
//
//
//
//            }
//
//
//        }else  if selectedIndex == 1 {
//
//            weak var PriceModel2 = CoachPriceModelArray.object(at: 1) as! CoachPricingModel
//            var status2 =  PriceModel2?.coachPriceStatus as! String
//
//            if status2 == "YES" {
//                PriceModel2?.coachPriceStatus = "NO"
//                 PriceModel2?.coachPrice = "$0.00"
//                self.editTbl_view.reloadRows(at: [IndexPath(row: selectedIndex, section: 4)], with: .none)
//
//            }else if status2 == "NO" {
//                PriceModel2?.coachPriceStatus = "YES"
//                self.editTbl_view.reloadRows(at: [IndexPath(row: selectedIndex, section: 4)], with: .none)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    let indexPath = IndexPath(row:self.selectedIndex , section: 4)
//                    let cell = self.editTbl_view.cellForRow(at: indexPath) as! PricingSignUpTblCell
//                    cell.priceTxtFld.becomeFirstResponder()
//                }
//            }
//
//        }else if selectedIndex == 2 {
//
//            weak var PriceModel3 = CoachPriceModelArray.object(at: 2) as! CoachPricingModel
//            var status3 =  PriceModel3?.coachPriceStatus as! String
//
//            if status3 == "YES" {
//                PriceModel3?.coachPriceStatus = "NO"
//                PriceModel3?.coachPrice = "$0.00"
//                self.editTbl_view.reloadRows(at: [IndexPath(row: selectedIndex, section: 4)], with: .none)
//
//            }else if status3 == "NO" {
//                PriceModel3?.coachPriceStatus = "YES"
//                self.editTbl_view.reloadRows(at: [IndexPath(row: selectedIndex, section: 4)], with: .none)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    let indexPath = IndexPath(row:self.selectedIndex , section: 4)
//                    let cell = self.editTbl_view.cellForRow(at: indexPath) as! PricingSignUpTblCell
//                    cell.priceTxtFld.becomeFirstResponder()
//                }
//            }
//
//        }
//    }
    func createCoachPricingArray() {
        
        var PriceModel1 =  CoachPricingModel.init() as CoachPricingModel
        PriceModel1.coachPriceType = "Direct Message"
        PriceModel1.coachPrice = "$0.00"
        PriceModel1.coachPriceStatus = "NO"
        print(PriceModel1)
        
        var PriceModel2 =  CoachPricingModel.init() as CoachPricingModel
        PriceModel2.coachPriceType = "Rush Direct Message"
        PriceModel2.coachPrice = "$0.00"
        PriceModel2.coachPriceStatus = "NO"
        print(PriceModel2)
        
        var PriceModel3 =  CoachPricingModel.init() as CoachPricingModel
        PriceModel3.coachPriceType = "Live Chat"
        PriceModel3.coachPrice = "$0.00"
        PriceModel3.coachPriceStatus = "NO"
        print(PriceModel3)
        
        print(self.pricingArray)
        
        
        if direct_Status == "1" {
            
            PriceModel1.coachPriceStatus = "YES"
            PriceModel1.coachPrice = directMessage  as NSString
        }
        
        if rush_direct_Status == "1" {
            PriceModel2.coachPriceStatus = "YES"
            PriceModel2.coachPrice = rushDirectMessage as NSString
        }
        
        if livechat_Status == "1" {
            PriceModel3.coachPriceStatus = "YES"
            PriceModel3.coachPrice = liveChat as NSString
        }
        
        CoachPriceModelArray.insert(PriceModel1, at: 0)
        CoachPriceModelArray.insert(PriceModel2, at: 1)
        CoachPriceModelArray.insert(PriceModel3, at: 2)
        print(CoachPriceModelArray.count)
        print(CoachPriceModelArray)
        
        
    }
    
    
    @objc func DoneBtnPressed(_ sender: UIButton) {
       
        
        
        var ServiceTaxPercent =  ServiceTaxValue as? String ?? ""
        
        //    intrigued has a 25% fee.  Your actual rate will be $2.42”
        var Price = ""
        weak var PriceModel = self.CoachPriceModelArray.object(at:  sender.tag) as! CoachPricingModel
        Price =  PriceModel?.coachPrice as! String
        print(Price)
        Price.remove(at: Price.startIndex)
        print(Price)
        var priceValue = Double(Price)
        var serviceTaxValue = Double(ServiceTaxPercent)
        priceValue = priceValue! - ((priceValue! * serviceTaxValue! )/100 )
        print(priceValue)
        ServiceTaxPercent = ServiceTaxPercent + "%"
        let   messageStr =      String(format:"Intrigued has a %@ fee. Your actual rate will be $%3.2f,           after Intrigued’s Service Costs.",ServiceTaxPercent, priceValue!)
        
        let alertView = UIAlertController(title: "Service Tax",
                                          message: messageStr,
                                          preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            print("TouchID not available")
            
          
        }))
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            print("TouchID not available")
            
            if sender.tag == 0
            {
                weak var PriceModel1 = self.CoachPriceModelArray.object(at:  sender.tag) as! CoachPricingModel
                var status1 =  PriceModel1?.coachPriceStatus as! String
                
                
                if status1 == "YES" {
                    PriceModel1?.coachPrice = "$0.00"
                    PriceModel1?.coachPriceStatus = "NO"
                    
                } else if status1 == "NO" {
                    
                }
            } else if sender.tag == 1 {
                weak var PriceModel2 = self.CoachPriceModelArray.object(at:  sender.tag) as! CoachPricingModel
                
                var status2 =  PriceModel2?.coachPriceStatus as! String
                
                if status2 == "YES" {
                    PriceModel2?.coachPrice = "$0.00"
                    PriceModel2?.coachPriceStatus = "NO"
                } else if status2 == "NO" {
                    
                }
            } else if sender.tag == 2 {
                weak var PriceModel3 = self.CoachPriceModelArray.object(at:  sender.tag) as! CoachPricingModel
                var status3 =  PriceModel3?.coachPriceStatus as! String
                
                if status3 == "YES" {
                    PriceModel3?.coachPrice = "$0.00"
                    PriceModel3?.coachPriceStatus = "NO"
                    
                } else if status3 == "NO" {
                    
                }
            }
            
              self.editTbl_view.reloadRows(at: [IndexPath(row: sender.tag, section: 4)], with: .none)
        }))
        
        present(alertView, animated: true, completion: nil)
    }
    
    func showCoachPofileDetials() {
        
        print(self.categoryArray)
        print(locationArray)
        self.categoryArray = getCategoryArray() as! NSMutableArray
        self.locationArray = getLocationPoint()
        print(self.categoryArray)
        print(locationArray)
        firstName = getFirstName()
        lastName = getLastName()
        phoneNumber = getPhoneNo()
        uploadUrl = getProfilePic()
        user_address = getAddress()
        locationArray = getLocationPoint()
        aboutyou = getAboutDetail()
        aboutcategory = getAbout_services()
        directMessage = getDirectPrice()
        rushDirectMessage = getRushDirectPrice()
        liveChat = getLiveChatPrice()
        if getDirect_Status() == 1 {
            pricingArray.add(0)
            direct_Status = "1"
        }
        
        if getRushDirect_Status() == 1 {
            pricingArray.add(1)
            rush_direct_Status = "1"
        }
        if getlivechat_Status() == 1 {
            pricingArray.add(2)
            livechat_Status = "1"
        }
        print("pricingArray",pricingArray)
    }
    func showUserPofileDetials() {
        
        
        firstName = getFirstName()
        lastName = getLastName()
        phoneNumber = getPhoneNo()
        uploadUrl = getProfilePic()
        user_address = getAddress()
        locationArray = getLocationPoint()
        
    }
    func registerCellNib() {
        if isfromCoach {
            editTbl_view.register(UINib(nibName: "CoachesSignUpCell", bundle: nil), forCellReuseIdentifier: "CoachesSignUpCell")
            editTbl_view.register(UINib(nibName: "CoachesCategoryCell", bundle: nil), forCellReuseIdentifier: "CoachesCategoryCell")
            editTbl_view.register(UINib(nibName: "CoachesPricingCell", bundle: nil), forCellReuseIdentifier: "CoachesPricingCell")
            editTbl_view.register(UINib(nibName: "CoachesAddAboutCell", bundle: nil), forCellReuseIdentifier: "CoachesAddAboutCell")
            editTbl_view.register(UINib(nibName: "AddUserAddressCell", bundle: nil), forCellReuseIdentifier: "AddUserAddressCell")
             editTbl_view.register(UINib(nibName: "EditIntroVideo", bundle: nil), forCellReuseIdentifier: "EditIntroVideo")
            categoryCellName = "Category"
            self.editTbl_view.register(UITableViewCell.self, forCellReuseIdentifier: categoryCellName)
            self.editTbl_view.register(UINib(nibName: "PricingSignUpTblCell", bundle: nil), forCellReuseIdentifier: "PricingSignUpTblCell")
        }
        else {
             editTbl_view.register(UINib(nibName: "CoachesSignUpCell", bundle: nil), forCellReuseIdentifier: "CoachesSignUpCell")
            editTbl_view.register(UINib(nibName: "AddUserAddressCell", bundle: nil), forCellReuseIdentifier: "AddUserAddressCell")
            editTbl_view.isScrollEnabled = false
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        let currentString: NSString = textView.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: text) as NSString
        if textView.tag == 2 {
            if newString.length <= 500
            {
                 return newString.length <= 500
            }else {
                textView.resignFirstResponder()
                notifyUser("Alert", message: "Maximum 500 characters for About yourself allowed.", vc: self)
                 return newString.length <= 500
            }
           
     
            
        }
        else{
            return newString.length <= 500
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        print(textView.tag)
        if textView.tag == 2 {
            if (textView.text == "Briefly tell us why you became a coach and what services you provide?"){
                textView.text = ""
                textView.textColor = .black
            }
        }
        else  if textView.tag == 3 {
            if (textView.text == "Write here 500 character"){
                textView.text = ""
                textView.textColor = .black
            }
        }
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == ""){
            if textView.tag == 2 {
                textView.text = "Briefly tell us why you became a coach and what services you provide?"
            }
            else{
                textView.text = "Write here 500 character"
            }
            textView.textColor = .lightGray
        }
        if textView.tag == 2 {
            aboutyou = textView.text
        }
        else{
            aboutcategory = textView.text
        }
        textView.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with:string) as NSString
        if textField.tag == 4000 {
            return newString.length <= 10
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField){
        
        
        
        
        switch textField.tag
        {
        case 1000:
            firstName = textField.text ?? ""
            break;
        case 2000:
            lastName = textField.text ?? ""
            break;
        case 4000:
            phoneNumber = textField.text ?? ""
            break;
        default:
            // do nothing
            break;
        }
    }
   
    
   
  
   //MARK:*********** UIButton Action *************
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func updateProfileDetailsAction(_ sender: Any) {
        if isfromCoach {
            
             categoryArray.removeAllObjects()
             for catModel in self.categoryModelArray {
                
                let catModelDetail = catModel as! CategoryModel
                let status =  catModelDetail.CatSelectedStatus as String
                let CatName = catModelDetail.categoryName as String
                
                if status == "YES" {
                    
                    categoryArray.add(CatName)
                    
                }else if status == "NO" {
                    
                }
                
            }
            
            
            let PriceModel1 = CoachPriceModelArray.object(at: 0) as! CoachPricingModel
            let PriceModel2 = CoachPriceModelArray.object(at: 1) as! CoachPricingModel
            let PriceModel3 = CoachPriceModelArray.object(at: 2) as! CoachPricingModel
            
            let Pricestatus1 =  PriceModel1.coachPriceStatus as String
            let Pricestatus2 =  PriceModel2.coachPriceStatus as String
            let Pricestatus3 =  PriceModel3.coachPriceStatus as String
            
          
            
            if Pricestatus1 == "YES" {
                
                direct_Status = "1"
                directMessage = PriceModel1.coachPrice as String
                
            }else if Pricestatus1 == "NO" {
                direct_Status = "0"
                directMessage = "$0.00"
            }
            if Pricestatus2 == "YES" {
                rush_direct_Status = "1"
                rushDirectMessage = PriceModel2.coachPrice as String
            }else if Pricestatus2 == "NO" {
                rush_direct_Status = "0"
                rushDirectMessage = "$0.00"
            }
            if Pricestatus3 == "YES" {
                livechat_Status = "1"
                liveChat = PriceModel3.coachPrice as String
            }else if Pricestatus3 == "NO" {
                livechat_Status = "0"
                liveChat = "$0.00"
            }
            
            
            if ischeckCoachesManadoryDetails() {
//                rushDirectMessage = PricingDictManage["RushDirectPricing"] as! String
//                 liveChat = PricingDictManage["LiveChatPricing"] as! String
//                 directMessage = PricingDictManage["DirectPricing"] as! String
                
                
                let videoUrl = getIntroVideoUrl()
                let videoThumbUrl = getVideoThumbUrl()
            
                let request = ["user_id": getUserId(),"fname": firstName, "lname":lastName, "address":user_address ,"longlat":locationArray, "phone_no":phoneNumber, "profile_pic":uploadUrl ,"about_services": aboutcategory,"about":aboutyou, "categories":categoryArray,"direct_price":directMessage,
                    "rush_direct_price":rushDirectMessage,
                    "livechat_price":liveChat,"direct_Status":direct_Status,
                    "rush_direct_Status":rush_direct_Status,
                    "livechat_Status":livechat_Status,
                    "coach_video":videoUrl,
                    "coach_video_thumb":videoThumbUrl] as [String : Any]
                print(request)
                    self.updateUser_CoachesDetails(request: request as NSDictionary, type: kUPDATE_COACH_DETAILS)
            }
        }
        else {
            if ischeckManadoryDetails() {
                let token = UserDefaults.standard.object(forKey: "deviceToken")
                let userDeviceArray = ["deviceToken": token ?? "","deviceId": appDelegateDeviceId.deviceId ?? "","deviceType": "I"] as [String : Any]
                
                 let request = ["user_id": getUserId(), "fname": firstName, "lname":lastName, "address":user_address ,"longlat":locationArray, "phone_no":phoneNumber , "profile_pic":uploadUrl,"user_devices":[userDeviceArray]] as [String : Any]
                self.updateUser_CoachesDetails(request: request as NSDictionary, type: kUPDATE_USER_DETAILS)
            }
        }
    }
    
    @objc func selectAddressBtnAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectAddressVC") as! SelectAddressVC
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func EditIntroductionideoBtnAction(_ sender: Any) {
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoCameraVc") as! VideoCameraVc
            self.navigationController?.pushViewController(vc, animated: true)
            
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CustomCameraNew") as! CustomCameraNew
//            self.navigationController?.pushViewController(vc, animated: true)

//                    let nextViewController: CustomCameraVC = CustomCameraVC(nibName: "CustomCameraVC", bundle: nil)
//                    self.navigationController?.pushViewController(nextViewController, animated: true)
//
            
        }else{
            notifyUser("", message: "Your device doesn't support camera", vc: self)
        }
    }
    
    @objc func changeProfilePicAcion(_ sender: Any) {
        let actionSheetController = UIAlertController(title: "Choose Image", message:nil , preferredStyle: .actionSheet)
        
        // actionSheetController.view.tintColor = UIColor.headerBlue
        
        let galleryButton = UIAlertAction(title: "Gallery", style: .default) { action -> Void in
            self.openGallary()
        }
        let cameraButton = UIAlertAction(title: "Camera", style: .default) { action -> Void in
            self.openCamera()
        }
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            
        }
        picker.delegate = self
        cancelActionButton.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheetController.addAction(galleryButton)
        actionSheetController.addAction(cameraButton)
        actionSheetController.addAction(cancelActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker.sourceType = UIImagePickerControllerSourceType.camera
            self .present(picker, animated: true, completion: nil)
        }else{
            notifyUser("", message: "Your device doesn't support camera", vc: self)
        }
    }
    
    func openGallary(){
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    //MARK:UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        flag = true
        picker .dismiss(animated: true, completion: nil)
        let infoindexPath = IndexPath(row: 0, section: 0)
        if let cell = editTbl_view.cellForRow(at: infoindexPath) as? CoachesSignUpCell {
            cell.userImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
                cell.userImage.isHidden = false
                cell.userNameProfileLbl.isHidden = true
            
            
        }
        var image = info[UIImagePickerControllerOriginalImage] as? UIImage //userProfileImage.image
        image = image?.resizeWithWidth(width: 200)!
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(String(describing: image)).jpeg")
        let imageData = UIImageJPEGRepresentation(image!, 0.5)
        let imageSize: Int = imageData!.count
        print("size of image in KB: %f ", Double(imageSize) / 1024.0)
        fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
        let fileUrl = URL(fileURLWithPath: path)
     
       showProgressIndicator(refrenceView: self.view)
        WebServices().uploadImageonServer(imageURL: fileUrl){ (responseData)  in
            stopProgressIndicator()
            if responseData != nil{
                self.uploadUrl = responseData!
                print("responseData",responseData ?? "")
                if self.isfromCoach {
                    
                    self.categoryArray.removeAllObjects()
                    for catModel in self.categoryModelArray {
                        
                        var catModelDetail = catModel as! CategoryModel
                        var status =  catModelDetail.CatSelectedStatus as String
                        var CatName = catModelDetail.categoryName as String
                        
                        if status == "YES" {
                            
                            self.categoryArray.add(CatName)
                            
                        }else if status == "NO" {
                            
                        }
                        
                    }
                    
//                    var catModel1 = self.categoryModelArray.object(at: 0) as! CategoryModel
//                    var catModel2 = self.categoryModelArray.object(at: 1) as! CategoryModel
//                    var catModel3 = self.categoryModelArray.object(at: 2) as! CategoryModel
//
//                    var status1 =  catModel1.CatSelectedStatus as String
//                    var status2 =  catModel2.CatSelectedStatus as String
//                    var status3 =  catModel3.CatSelectedStatus as String
//
//                    var CatName1 = catModel1.categoryName as String
//                    var CatName2 = catModel2.categoryName as String
//                    var CatName3 = catModel3.categoryName as String
//
//                    self.categoryArray.removeAllObjects()
//                    if status1 == "YES" {
//
//                        self.categoryArray.add(CatName1)
//
//                    }else if status1 == "NO" {
//
//                    }
//                    if status2 == "YES" {
//                        self.categoryArray.add(CatName2)
//                    }else if status2 == "NO" {
//
//                    }
//                    if status3 == "YES" {
//                        self.categoryArray.add(CatName3)
//                    }else if status3 == "NO" {
//
//                    }
//
                    
                    let PriceModel1 = self.CoachPriceModelArray.object(at: 0) as! CoachPricingModel
                    let PriceModel2 = self.CoachPriceModelArray.object(at: 1) as! CoachPricingModel
                    let PriceModel3 = self.CoachPriceModelArray.object(at: 2) as! CoachPricingModel
                    
                    let Pricestatus1 =  PriceModel1.coachPriceStatus as String
                    let Pricestatus2 =  PriceModel2.coachPriceStatus as String
                    let Pricestatus3 =  PriceModel3.coachPriceStatus as String
                    
                    
                    
                    if Pricestatus1 == "YES" {
                        
                        self.direct_Status = "1"
                        self.directMessage = PriceModel1.coachPrice as String
                        
                    }else if Pricestatus1 == "NO" {
                        self.direct_Status = "0"
                        self.directMessage = "$0.00"
                    }
                    if Pricestatus2 == "YES" {
                        self.rush_direct_Status = "1"
                        self.rushDirectMessage = PriceModel2.coachPrice as String
                    }else if Pricestatus2 == "NO" {
                        self.rush_direct_Status = "0"
                        self.rushDirectMessage = "$0.00"
                    }
                    if Pricestatus3 == "YES" {
                        self.livechat_Status = "1"
                        self.liveChat = PriceModel3.coachPrice as String
                    }else if Pricestatus3 == "NO" {
                        self.livechat_Status = "0"
                        self.liveChat = "$0.00"
                    }
                    

                    print(self.categoryArray)
                    print(self.locationArray)
                    print(self.uploadUrl)
                    self.uploadUrl = responseData!
                    let videoUrl = getIntroVideoUrl()
                    let videoThumbUrl = getVideoThumbUrl()
                    
                    let request = ["user_id": getUserId(),
                                   "fname": self.firstName,
                                   "lname":self.lastName,
                                   "address":self.user_address ,
                                   "longlat":self.locationArray,
                                   "phone_no":self.phoneNumber,
                                   "profile_pic": self.uploadUrl ,
                                   "about_services": self.aboutcategory,
                                   "about":self.aboutyou,
                                   "categories":self.categoryArray,
                                   "direct_price":self.directMessage,
                                   "rush_direct_price":self.rushDirectMessage,
                                   "livechat_price":self.liveChat,
                                   "direct_Status":self.direct_Status,
                                   "rush_direct_Status":self.rush_direct_Status,
                                   "livechat_Status":self.livechat_Status,
                                   "coach_video":videoUrl,
                                   "coach_video_thumb":videoThumbUrl] as [String : Any]
                    
                 
                   
                        self.updateUserProfilePic(request: request as NSDictionary, type: kUPDATE_COACH_DETAILS)
                //    }
                }
                else {
                //    if ischeckManadoryDetails() {
                    let request = ["user_id": getUserId(), "fname": self.firstName, "lname":self.lastName, "address":self.user_address ,"longlat":self.locationArray, "phone_no":self.phoneNumber , "profile_pic":self.uploadUrl] as [String : Any]
                        self.updateUserProfilePic(request: request as NSDictionary, type: kUPDATE_USER_DETAILS)
                 //   }
                }
                
             }
            else{ stopProgressIndicator()}
            }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        print("picker cancel.")
        picker .dismiss(animated: true, completion: nil)
    }
    
    func updateUserProfilePic(request:NSDictionary,type:String)  {
        
      
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:type) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    
                    guard let resultDict = responseData?["result"] as? NSDictionary else {
                        return
                    }
                    removeUserDetails()
                    saveUserDetails(userDict: resultDict)
                    if isCoach(){
                        var arrayOfController = self.navigationController?.viewControllers
                        for (index, item) in (arrayOfController?.enumerated())! {
                            if  let controller = item as? CoachesTabbarVC {
                                var arrayOfController1 = controller.viewControllers
                                for (index1, item1) in (arrayOfController1?.enumerated())! {
                                    if  let controller = item1 as? CoachesProfileVC {
                                        controller.viewDidLoad()
                                        controller.viewWillAppear(true)
                                    }
                                }
                            }
                        }
                        
                        
                        
                    }else{
                        
                        var arrayOfController = self.navigationController?.viewControllers
                        for (index, item) in (arrayOfController?.enumerated())! {
                            if  let controller = item as? HomeTabbarVC {
                                var arrayOfController1 = controller.viewControllers
                                for (index1, item1) in (arrayOfController1?.enumerated())! {
                                    if  let controller = item1 as? ProfileVC {
                                        controller.viewDidLoad()
                                        controller.viewWillAppear(true)
                                    }
                                }
                            }
                        }
                        
                        
                    }
                    
                    
                    
                 //   self.navigationController?.popViewController(animated: true)
                }
                else {
                    if let message = responseData?["result"] as? String {
                        notifyUser("", message: message , vc: self)
                    }
                    else{
                        // notifyUser("", message: "Something went wrong", vc: self)
                    }
                }
            }
            else{ stopProgressIndicator()}
            
        }
    }
    func updateUser_CoachesDetails(request:NSDictionary,type:String) {
     
         showProgressIndicator(refrenceView: self.view)
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:type) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    
                    guard let resultDict = responseData?["result"] as? NSDictionary else {
                        return
                    }
                    removeUserDetails()
                    CloseChatDays = resultDict["close_chat"] as? String ?? ""
                    ServiceTaxValue = resultDict["service_tax"] as? String ?? ""
                    saveUserDetails(userDict: resultDict)
                    if isCoach(){
                        var arrayOfController = self.navigationController?.viewControllers
                        for (index, item) in (arrayOfController?.enumerated())! {
                            if  let controller = item as? CoachesTabbarVC {
                               var arrayOfController1 = controller.viewControllers
                                for (index1, item1) in (arrayOfController1?.enumerated())! {
                                    if  let controller = item1 as? CoachesProfileVC {
                                        controller.viewDidLoad()
                                        controller.viewWillAppear(true)
                                    }
                                }
                            }
                        }
                        

                       
                    }else{
                        
                        if let viewControllers = self.navigationController?.viewControllers {
                            for viewController in viewControllers {
                                // some process
                                if viewController.isKind(of: ProfileVC.self){
                                    if let vc = viewController as? ProfileVC {
                                        //   vc.selectedIndex = 1;
                                        vc.viewDidLoad()
                                        vc.viewWillAppear(true)
                                     //   self.navigationController?.popToViewController(vc, animated: true)
                                        break
                                    }
                                    
                                }
                            }
                        }
                        
//                        var arrayOfController = self.navigationController?.viewControllers
//                        for (index, item) in (arrayOfController?.enumerated())! {
//                            if  let controller = item as? HomeTabbarVC {
//                                var arrayOfController1 = controller.viewControllers
//                                for (index1, item1) in (arrayOfController1?.enumerated())! {
//                                    if  let controller = item1 as? ProfileVC {
//                                        controller.viewDidLoad()
//                                        controller.viewWillAppear(true)
//                                    }
//                                }
//                            }
//                        }
                        
                       
                    }
                   
                 
                    
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    if let message = responseData?["result"] as? String {
                        notifyUser("", message: message , vc: self)
                    }
                    else{
                        // notifyUser("", message: "Something went wrong", vc: self)
                    }
                }
            }
            else{ stopProgressIndicator()}
            
        }
    }
    
    //MARK:LocationManagerDelegate
    func getCurrentLocation(address: String, latitude: String, longitude: String) {
        user_address = address
        locationArray = [longitude,latitude]
        let addressindexPath = IndexPath(row: 1, section: 0)
        if let cell = editTbl_view.cellForRow(at: addressindexPath) as? AddUserAddressCell {
            // do what you need with cell
            cell.tf_address.text = user_address
        }
        
    }
    
    //MARK: ****** Check Field is empty / valid **************
    func ischeckManadoryDetails() -> Bool {
        
        let infoindexPath = IndexPath(row: 0, section: 0)
        if let cell = editTbl_view.cellForRow(at: infoindexPath) as? CoachesSignUpCell {
            // do what you need with cell
            firstName = cell.Tf_Fristname.text ?? ""
            lastName = cell.Tf_Secondname.text ?? ""
            phoneNumber = cell.Tf_phoneNo.text ?? ""
        }
        
        let addressindexPath = IndexPath(row: 1, section: 0)
        if let cell = editTbl_view.cellForRow(at: addressindexPath) as? AddUserAddressCell {
            // do what you need with cell
            user_address = cell.tf_address.text ?? ""
        }
        
        if String.isNilOrEmpty(firstName)  {
            notifyUser("", message: kFIRSTNMAE_BLANK, vc: self)
            return false
        }
        else if String.isNilOrEmpty(lastName)  {
            notifyUser("", message: kLASTNMAE_BLANK, vc: self)
            return false
        }
//        else if String.isNilOrEmpty(phoneNumber) {
//            notifyUser("", message: kPHONE_BLANK, vc: self)
//            return false
//        }
//        else if String.isNilOrEmpty(user_address) {
//            notifyUser("", message: kADDRESS_BLANK, vc: self)
//            return false
//        }
        
        return true
    }
    
    func ischeckCoachesManadoryDetails() -> Bool {
        if let cell = editTbl_view.cellForRow(at: IndexPath(row: 0, section: 3)) as? CoachesCategoryCell {
            categoryArray =  cell.coachesCategoryArray
        }
        if let cell = editTbl_view.cellForRow(at: IndexPath(row: 0, section: 4)) as? CoachesPricingCell{
            // do what you need with cell
            directMessage = cell.tf_Price.text ?? ""
        }
        if let cell = editTbl_view.cellForRow(at: IndexPath(row: 1, section: 4)) as? CoachesPricingCell{
            // do what you need with cell
            rushDirectMessage = cell.tf_Price.text ?? ""
        }
        if let cell = editTbl_view.cellForRow(at: IndexPath(row: 2, section: 4)) as? CoachesPricingCell{
            // do what you need with cell
            liveChat = cell.tf_Price.text ?? ""
        }
        
        
        if String.isNilOrEmpty(firstName)  {
            notifyUser("", message: kFIRSTNMAE_BLANK, vc: self)
            return false
        }
        else if String.isNilOrEmpty(lastName)  {
            notifyUser("", message: kLASTNMAE_BLANK, vc: self)
            return false
        }
        else if String.isNilOrEmpty(phoneNumber) {
            notifyUser("", message: kPHONE_BLANK, vc: self)
            return false
        }
        else if phoneNumber.count < 10  {
            notifyUser("", message: "Please enter valid phone number ", vc: self)
            return false
        }else if String.isNilOrEmpty(user_address) {
            notifyUser("", message: kADDRESS_BLANK, vc: self)
            return false
        }else if aboutyou == "Briefly tell us why you became a coach and what services you provide?" {
            notifyUser("", message: kABOUTYOU_BLANK, vc: self)
            return false
        }
//        }else if aboutcategory == "Write here 500 character" {
//            notifyUser("", message: kABOUTCATEGO_BLANK, vc: self)
//            return false
//        }
            else if categoryArray.count <= 0 {
            notifyUser("", message: kCATEGORY_BLANK, vc: self)
            return false
        }else if direct_Status == "0" && rush_direct_Status == "0" && livechat_Status == "0" {
            notifyUser("", message: "Please Provide Pricing Details", vc: self)
            return false
            
        }
        return true
    }
    
//    @objc func catBtnPressed(sender: UIButton){
//
//        let tagvalue = sender.tag
//        if tagvalue == 0 {
//
//         weak var catModel1 = categoryModelArray.object(at: 0) as! CategoryModel
//            var status1 =  catModel1?.CatSelectedStatus as! String
//
//            if status1 == "YES" {
//                catModel1?.CatSelectedStatus = "NO"
//
//            }else if status1 == "NO" {
//                 catModel1?.CatSelectedStatus = "YES"
//            }
//
//
//            print("Single")
//        } else if tagvalue == 1 {
//             print("new RlationShip")
//          weak   var catModel2 = categoryModelArray.object(at: 1) as! CategoryModel
//            var status2 =  catModel2?.CatSelectedStatus as! String
//
//            if status2 == "YES" {
//                catModel2?.CatSelectedStatus = "NO"
//
//            }else if status2 == "NO" {
//                catModel2?.CatSelectedStatus = "YES"
//            }
//
//        }else if tagvalue  == 2 {
//             print("Other")
//            weak var catModel3 = categoryModelArray.object(at: 2) as! CategoryModel
//             var status3 =  catModel3?.CatSelectedStatus as! String
//
//            if status3 == "YES" {
//                catModel3?.CatSelectedStatus = "NO"
//
//            }else if status3 == "NO" {
//                catModel3?.CatSelectedStatus = "YES"
//            }
//        }
//         self.editTbl_view.reloadRows(at: [IndexPath(row: 0, section: 3)], with: .none)
//
//
//    }
//
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return categoryModelArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionCell", for : indexPath as IndexPath) as? CategoryCollectionCell
       

        cell?.backgroundColor = UIColor.green
        
        
                   var catModel = categoryModelArray.object(at: indexPath.item) as! CategoryModel
                    var status =  catModel.CatSelectedStatus as String
        
        let catName = catModel.categoryName as? String ?? ""
        cell?.categoryName.text = catName
        
        if status == "YES" {
            
            let selimageName = catModel.CatSelectedImgName as String? ?? ""
            let imageUrl = URL(string:selimageName )
            cell?.categoryImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "tarot_reading_unselect"), options:.refreshCached)

            cell?.categoryName.textColor = UIColor.red
            
                        }else if status == "NO" {
            let imageName = catModel.CatUnSelectedImgName as String? ?? ""
            cell?.categoryImage.image = UIImage(named:imageName )
           
            let imageUrl = URL(string:imageName )
            cell?.categoryImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "tarot_reading_select"), options:.refreshCached)
            
              cell?.categoryName.textColor = UIColor.black
        }
        
        return cell!
//        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionCell", for: indexPath as IndexPath)
//
//        cell.backgroundColor = UIColor.green
//        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
      
        let tagvalue = indexPath.item
        
        weak var catModel = categoryModelArray.object(at: indexPath.item) as! CategoryModel
       
        var status1 =  catModel?.CatSelectedStatus as! String
        
        if status1 == "YES" {
            catModel?.CatSelectedStatus = "NO"
            
        }else if status1 == "NO" {
            catModel?.CatSelectedStatus = "YES"
        }
       
         collectionView.reloadData()
        
//        if tagvalue == 0 {
//
//            weak var catModel1 = categoryModelArray.object(at: 0) as! CategoryModel
//            var status1 =  catModel1?.CatSelectedStatus as! String
//
//            if status1 == "YES" {
//                catModel1?.CatSelectedStatus = "NO"
//
//            }else if status1 == "NO" {
//                catModel1?.CatSelectedStatus = "YES"
//            }
//
//
//            print("Single")
//        } else if tagvalue == 1 {
//            print("new RlationShip")
//            weak   var catModel2 = categoryModelArray.object(at: 1) as! CategoryModel
//            var status2 =  catModel2?.CatSelectedStatus as! String
//
//            if status2 == "YES" {
//                catModel2?.CatSelectedStatus = "NO"
//
//            }else if status2 == "NO" {
//                catModel2?.CatSelectedStatus = "YES"
//            }
//
//        }else if tagvalue  == 2 {
//            print("Other")
//            weak var catModel3 = categoryModelArray.object(at: 2) as! CategoryModel
//            var status3 =  catModel3?.CatSelectedStatus as! String
//
//            if status3 == "YES" {
//                catModel3?.CatSelectedStatus = "NO"
//
//            }else if status3 == "NO" {
//                catModel3?.CatSelectedStatus = "YES"
//            }
//        }
//     //   self.editTbl_view.reloadRows(at: [IndexPath(row: 0, section: 3)], with: .none)
//
//      collectionView.reloadData()
//
        
    }
}

extension EditUserProfileVC: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isfromCoach {
            return 5
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isfromCoach {
            if section == 4{
                return 3
            }
            else if section == 0{
                return 2
            }
            return 1
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
          if indexPath.section == 0 {
                if indexPath.row == 0 {
                    let cell: CoachesSignUpCell! =  tableView.dequeueReusableCell(withIdentifier: "CoachesSignUpCell") as? CoachesSignUpCell
                    cell.Tf_Fristname.delegate = self
                    cell.Tf_Secondname.delegate = self
                    cell.Tf_phoneNo.delegate = self
                    cell.selectionStyle = .none
                   
                    if uploadUrl == "" {
                        cell.userImage.isHidden = true
                        cell.userNameProfileLbl.isHidden = false
                        cell.userNameProfileLbl.text = String(firstName.prefix(1))
                    } else {
                        cell.userImage.isHidden = false
                        cell.userNameProfileLbl.isHidden = true
                    }
                    
                    cell.EditBtn.addTarget(self, action: #selector(changeProfilePicAcion), for: .touchUpInside)
                    let imageUrl = URL(string: uploadUrl)
                    cell.userImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    cell.Tf_emailid.isUserInteractionEnabled = false
                    cell.Tf_emailid.text = getUserEmail()
                    cell.Tf_phoneNo.text = phoneNumber
                    cell.Tf_Fristname.text = firstName
                    cell.Tf_Secondname.text = lastName
                    cell.Tf_Fristname.tag = 1000
                    cell.Tf_Secondname.tag = 2000
                    cell.Tf_emailid.tag = 3000
                    cell.Tf_phoneNo.tag = 4000
                    
                    if isfromCoach {
                        cell.Tf_phoneNo.isHidden = false
                        cell.phoneLbl.isHidden = false
                         cell.phoneBaseView.isHidden = false
                    }else{
                         cell.Tf_phoneNo.isHidden = true
                        cell.phoneLbl.isHidden = true
                        cell.phoneBaseView.isHidden = true
                     //   cell.phoneBaseView.backgroundColor = UIColor.lightGray
                    }
                    
                    return cell
                }
                else{
                    let cell: AddUserAddressCell! =  tableView.dequeueReusableCell(withIdentifier: "AddUserAddressCell") as? AddUserAddressCell
                    cell.selectionStyle = .none
                    cell.addressBtn.addTarget(self, action: #selector(selectAddressBtnAction), for: .touchUpInside)
                    cell.tf_address.text = user_address
                    return cell
                }
          }else if indexPath.section == 1 {
            let cell: EditIntroVideo! =  tableView.dequeueReusableCell(withIdentifier: "EditIntroVideo") as? EditIntroVideo
            cell.selectionStyle = .none
            let videoUrl = getIntroVideoUrl() as String
            if videoUrl == "" {
              cell.EditLbl.text = "Add Introducion Video"
            }else {
                  cell.EditLbl.text = "Edit Introducion Video"
            }
            
            cell.EditVideoBtn.addTarget(self, action: #selector(EditIntroductionideoBtnAction), for: .touchUpInside)
           
            return cell
          }
         else if indexPath.section == 3 {
            
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as UITableViewCell!
           cell.frame =   CGRect(x: 0, y: 0, width: self.view.frame.size.width , height: 100)
           cell.contentView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width , height: 100)
            CategoryCollectionView.frame = cell.bounds
            cell.contentView.addSubview(CategoryCollectionView)
            
            return cell
            
//                let cell: CoachesCategoryCell! =  tableView.dequeueReusableCell(withIdentifier: "CoachesCategoryCell") as? CoachesCategoryCell
//                cell.selectionStyle = .none
//                cell.updateCategoryDetails(catArray: getCategoryArray(), isEdit: true)
//                return cell
      
              /****************  New 1 *************/
//            let cell:UITableViewCell = self.editTbl_view.dequeueReusableCell(withIdentifier: categoryCellName) as UITableViewCell!
//
//            cell.frame =  CGRect(x: 0, y: 0, width: self.view.frame.size.width , height: 100)
//            let baseView = UIView(frame: CGRect(x: 10, y: 0, width: self.view.frame.size.width - 20, height: 100))
//            baseView.backgroundColor = UIColor.white
//            cell.selectionStyle = .none
//            cell.addSubview(baseView)
//
//         /****************  Cat 1 *************/
//            let CatbaseView1 = UIView(frame: CGRect(x: (baseView.frame.size.width - 300)/4, y: 0, width:100 , height: 100))
//            CatbaseView1.backgroundColor = UIColor.white
//            baseView.addSubview(CatbaseView1)
//
//            let categoryImgBtn1 = UIButton(frame: CGRect(x: 22.5 , y: 5, width:55 , height: 55))
//            categoryImgBtn1.isUserInteractionEnabled = false
//            categoryImgBtn1.layer.masksToBounds = true
//            categoryImgBtn1.layer.cornerRadius = 27.5
//            CatbaseView1.addSubview(categoryImgBtn1)
//
//
//            let catNameLbl1 = UILabel(frame: CGRect(x:0 , y: categoryImgBtn1.frame.origin.y + categoryImgBtn1.frame.size.height , width: 100, height: 40))
//            catNameLbl1.textColor = UIColor.white
//            catNameLbl1.lineBreakMode = .byWordWrapping
//            catNameLbl1.numberOfLines = 2
//            catNameLbl1.font =  catNameLbl1.font.withSize(14)
//            catNameLbl1.textAlignment = .center
//            CatbaseView1.addSubview(catNameLbl1)
//
//            let catTopBtn1 = UIButton(frame: CatbaseView1.frame)
//            catTopBtn1.backgroundColor = UIColor.clear
//            catTopBtn1.tag = 0
//            catTopBtn1.addTarget(self, action:#selector(catBtnPressed(sender:)), for: .touchUpInside)
//            CatbaseView1.addSubview(catTopBtn1)
//             /****************  Cat 1 *************/
//
//             /****************  Cat 2 *************/
//            let CatbaseView2 = UIView(frame: CGRect(x: 2*((baseView.frame.size.width - 300)/4) + 100, y: 0, width:100 , height: 100))
//            CatbaseView2.backgroundColor = UIColor.white
//            baseView.addSubview(CatbaseView2)
//
//
//
//
//            let categoryImgBtn2 = UIButton(frame: CGRect(x: 22.5 , y: 5, width: 55, height: 55))
//            categoryImgBtn2.isUserInteractionEnabled = false
//            categoryImgBtn2.layer.masksToBounds = true
//            categoryImgBtn2.layer.cornerRadius = 27.5
//            CatbaseView2.addSubview(categoryImgBtn2)
//
//
//            let catNameLbl2 = UILabel(frame: CGRect(x:0 , y: categoryImgBtn2.frame.origin.y + categoryImgBtn2.frame.size.height , width: 100, height: 40))
//            catNameLbl2.textColor = UIColor.white
//            catNameLbl2.textAlignment = .center
//             catNameLbl2.font =  catNameLbl1.font.withSize(14)
//            catNameLbl2.lineBreakMode = .byWordWrapping
//            catNameLbl2.numberOfLines = 2
//            CatbaseView2.addSubview(catNameLbl2)
//
//
//            let catTopBtn2 = UIButton(frame: CatbaseView1.frame)
//            catTopBtn2.backgroundColor = UIColor.clear
//            catTopBtn2.tag = 1
//            catTopBtn2.addTarget(self, action:#selector(catBtnPressed(sender:)), for: .touchUpInside)
//            CatbaseView2.addSubview(catTopBtn2)
//
//             /****************  Cat 2 *************/
//
//            /****************  Cat 3 *************/
//            let CatbaseView3 = UIView(frame: CGRect(x: 3*((baseView.frame.size.width - 300)/4) + 200, y: 0, width:100 , height: 100))
//            CatbaseView3.backgroundColor = UIColor.white
//            baseView.addSubview(CatbaseView3)
//
//            let categoryImgBtn3 = UIButton(frame: CGRect(x: 22.5 , y: 5, width: 55, height: 55))
//            categoryImgBtn3.isUserInteractionEnabled = false
//            categoryImgBtn2.layer.masksToBounds = true
//            categoryImgBtn2.layer.cornerRadius = 27.5
//            CatbaseView3.addSubview(categoryImgBtn3)
//
//
//            let catNameLbl3 = UILabel(frame: CGRect(x:0 , y: categoryImgBtn3.frame.origin.y + categoryImgBtn3.frame.size.height , width: 100, height: 40))
//
//            catNameLbl3.textAlignment = .center
//            catNameLbl3.lineBreakMode = .byWordWrapping
//            catNameLbl3.numberOfLines = 2
//            catNameLbl3.font =  catNameLbl1.font.withSize(14)
//            CatbaseView3.addSubview(catNameLbl3)
//
//            let catTopBtn3 = UIButton(frame: CatbaseView1.frame)
//            catTopBtn3.backgroundColor = UIColor.clear
//            catTopBtn3.tag = 2
//            catTopBtn3.addTarget(self, action:#selector(catBtnPressed(sender:)), for: .touchUpInside)
//            CatbaseView3.addSubview(catTopBtn3)
//             /****************  Cat 3 *************/
//
//            /****************  New 1 *************/
//
//
//            var catModel1 = categoryModelArray.object(at: 0) as! CategoryModel
//            var catModel2 = categoryModelArray.object(at: 1) as! CategoryModel
//            var catModel3 = categoryModelArray.object(at: 2) as! CategoryModel
//
//            var status1 =  catModel1.CatSelectedStatus as String
//            var status2 =  catModel2.CatSelectedStatus as String
//            var status3 =  catModel3.CatSelectedStatus as String
//
//           catNameLbl1.text = catModel1.categoryName as String
//            catNameLbl2.text = catModel2.categoryName as String
//            catNameLbl3.text = catModel3.categoryName as String
//
//            if status1 == "YES" {
//
//                categoryImgBtn1.setImage(UIImage(named:catModel1.CatSelectedImgName as String ), for: .normal)
//                  catNameLbl1.textColor = UIColor.red
//            }else if status1 == "NO" {
//               categoryImgBtn1.setImage(UIImage(named:catModel1.CatUnSelectedImgName as String ), for: .normal)
//                  catNameLbl1.textColor = UIColor.black
//            }
//            if status2 == "YES" {
//               categoryImgBtn2.setImage(UIImage(named:catModel2.CatSelectedImgName as String ), for: .normal)
//                  catNameLbl2.textColor = UIColor.red
//            }else if status2 == "NO" {
//               categoryImgBtn2.setImage(UIImage(named:catModel2.CatUnSelectedImgName as String ), for: .normal)
//                  catNameLbl2.textColor = UIColor.black
//            }
//            if status3 == "YES" {
//               categoryImgBtn3.setImage(UIImage(named:catModel3.CatSelectedImgName as String ), for: .normal)
//                  catNameLbl3.textColor = UIColor.red
//            }else if status3 == "NO" {
//                categoryImgBtn3.setImage(UIImage(named:catModel3.CatUnSelectedImgName as String ), for: .normal)
//                  catNameLbl3.textColor = UIColor.black
//            }
//
//
//
//            return cell

          } else if indexPath.section == 4 {

            
            let cell: PricingSignUpTblCell! =  tableView.dequeueReusableCell(withIdentifier: "PricingSignUpTblCell") as? PricingSignUpTblCell
            cell.frame = CGRect(x:0, y: 0, width: self.view.frame.size.width, height:50)
            cell.contentView.frame = CGRect(x:0, y: 0, width: self.view.frame.size.width, height:50)
                        cell.BaseView.frame =  CGRect(x:0, y: 0, width: cell.frame.size.width , height: cell.frame.size.height - 0.25)
            cell.backgroundColor = UIColor.lightGray
            cell.BaseView.backgroundColor = UIColor.white
            
            cell.rightImgView.frame = CGRect(x:10, y: 18, width: 20, height: 14)
            cell.ChatTypeBtn.frame =  CGRect(x:10 + 10 + 20, y:0, width: cell.BaseView.frame.size.width - 80 - 50, height: cell.BaseView.frame.size.height)
            cell.VerticalNarroewLineView.frame = CGRect(x:cell.ChatTypeBtn.frame.size.width + cell.ChatTypeBtn.frame.origin.x, y: 0, width: 0.5, height: 50)
            
            cell.PriceTxtFieldBaseView.frame = CGRect(x:cell.ChatTypeBtn.frame.size.width + cell.ChatTypeBtn.frame.origin.x + 0.5, y: 0, width: 80, height: cell.BaseView.frame.size.height)
            cell.priceTxtFld.frame = CGRect(x:0 , y: 0, width: cell.PriceTxtFieldBaseView.frame.width, height: cell.BaseView.frame.size.height - 20)
            cell.priceTxtFld.textAlignment = .center
            cell.priceTxtFld.delegate = self
            cell.priceLbl.frame = CGRect(x:0 , y: cell.priceTxtFld.frame.size.height, width: cell.PriceTxtFieldBaseView.frame.width, height: 20)
         cell.priceLbl.text = "Per msg"
            cell.priceLbl.textAlignment = .center
            cell.priceLbl.textColor = UIColor.lightGray
      
   //     cell.ChatTypeBtn.addTarget(self, action:#selector(handlePricing(sender:)), for: .touchUpInside)
      
        cell.priceTxtFld.inputView = pickerView
            cell.ChatTypeBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            cell.priceLbl.font = UIFont.systemFont(ofSize: 15)
            cell.priceTxtFld.font = UIFont.systemFont(ofSize: 15)
            cell.PriceTxtFieldBaseView.backgroundColor = UIColor.white
        cell.selectionStyle = .none
            cell.BaseView.backgroundColor = UIColor.white
            
            
            
            if indexPath.row == 0
            {
                var PriceModel1 = CoachPriceModelArray.object(at: 0) as! CoachPricingModel
                 var status1 =  PriceModel1.coachPriceStatus as String
                 cell.priceTxtFld.text = PriceModel1.coachPrice as String
                 cell.ChatTypeBtn.setTitle(PriceModel1.coachPriceType as String, for: .normal)
                cell.ChatTypeBtn.tag = indexPath.row
                cell.priceTxtFld.tag = indexPath.row
               
                if status1 == "YES" {
                    cell.ChatTypeBtn.setTitleColor(hexStringToUIColor(hex: "#0b91f8"), for: .normal)
                    cell.rightImgView.isHidden = false
                     cell.priceTxtFld.isUserInteractionEnabled =  true
                    
                } else if status1 == "NO" {
                   cell.ChatTypeBtn.setTitleColor(UIColor.lightGray, for: .normal)
                    cell.rightImgView.isHidden = true
                    cell.priceTxtFld.text = "-"
                    cell.priceTxtFld.isUserInteractionEnabled =  false
                }
            } else if indexPath.row == 1 {
                var PriceModel2 = CoachPriceModelArray.object(at: 1) as! CoachPricingModel
                 var status2 =  PriceModel2.coachPriceStatus as String
                 cell.priceTxtFld.text = PriceModel2.coachPrice as String
                cell.ChatTypeBtn.setTitle(PriceModel2.coachPriceType as String, for: .normal)
                cell.ChatTypeBtn.tag = indexPath.row
                cell.priceTxtFld.tag = indexPath.row
                if status2 == "YES" {
                    cell.ChatTypeBtn.setTitleColor(hexStringToUIColor(hex: "#0b91f8"), for: .normal)
                    cell.rightImgView.isHidden = false
                cell.priceTxtFld.isUserInteractionEnabled =  true
                } else if status2 == "NO" {
                    cell.ChatTypeBtn.setTitleColor(UIColor.lightGray, for: .normal)
                    cell.rightImgView.isHidden = true
                    cell.priceTxtFld.text = "-"
                      cell.priceTxtFld.isUserInteractionEnabled =  false
                }
            } else if indexPath.row == 2 {
                var PriceModel3 = CoachPriceModelArray.object(at: 2) as! CoachPricingModel
                var status3 =  PriceModel3.coachPriceStatus as String
                 cell.priceTxtFld.text = PriceModel3.coachPrice as String
                  cell.ChatTypeBtn.setTitle(PriceModel3.coachPriceType as String, for: .normal)
                cell.ChatTypeBtn.tag = indexPath.row
                cell.priceTxtFld.tag = indexPath.row
                cell.priceLbl.text = "Per min"
                if status3 == "YES" {
                    cell.ChatTypeBtn.setTitleColor(hexStringToUIColor(hex: "#0b91f8"), for: .normal)
                    cell.rightImgView.isHidden = false
                cell.priceTxtFld.isUserInteractionEnabled =  true
                } else if status3 == "NO" {
                    cell.ChatTypeBtn.setTitleColor(UIColor.lightGray, for: .normal)
                    cell.rightImgView.isHidden = true
                    cell.priceTxtFld.text = "-"
                    cell.priceTxtFld.isUserInteractionEnabled =  false
                }
            }
           
            cell.ChatTypeBtn.contentHorizontalAlignment = .left
           
           //   cell.priceTxtFld.isUserInteractionEnabled = false
              cell.ChatTypeBtn.isUserInteractionEnabled = false
            cell.priceTxtFld.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(DoneBtnPressed(_:)))
            cell.priceTxtFld.keyboardToolbar.doneBarButton.tag  = indexPath.row
              cell.isUserInteractionEnabled = true
                        return cell
            
          }
        else{
            let cell: CoachesAddAboutCell! =  tableView.dequeueReusableCell(withIdentifier: "CoachesAddAboutCell") as? CoachesAddAboutCell
            cell.textView_abou.delegate = self
            cell.textView_abou.tag = indexPath.section
            if (cell.textView_abou.text == "Briefly tell us why you became a coach and what services you provide?") || (cell.textView_abou.text == "Write here 500 character"){
                cell.textView_abou.textColor = .lightGray
            }
            else{
                cell.textView_abou.textColor = .black
            }
            
            if indexPath.section == 2{
                
                cell.textView_abou.text = aboutyou
            }
            else{
                cell.textView_abou.text = aboutcategory
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}

extension EditUserProfileVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cardDetail = self.cardArray[indexPath.row]
        if indexPath.section == 4 {
            if indexPath.row == 0 {
                print("directPrice")
                self.managePrice(tagValue: 0)
            }else if indexPath.row == 1 {
                 self.managePrice(tagValue: 1)
                  print("Rush direct price")
            } else if indexPath.row == 2 {
                  print("Live Chat")
                 self.managePrice(tagValue: 2)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            if indexPath.row == 1{
                return 85
            }
              if indexPath.row == 0{
            if isfromCoach {
                return 325
            } else{
                return 275
            }
            }
           
        }
        else if indexPath.section == 4 {
            return 50
        }
        else if indexPath.section == 1{
            return 50
        }
        // else if indexPath.section == 2{
//         return   UITableViewAutomaticDimension
//        } else if indexPath.section == 3{
//           return   UITableViewAutomaticDimension
//        }
        
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        let header_lbl = UILabel(frame: CGRect(x: 15, y: 0, width: 200, height: 40))
        headerView.backgroundColor = UIColor.clear
        if section == 0{
        }
        else if section == 1{
            header_lbl.text = "INTRODUCTION VIDEO"
        }else if section == 2{
                        header_lbl.text = "ABOUT ME"
                    }
//                    else if section == 3{
//                        header_lbl.text = "ABOUT MY SERVICES"
//                    }
        else if section == 3{
            header_lbl.text = "CHOOSE YOUR EXPERTISE"
        }

        else if section == 4{
            header_lbl.text = "PRICING"
        }
        header_lbl.font = UIFont(name: "OpenSans-Bold", size: 14.0)
        headerView.addSubview(header_lbl)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if section == 0{
            return 0
        }
        return 40
    }

    
}

