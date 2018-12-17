//
//  MyTicketVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

class MyTicketVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var lblNoTickets: UILabel!
    
    @IBOutlet weak var tblView: UITableView!
    var arrayOfTickets = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = "MY TICKET"
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        //hide empty cell from tableView
        self.tblView.estimatedRowHeight = 63
        self.tblView.tableFooterView = UIView()
        
        self.fetchTickets()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return self.arrayOfTickets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        let json = self.arrayOfTickets.object(at: indexPath.row)as! NSDictionary
        let file_name = json.value(forKey: "file_name")as! String
        
        if file_name != ""{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
            
            if let lblTitle = cell.viewWithTag(1)as? UILabel{
                lblTitle.text = json.value(forKey: "ticket_message")as? String
            }
            
            if let lblCreatedAt = cell.viewWithTag(2)as? UILabel{
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 0{
                       lblCreatedAt.text = "Pending  \(self.getDate(dateString: json.value(forKey: "updated_at")as! String))"
                    }
                    else if status == 1{
                        lblCreatedAt.text = "Answered  \(self.getDate(dateString: json.value(forKey: "updated_at")as! String))"
                    }
                    else{
                        lblCreatedAt.text = "Closed  \(self.getDate(dateString: json.value(forKey: "updated_at")as! String))"
                    }
                    
                }
            }
            
            if let tiketImage = cell.viewWithTag(3)as? UIImageView{
                if let link = json.value(forKey: "file_name")as? String{
                    let url = URL(string: link)
                    tiketImage.sd_setImage(with: url) { (image, error, imageCacheType, imageUrl) in }
                    tiketImage.layer.cornerRadius = 5
                    tiketImage.clipsToBounds = true
                }
            }
            
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
            
            if let lblTitle = cell.viewWithTag(4)as? UILabel{
                lblTitle.text = json.value(forKey: "ticket_message")as? String
            }
            
            if let lblCreatedAt = cell.viewWithTag(5)as? UILabel{
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 0{
                        lblCreatedAt.text = "Pending  \(self.getDate(dateString: json.value(forKey: "updated_at")as! String))"
                    }
                    else if status == 1{
                        lblCreatedAt.text = "Answered  \(self.getDate(dateString: json.value(forKey: "updated_at")as! String))"
                    }
                    else{
                        lblCreatedAt.text = "Closed  \(self.getDate(dateString: json.value(forKey: "updated_at")as! String))"
                    }
                    
                }
            }
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let json = self.arrayOfTickets.object(at: indexPath.row)as! NSDictionary
        let ticket_id = json.value(forKey: "_id")as! String
        
        if let status = json.value(forKey: STATUS)as? Int{
            if status == 0{
                UserDefaults.standard.set(0, forKey: "status")
            }
            else if status == 1{
                UserDefaults.standard.set(1, forKey: "status")
            }
            else{
               UserDefaults.standard.set(2, forKey: "status")
            }
        }
        
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "MyTicketMessageVC")as! MyTicketMessageVC
        nextVC.ticketID = String(ticket_id)
        navigationController?.pushViewController(nextVC, animated: true)
        
    }
    
    
    
    
    func getDate(dateString:String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let showDate = inputFormatter.date(from: dateString)
        inputFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        let resultString = inputFormatter.string(from: showDate!)
        return resultString
    }
    
    func fetchTickets(){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kMyTicketList)
        print(url)
        
        manager.get(url, parameters: nil, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                        if let tickets = json.value(forKey: "tickets")as? NSArray{
                            for dic in tickets{
                               self.arrayOfTickets.add(dic as! NSDictionary)
                            }
                        }
                        
                        SVProgressHUD.dismiss()
                        self.tblView.reloadData()
                        
                    }else{
                        SVProgressHUD.dismiss()
                        self.tblView.isHidden = true
                        self.lblNoTickets.isHidden = false
                    }
                }
                
            } catch {
                SVProgressHUD.dismiss()
                alert(title: "Server didnt get any responding", msg: "Please try again")
                print("error getting string: \(error)")
            }
            
        }, failure: { (operation, error) in
            if InternetReachability.isConnectedToNetwork(){
                giveMeFailure(error: error as NSError, completionHandler: {
                    isTokedUpdated in
                    if isTokedUpdated == true{
                       self.fetchTickets()
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
        
    }
    

    
    
}
