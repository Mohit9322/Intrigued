//
//  EarningDetailVC.swift
//  Intrigued
//
//  Created by Shineweb-solutions on 13/03/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit

class EarningDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var HeaderBaseView: UIView!
    @IBOutlet weak var HeaderNameLbl: UILabel!
    @IBOutlet weak var BackBtnn: UIButton!
    
    var userOrderInfo = NSDictionary()
    var images_Array = NSArray()
    
    @IBOutlet weak var infoTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(userOrderInfo)
        infoTableView.estimatedRowHeight = 50
        infoTableView.rowHeight = UITableViewAutomaticDimension
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        infoTableView.backgroundColor = hexStringToUIColor(hex: "#EFEFF4")
        
        infoTableView.register(UINib(nibName: "UserQuestionImageCell", bundle: nil), forCellReuseIdentifier: "UserQuestionImageCell")
        infoTableView.delegate = self
        infoTableView.dataSource = self
        print(userOrderInfo)
        
        let orderDict = userOrderInfo["order_id"] as? NSDictionary
        
        
        if let imageArray =  orderDict!["images"] as? NSArray  {
            images_Array = imageArray
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if images_Array.count > 0 {
            return 4
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: UserRequestInfoCell! =  tableView.dequeueReusableCell(withIdentifier: "UserRequestInfoCell") as? UserRequestInfoCell
            cell.selectionStyle = .none
            print(userOrderInfo)
            cell.setupEarningDataOnCell(orderDetails:userOrderInfo)
            
            let orderDict = userOrderInfo["order_id"] as? NSDictionary
            let created_date =  orderDict!["accept_time"] as? String
            let date =  convertStringintoDate(dateStr: created_date!)
            
            cell.paymentDate.text = date.getCreatedDate()
            return cell
        }
        else if indexPath.section == 3 {
            let cell: UserQuestionImageCell! =  tableView.dequeueReusableCell(withIdentifier: "UserQuestionImageCell") as? UserQuestionImageCell
            cell.selectionStyle = .none
            cell.setupDetailsonView(imageArray:images_Array)
            return cell
        }
        else{
            let cell: AboutAdvisorCell! =  tableView.dequeueReusableCell(withIdentifier: "AboutAdvisorCell") as? AboutAdvisorCell
            let orderDict = userOrderInfo["order_id"] as? NSDictionary
            if indexPath.section == 1{
                cell.lbl_aboutAdvisor.text = orderDict!["title"] as? String ?? ""
            }
            else{
                cell.lbl_aboutAdvisor.text =  orderDict!["question"] as? String ?? ""
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 320
            
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        let header_lbl = UILabel(frame: CGRect(x: 15, y: 0, width: 200, height:40))
        headerView.backgroundColor = UIColor.clear
        if section == 0{
        }
            
        else if section == 1{
            header_lbl.text = "USER DESCRIPTION"
        }
        else if section == 2{
            header_lbl.text = "USER QUESTION"
        }else if section == 3{
            header_lbl.text = "UPLOADED IMAGES"
        }
        
        header_lbl.font = UIFont(name: "OpenSans-Bold", size: 14.0)
        headerView.addSubview(header_lbl)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if section == 0 {
            return 0
        }
        return 40
    }
}

