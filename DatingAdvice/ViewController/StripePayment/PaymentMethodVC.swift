//
//  PaymentMethodVC.swift
//  Intrigued
//
//  Created by SWS on 01/02/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit
import Stripe
import IQKeyboardManagerSwift


protocol getSaveCardListDelegate {
    func getSaveCardList()
}

//protocol UpdateUserInfoDelegate {
//    func getUserDetailApi()
//}

//protocol SendUserMessageDelegate {
//    func sendMessageApi()
//}

class PaymentMethodVC: UIViewController,STPPaymentCardTextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var cardTextField_tf: STPPaymentCardTextField!
    @IBOutlet weak var cardholder_name_tf: UITextField!
    
    @IBOutlet weak var line1_address_tft: UITextField!
    @IBOutlet weak var line2_address_tft: UITextField!
    @IBOutlet weak var city_tft: UITextField!
    @IBOutlet weak var state_tft: UITextField!
    @IBOutlet weak var zipcode_tft: UITextField!
    
    
    @IBOutlet weak var submit_btn: UIButton!
    let manager = StripeManager()
    var stripeCard = STPCardParams()
    var stripeToken = ""
    var delegate: getSaveCardListDelegate?
    //var userDelegate: UpdateUserInfoDelegate?
    var directPrice:Float = 0.0
    var pay_balance:String?
    var pageString:String?
    var Total_balance:String?
    var cardArrayDict : NSDictionary?
    let defaults = UserDefaults.standard
    
    var stateArrayList = [String]()
    var statePickerView = UIPickerView()
    var selectedStatePickeIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // GetCardListValue()
        cardholder_name_tf.setLeftPaddingPoints(10)
        line1_address_tft.setLeftPaddingPoints(10)
        line2_address_tft.setLeftPaddingPoints(10)
        city_tft.setLeftPaddingPoints(10)
        state_tft.setLeftPaddingPoints(10)
        print(directPrice)
        
        stateListApi()
        state_tft.delegate = self
        statePickerView.delegate = self
        statePickerView.dataSource = self
        state_tft.inputView = statePickerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().toolbarPreviousNextAllowedClasses = [UIStackView.self,UIView.self]
    }
    
    
    @IBAction func clickOnBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        
    }
    
    
    func isValidateFieldsForCardDetails() -> Bool {
        
        if String.isNilOrEmpty(cardTextField_tf.cardNumber){
            showAlerView(title: "Error!", message: "Card number is blank", self1: self)
            return false
        }
            
        else if (cardTextField_tf.expirationYear == 0 || cardTextField_tf.expirationMonth == 0){
            showAlerView(title: "Error!", message: "Expiry number is blank", self1: self)
            return false
        }
        else if String.isNilOrEmpty(cardTextField_tf.cvc ){
            showAlerView(title: "Error!", message: "Pin number is blank", self1: self)
            return false
        }
        else if String.isNilOrEmpty(cardholder_name_tf.text){
            showAlerView(title: "Alert", message: "Your card holder name is missing", self1: self)
            return false
        }
        else if String.isNilOrEmpty(line1_address_tft.text){
            showAlerView(title: "Alert", message: "Your address line_1 field is missing", self1: self)
            return false
        }
            //        else if String.isNilOrEmpty(line2_address_tft.text){
            //            showAlerView(title: "Alert", message: "Your address line_2 field is missing", self1: self)
            //            return false
            //        }
            
        else if String.isNilOrEmpty(state_tft.text){
            showAlerView(title: "Alert", message: "Your address city field is missing", self1: self)
            return false
        }
            
        else if String.isNilOrEmpty(city_tft.text){
            showAlerView(title: "Alert", message: "Your address state field is missing", self1: self)
            return false
        }
        else if String.isNilOrEmpty(zipcode_tft.text){
            showAlerView(title: "Alert", message: "Your address zipcode field is missing", self1: self)
            return false
        }
        return true
    }
    
    
    //MARK: ********** UIPickerView Delegate & DataSource Method
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.stateArrayList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var data:String?
        if pickerView === statePickerView {
            data = self.stateArrayList[row]
        }
        return data
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        state_tft.text = self.stateArrayList[row]
        selectedStatePickeIndex = row
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === state_tft {
            state_tft.text = self.stateArrayList[selectedStatePickeIndex]
        }
    }
    
    
    
    func stateListApi() {
        //showProgressIndicator(refrenceView: self.view)
        let request = ["user_id": getUserId()] as [String : Any]
        
        print(request)
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:k_User_State_Listing) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    guard let resultArray = responseData?["result"] as? [[String:Any]] else {
                        return
                    }
                    for resultDict in resultArray{
                        let nameState = resultDict["name"] as? String ?? ""
                        self.stateArrayList.append(nameState)
                        print(self.stateArrayList)
                    }
                }
                else {
                    
                }
            }
        }
    }
    
    
    
    
    
    //MARK: ********** SUBMIT BUTTON **************
    @IBAction func clickOnSubmitButton(_ sender: UIButton) {
        
        if isValidateFieldsForCardDetails() {
            stripeCard = cardTextField_tf.cardParams
            stripeCard.name = cardholder_name_tf.text
            stripeCard.address.line1 = line1_address_tft.text
            stripeCard.address.line2 = line2_address_tft.text
            stripeCard.address.city = city_tft.text
            stripeCard.address.state = state_tft.text
            stripeCard.address.postalCode = zipcode_tft.text
            getTokenFromStripe()
        }
    }
    
    
    func getTokenFromStripe() {
        
        if STPCardValidator.validationState(forNumber: stripeCard.number, validatingCardBrand: true) == .invalid {
            showAlerView(title: "Error!", message: "Your card number is invalid", self1: self)
            return
        }
        else if STPCardValidator.validationState(forNumber: stripeCard.number, validatingCardBrand: true) == .incomplete {
            showAlerView(title: "Error!", message: "Card number should be minimum 16 digit", self1: self)
        }
            
        else if STPCardValidator.validationState(forExpirationMonth: String(stripeCard.expMonth)) == .invalid
        {
            showAlerView(title: "Error!", message: "Your card's expiration month number is invalid", self1: self)
            return
        }
        else if STPCardValidator.validationState(forExpirationYear: String(stripeCard.expYear), inMonth: String(stripeCard.expMonth)) == .invalid
        {
            showAlerView(title: "Error!", message: "Your card's expiration year is invalid", self1: self)
            return
        }
            
        else if STPCardValidator.validationState(forCVC: stripeCard.cvc ?? "", cardBrand: STPCardValidator.brand(forNumber: stripeCard.number ?? "")) == .incomplete {
            showAlerView(title: "Error!", message: "Your card cvc number is invalid", self1: self)
            return
        }
            
        else if  STPCardValidator.validationState(forCard: stripeCard) == .valid
        {
            appDelegateRef.showIndicator()
         //    appDelegateRef.showTitleIndicator()
            STPAPIClient.shared().createToken(withCard: stripeCard) { Token, error in
                guard let stripeToken = Token else {
                    NSLog("Error creating token: %@", error!.localizedDescription);
                   
                      appDelegateRef.hideIndicator()
                    return
                }
                print("******* stripe token \(stripeToken)")
                self.postStripeToken(token: stripeToken)
            }
            
        } else {
            return
        }
    }
    
    func postStripeToken(token: STPToken) {
        
        NSLog("Token is %@",token.tokenId)
        let stripeToken = token.tokenId
        
        let request = ["source":stripeToken]//,"TYPE":"POST","BODY":"YES"]
        //appDelegateRef.showIndicator()
        StripeManager().addCardOnStripe(data: request as NSDictionary) { (responseData,responseCode)  in
            appDelegateRef.hideIndicator()
            print("responseData",responseData ?? "", "responseCode -====",responseCode)
            self.cardArrayDict = responseData
            print("Card saved array detail \(String(describing: self.cardArrayDict))")
            if responseData != nil {
                if responseCode == 200{
                    if self.pageString == "userSendMessageVC" {
                        //self.confirm_payment()
                        //self.AlertConfirmController()
                    } else{
                        let alert = UIAlertController(title: "Card added", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            self.delegate?.getSaveCardList()
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else {
                    showAlerView(title: "Failed", message: "Add card failed.", self1: self)
                }
            }
        }
    }
    
    // }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

