//
//  AccountStatementVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

class AccountStatementVC: UIViewController,UITableViewDataSource,UITableViewDelegate,URLSessionDownloadDelegate, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblWeekLine: UILabel!
    @IBOutlet weak var lblMonthLine: UILabel!
    @IBOutlet weak var lblAllLine: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var btnPDF: UIButton!
    @IBOutlet weak var lblNoStatementsAvailble: UILabel!
    
    
    
    var arrayOfStatement = NSMutableArray()
    var reversedArray = NSArray()
    
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    var pdfFileName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = "ACCOUNT STATEMENT"
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        //hide back button of navigation bar
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        //set RightBar button icon
        self.setRightIcon()
        
        self.getStatement(type: "/7")
        
        self.tblView.estimatedRowHeight = 45
        self.tblView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*=======================================================================
     * Function Purpose: set Rightbar buttons in NavigationBar
     * ====================================================================*/
    func setRightIcon(){
        //create a rightBar button for Logout
        let button: UIButton = UIButton(type: .custom)
        //set image for button
        button.setImage(UIImage(named: "ic_menu"), for: UIControlState())
        //add function for button
        button.addTarget(self, action: #selector(AccountStatementVC.openDrawer), for: UIControlEvents.touchUpInside)
        //set frame
        if #available(iOS 9.0, *) {
            let widthConstraint = button.widthAnchor.constraint(equalToConstant: 28)
            let heightConstraint = button.heightAnchor.constraint(equalToConstant: 33)
            heightConstraint.isActive = true
            widthConstraint.isActive = true
        }
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func openDrawer(){
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.centerContainer!.toggle(MMDrawerSide.right, animated: true, completion: nil)
    }
    //====================end function for setRightIcons======================
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfStatement.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let json = arrayOfStatement.object(at: indexPath.row)as! NSDictionary
        print(json)
        
        if let lblDate = cell.viewWithTag(1)as? UILabel{
            if let transaction_date = json.value(forKey: "transaction_date")as? Int{
                print(transaction_date)
                lblDate.text = self.getDate(dateString: String(transaction_date))
            }
        }
        
        if let lblDescription = cell.viewWithTag(2)as? UILabel , let lblbitcoinqty = cell.viewWithTag(3)as? UILabel{
            if let transaction_type = json.value(forKey: "transaction_type")as? Int , let transaction_type_dw = json.value(forKey: "transaction_type_dw")as? Int , let txn_type = json.value(forKey: "txn_type")as? Int , let bitcoin_qty = json.value(forKey: "bitcoin_qty")as? String , let transaction_amount = json.value(forKey: "transaction_amount")as? Int{
                
                if txn_type != 0{
                    if let btc_address = json.value(forKey: "btc_address")as? String{
                        if txn_type == 1{
                            lblDescription.text = "Send bitcoins to address :\n\(btc_address)"
                        }else{
                            lblDescription.text = "Received bitcoins to address :\n\(btc_address)"
                        }
                    }
                    lblbitcoinqty.text = "\(bitcoin_qty) ฿"
                }else if transaction_type != 0{
                    if let txn_id = json.value(forKey: "txn_id")as? String{
                        if transaction_type == 1{
                            lblDescription.text = "Bitcoin buy\nOrder no. : \(txn_id)"
                        }else if transaction_type == 2{
                            lblDescription.text = "Bitcoin sell\nOrder no. : \(txn_id)"
                        }
                        else if transaction_type == 3{
                            lblDescription.text = "Bitcoin Bid\nOrder no. : \(txn_id)"
                        }
                        else if transaction_type == 4{
                            lblDescription.text = "Bitcoin Ask\nOrder no. : \(txn_id)"
                        }
                    }
                    lblbitcoinqty.text = "\(bitcoin_qty)"
                }
            }
        }
        
        return cell
    }
    
    func getDate(dateString:String) -> String {
        let time: TimeInterval = Double(dateString)!/1000
        
        let showDate = NSDate(timeIntervalSince1970: time)
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"
        inputFormatter.timeZone = TimeZone.current
        
        let resultString = inputFormatter.string(from: showDate as Date)
        return resultString
    }
    
    
    
    @IBAction func buttonWeek(_ sender: Any) {
        self.lblWeekLine.backgroundColor = UIColor.init(hexString: "FFD700")
        self.lblMonthLine.backgroundColor = UIColor.clear
        self.lblAllLine.backgroundColor = UIColor.clear
        self.getStatement(type: "/7")
    }
    
    @IBAction func buttonMonth(_ sender: Any) {
        self.lblWeekLine.backgroundColor = UIColor.clear
        self.lblMonthLine.backgroundColor = UIColor.init(hexString: "FFD700")
        self.lblAllLine.backgroundColor = UIColor.clear
         self.getStatement(type: "/30")
    }
    
    @IBAction func buttonAll(_ sender: Any) {
        self.lblWeekLine.backgroundColor = UIColor.clear
        self.lblMonthLine.backgroundColor = UIColor.clear
        self.lblAllLine.backgroundColor = UIColor.init(hexString: "FFD700")
         self.getStatement(type: "all")
    }
    
    @IBAction func buttonPDF(_ sender: Any) {
        if self.arrayOfStatement.count == 0{
            self.view.makeToast("No transaction statement available", duration: 2.0, position: .bottom)
        }else{
            self.getStatementPDF(type:"/7")
        }
    }
    
    @IBAction func buttonHandlerTabBar(_ sender: UIButton) {
        if sender.tag == 1{
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC")as! HomeVC
            self.navigationController?.pushViewController(nextVC, animated: false)
        }else if sender.tag == 2{
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SendVC")as! SendVC
            self.navigationController?.pushViewController(nextVC, animated: false)
        }else if sender.tag == 3{
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ReceiveVC")as! ReceiveVC
            self.navigationController?.pushViewController(nextVC, animated: false)
        }else if sender.tag == 4{
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "BidVC")as! BidVC
            self.navigationController?.pushViewController(nextVC, animated: false)
        }else if sender.tag == 5{
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "AskVC")as! AskVC
            self.navigationController?.pushViewController(nextVC, animated: false)
        }
    }
    
    
    func getStatement(type:String){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(type != "all" ? kListStatement + type : kListStatement)
        let param = ["offset":"0","limit":"100"]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        self.arrayOfStatement.removeAllObjects()
                        if let statements = json.value(forKey: "statements")as? NSArray{
                            print(statements)
                            for dic in statements{
                                print(dic)
                                if let transaction_type = (dic as AnyObject).value(forKey: "transaction_type")as? Int{
                                    if transaction_type != 0 {
                                        self.arrayOfStatement.add(dic as! NSDictionary)
                                    }
                                }
                                
                                if let txn_type = (dic as AnyObject).value(forKey: "txn_type")as? Int{
                                    if txn_type != 0 {
                                        self.arrayOfStatement.add(dic as! NSDictionary)
                                    }
                                }
                                
                            }
                        }
                        
                        if self.arrayOfStatement.count == 0{
                            self.tblView.isHidden = true
                            self.topView.isHidden = true
                            self.lblNoStatementsAvailble.isHidden = false
                            SVProgressHUD.dismiss()
                        }else{
                            self.tblView.isHidden = false
                            self.topView.isHidden = false
                            self.lblNoStatementsAvailble.isHidden = true
                            SVProgressHUD.dismiss()
                            self.tblView.reloadData()
                        }
                    }
                    SVProgressHUD.dismiss()
                }
                
            } catch {
                SVProgressHUD.dismiss()
                alert(title: "Server didnt get any responding", msg: "Please try again")
                print("error getting string: \(error)")
            }
            
        }, failure: { (operation, error) in
            SVProgressHUD.dismiss()
            print(error.localizedDescription)
        })
        
    }
    
    func getStatementPDF(type:String){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        print(type)
        let url = kBaseUrl.appending(kGetStatementPDF).appending(type)
        
        let param = ["offset":"0","limit":"100"]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        if let download_url = json.value(forKey: "download_url")as? String{
                           self.pdfDownload(pdfLink: download_url)
                        }
                    }
                    SVProgressHUD.dismiss()
                }
                
            } catch {
                SVProgressHUD.dismiss()
                alert(title: "Server didnt get any responding", msg: "Please try again")
                print("error getting string: \(error)")
            }
            
        }, failure: { (operation, error) in
            SVProgressHUD.dismiss()
            print(error.localizedDescription)
        })
        
    }
    
    
    func pdfDownload(pdfLink:String){
        let url = URL(string: pdfLink)!
        self.pdfFileName = pdfLink.replacingOccurrences(of: "http://104.154.161.69:7878/pdf/", with: "")
        downloadTask = backgroundSession.downloadTask(with: url)
        downloadTask.resume()
        
    }
    
    
    func showFileWithPath(path: String){
        let isFileFound:Bool? = FileManager.default.fileExists(atPath: path)
        print(path)
        if isFileFound == true{
            let viewer = UIDocumentInteractionController(url: URL(fileURLWithPath: path))
            print(viewer)
            viewer.delegate = self
            viewer.presentPreview(animated: true)
        }
    }
    
    //MARK: URLSessionDownloadDelegate
    // 1
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL){
        
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = FileManager()
        let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appendingFormat("/\(self.pdfFileName)"))
        
        if fileManager.fileExists(atPath: destinationURLForFile.path){
            showFileWithPath(path: destinationURLForFile.path)
        }
        else{
            do {
                try fileManager.moveItem(at: location, to: destinationURLForFile)
                // show file
                showFileWithPath(path: destinationURLForFile.path)
            }catch{
                print("An error occurred while moving file to destination url")
            }
        }
    }
    
    //MARK: UIDocumentInteractionControllerDelegate
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController
    {
        return self
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
