//
//  setPassCodeFirst.swift
//  Intrigued
//
//  Created by Shineweb-solutions on 23/01/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit

class setPassCodeFirst: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
      
        let pinCodeBtn = UIButton(frame: CGRect(x:(self.view.frame.size.width -  200)/2 , y: (self.view.frame.size.height -  100), width: 200, height: 50))
        pinCodeBtn.setTitle("Enter Pin Code", for: UIControlState.normal)
        pinCodeBtn.setTitleColor(.white, for: .normal)
        pinCodeBtn.addTarget(self, action:#selector(PincodeBtnTapped(_:)), for: .touchUpInside)
        pinCodeBtn.layer.masksToBounds = true
        pinCodeBtn.layer.cornerRadius = 30.0
        self.view.addSubview(pinCodeBtn)

        // Do any additional setup after loading the view.
    }
    @objc func PincodeBtnTapped(_ sender: UIButton){
      self.dismiss(animated: true, completion: nil)
        }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
