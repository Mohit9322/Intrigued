//
//  SelectAddressVC.swift
//  Intrigued
//
//  Created by daniel helled on 29/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import SVGeocoder
class SelectAddressVC: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var addressTblView: UITableView!
    @IBOutlet weak var searhView: UIView!
    var addressListsArray = NSMutableArray()
    var delegate:LocationManagerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        searhView.layer.cornerRadius = 4.0
        addressTblView.isHidden = true
        addressTblView.delegate = self
        addressTblView.dataSource = self
        self.addressTblView.tableFooterView = UIView()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        // Do any additional setup after loading the view.
    }
    @IBAction func onChangeKeyWord(_ sender: Any) {
        if let v = self.searchTextField.text?.count, v > 2 {
            self.searchAddressForString(address: self.searchTextField.text ?? "")
        }
    }
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchAddressForString(address: String)
    {
        SVGeocoder.geocode(address, completion:{(placemarks, urlResponse, error: Error?) -> Void in
            if placemarks == nil
            {return}
            
            if let addressArray = placemarks as AnyObject as? NSArray {
                print("address",addressArray)
                self.addressListsArray = addressArray.mutableCopy() as! NSMutableArray
                self.addressTblView.isHidden = false
                self.addressTblView.reloadData()
            }
        })
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
    extension SelectAddressVC: UITableViewDataSource {
        
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return addressListsArray.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
   
           // let cell =  tableView.dequeueReusableCell(withIdentifier: "c1", for: indexPath)
            cell.selectionStyle = .none
        
            if  let dictOfInfo:SVPlacemark =  addressListsArray[indexPath.row] as? SVPlacemark{
                cell.textLabel?.text = dictOfInfo.formattedAddress
                cell.textLabel?.font = UIFont(name: "OpenSans", size: 13.0)
            }
            return cell
        }
        
    }
    
    extension SelectAddressVC: UITableViewDelegate {
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
             let placemark :SVPlacemark = addressListsArray[indexPath.row] as! SVPlacemark
             SVGeocoder.reverseGeocode(placemark.coordinate, completion:{(placemarks, urlResponse, error: Error?) -> Void in
                
                if (error != nil)
                {return}
                
                if placemarks == nil
                {return}
                
                if let v = placemarks?.count, v > 0 {
                    let lat = String(placemark.coordinate.latitude)
                    let lng = String(placemark.coordinate.longitude)
                    self.delegate?.getCurrentLocation(address: placemark.formattedAddress, latitude: lat, longitude: lng)
                   self.navigationController?.popViewController(animated: true)
                }
             })
            
        }
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

            return 44
        }
        
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
            let header_lbl = UILabel(frame: CGRect(x: 15, y: 0, width: 200, height: 40))
            header_lbl.text = "SELECT LOCATION"
            header_lbl.font = UIFont(name: "OpenSans-Bold", size: 14.0)
            headerView.addSubview(header_lbl)
            
            return headerView
        }
        
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
            return 40
        }
        
    }



