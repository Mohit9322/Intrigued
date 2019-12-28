//
//  ReviewsListVC.swift
//  Intrigued
//
//  Created by daniel helled on 31/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class ReviewsListVC: UIViewController {
    @IBOutlet weak var reviewListTableView: UITableView!
    var advisor_Details = NSDictionary()
    var reviewsArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(advisor_Details)
        reviewListTableView.estimatedRowHeight = 68
        reviewListTableView.rowHeight = UITableViewAutomaticDimension
        getReviewList()
    }
    
    
    
    
    
    func getReviewList() {
        showProgressIndicator(refrenceView: self.view)
        let coachId = advisor_Details["_id"] as? String ?? ""
        let request = ["coach_id": coachId,"pageSize":10,"pageIndex":1] as [String : Any]
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kGET_REVIEW_LIST) { (responseData)  in
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    guard let resultArray = responseData?["result"] as? NSMutableArray else {
                        return
                    }
                    self.reviewsArray = resultArray
                    self.reviewListTableView.reloadData()
                }
                else if code == 100{
                    if let message = responseData?["result"] as? String {
                        notifyUser("", message: message , vc: self)
                    }
                    //notifyUser("Alert", message: responseData["result"] as? String ?? "", vc: self)
                }
                else if code == 500{
                    if let message = responseData?["result"] as? String {
                        notifyUser("", message: message , vc: self)
                    }
                }
            }
            
        }
    }
    
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension ReviewsListVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reviewsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ReviewsDetailsCell! =  tableView.dequeueReusableCell(withIdentifier: "ReviewsDetailsCell") as? ReviewsDetailsCell
        let reviewDict = reviewsArray[indexPath.row]
        cell.showReviewDetailsView(reviewArray: reviewDict as! NSDictionary)
        
        return cell
    }
}

//extension ReviewsListVC: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 70
//    }
//}


