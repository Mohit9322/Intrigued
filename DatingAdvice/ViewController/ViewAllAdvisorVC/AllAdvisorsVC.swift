//
//  AllAdvisorsVC.swift
//  Intrigued
//
//  Created by daniel helled on 21/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class AllAdvisorsVC: UIViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var lbl_navigationTitle: UILabel!
    @IBOutlet weak var filterTableView: UITableView!
    var advisorsArray = NSMutableArray()
    var filteredArray = NSMutableArray()
    var filteredType = ""
    var checkFiltered = Bool()
    @IBOutlet weak var noRecordView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        setTitle(type: filteredType)
        
        print(filteredType)
        print(checkFiltered)
        print(filteredArray)
        print(advisorsArray)
        noRecordView.isHidden = true
        searchController.searchResultsUpdater = self
       // definesPresentationContext = false
      //  searchController.hidesNavigationBarDuringPresentation = false
    //    searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.barTintColor = UIColor.searchBGColor
        filterTableView.tableHeaderView = searchController.searchBar
        showProgressIndicator(refrenceView: self.view)
        filterCoachList(searchText: "", type: filteredType)
        
        searchController.searchBar.showsCancelButton = false
        self.automaticallyAdjustsScrollViewInsets = true
   //     filterTableView.contentInset = UIEdgeInsetsMake(0, -4, 0, 0)
     filterTableView.contentInset = UIEdgeInsets.zero
    //    searchController.searchBar.backgroundColor = UIColor.red
     //   filterTableView.backgroundColor = UIColor.green
     //   filterTableView.tableHeaderView?.backgroundColor = UIColor.yellow
        
        // Do any additional setup after loading the view.
    }
    
    func setTitle(type:String) {
        switch type{
         case "1" :
             lbl_navigationTitle.text = "Direct Message"
            break
        case "2" :
            lbl_navigationTitle.text = "Rush Direct Message"
            break
        case "3" :
            lbl_navigationTitle.text = "All Advisors"
            //lbl_navigationTitle.text = "Live Chat"
            break
        case "4" :
            lbl_navigationTitle.text = "1-Hour Delivery"
            break
            
        default:
            lbl_navigationTitle.text = "All Advisors"
            break
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        
        searchController.dismiss(animated: true) {

        }
        self.view.endEditing(true)
          self.navigationController?.popViewController(animated: true)
    }
    
    @objc func clickOnOrderButton(sender:UIButton) {
          searchController.isActive = false
        movetoAddOrder(advisorIndex:sender.tag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        if searchController.searchBar.text! == "" {
              self.filterTableView.isHidden = false
              filterTableView.reloadData()
        }
        else{
            if searchText.characters.count > 0 {
                print(searchText)
                searchCoachBasedOnCategory(searchText: searchText)
            }
        }
    }

    //MARK:- ************ Hit Api to search coach ***************
    
    func searchCoachBasedOnCategory(searchText : String) {
        self.filterTableView.isHidden = false
        var request = NSDictionary()
        if checkFiltered {
            request = ["search": searchText,"type":filteredType]
        }
        else{
            request = ["search": searchText]
        }
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kSEARCH) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    guard let resultArray = responseData?["result"] as? NSMutableArray else {
                        return
                    }
                    self.filteredArray = resultArray
                    self.filterTableView.reloadData()
                }
                else {
                    DispatchQueue.main.async(execute: {
                        self.noRecordView.isHidden = false
                        self.filteredArray.removeAllObjects()
                        self.filterTableView.reloadData()
                    })
                    if let message = responseData?["result"] as? String {
                       // notifyUser("", message: message , vc: self)
                    }
                    else{
                        // notifyUser("", message: "Something went wrong", vc: self)
                    }
                }
            }
            else{ stopProgressIndicator()}
            
        }
    }
    func filterCoachList(searchText : String, type: String) {
         self.filterTableView.isHidden = false
        let request = ["search": searchText,"type":type] as [String : Any]
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kSEARCH) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    guard let resultArray = responseData?["result"] as? NSMutableArray else {
                        return
                    }
                    self.advisorsArray = resultArray
                    print(resultArray)
                    self.filterTableView.reloadData()
                }
                else {
                    DispatchQueue.main.async(execute: {
                       self.noRecordView.isHidden = false
                    })
                   
                    if let message = responseData?["result"] as? String {
                        //notifyUser("", message: message , vc: self)
                    }
                    else{
                        // notifyUser("", message: "Something went wrong", vc: self)
                    }
                }
            }
            else{ stopProgressIndicator()}
            
        }
    }
    func movetoAddOrder(advisorIndex:Int){
          searchController.isActive = false 
        var directStatus = Int()
        var rushdirectStatus = Int()
        var liveChatStatus = Int()
        var commType = ""
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserSendMessageVc") as! UserSendMessageVc
        if let dict = advisorsArray[advisorIndex] as? NSDictionary {
            vc.coachId = dict["_id"] as? String ?? ""
            coachIDPassMessage =  dict["_id"] as? String ?? ""
            userNamePassMsg =  (dict["fname"] as? String ?? "")  + " " + (dict["lname"] as? String ?? "")
            if let direct_Status = dict["direct_Status"] as? Int {
                directStatus =  direct_Status
            }
            
            if let rush_direct_Status = dict["rush_direct_Status"] as? Int {
                rushdirectStatus =  rush_direct_Status
            }
            
            if let livechat_Status = dict["livechat_Status"] as? Int {
                liveChatStatus = livechat_Status
            }
            
            if directStatus == 1{
                commType = "1"
            }
            else if rushdirectStatus == 1{
                commType = "2"
            }
            else if liveChatStatus == 1{
                commType = "3"
            }
            vc.communicationType = commType
            commTypePassMsg = commType
            checkFromController = "YES"
            vc.advisor_Details = dict
   
        }
        self.navigationController?.pushViewController(vc,animated: true)
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


extension AllAdvisorsVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredArray.count
        }
        else{
           return advisorsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell: HighestRatedCell! =  tableView.dequeueReusableCell(withIdentifier: "HighestRatedCell") as? HighestRatedCell
        cell.selectionStyle = .none
        if isFiltering() {
            if let dict = filteredArray[indexPath.row] as? NSDictionary {
                cell.setUpAdvisorFilterData(coachesDetails: dict, filterType: filteredType ?? "")
            }
        }
        else{
            if let dict = advisorsArray[indexPath.row] as? NSDictionary {
                print(dict)
                cell.setUpAdvisorFilterData(coachesDetails: dict,filterType: filteredType ?? "")
            }
        }
        cell?.orderButton.tag = indexPath.row
         cell?.orderButton.addTarget(self, action: #selector(AdvisorCollectionView.clickOnOrderButton(sender:)), for: .touchUpInside)
        return cell
    }
}

extension AllAdvisorsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 111
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        searchController.isActive = false 
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AdvisorDetailsVC") as! AdvisorDetailsVC
        if let dict = advisorsArray[indexPath.row] as? NSDictionary {
            vc.advisorDetails = dict
        }
        
        self.navigationController?.pushViewController(vc,animated: true)
    }
}

extension AllAdvisorsVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
}
