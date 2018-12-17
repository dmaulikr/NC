//
//  MyTicketMessageVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import SVProgressHUD
import AFNetworking

class MyTicketMessageVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    
    
    @IBOutlet weak var txtEnterMessage: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var lblNoMessageFound: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var imgAttechment: UIImageView!
    @IBOutlet weak var viewDisable: UIView!
    
    var ticketID = ""
    var arrayOfTicketsMessages = NSMutableArray()
    var isPhotoSelected = false
    var profileImage = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = "APP TICKET"
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
        
        self.bottomView.layer.cornerRadius = 3
        self.bottomView.clipsToBounds = true
        
        //set textField Placeholder color
        setTextFieldPlaceHolderColor(txtName: self.txtEnterMessage, placeHolderText: "Enter ticket message")
        
        self.fetchTicketsMessages()

        if let status = UserDefaults.standard.value(forKey: "status")as? Int{
            if status == 0{
                viewDisable.isHidden = true
            }
            else if status == 1{
                viewDisable.isHidden = true
            }
            else{
                //viewDisable.isHidden = false
            }
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func buttonAttechment(_ sender: Any) {
        view.endEditing(true)
        
        // Create the AlertController and add its actions like button in ActionSheet
        let actionSheetController = UIAlertController(title: "", message: "Choose Ticket", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Gallery", style: .default) { action -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            OperationQueue.main.addOperation({
                self.present(imagePicker, animated: true, completion: nil)
            })
        }
        actionSheetController.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Camera", style: .default) { action -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                OperationQueue.main.addOperation({
                    self.present(imagePicker, animated: true, completion: nil)
                })
                
            }else
            {
                let alert = UIAlertView(title: "Warning", message: "You don't have camera", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
        actionSheetController.addAction(deleteActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImage.image = pickedImage
            self.isPhotoSelected = true
            self.imgAttechment.image = UIImage.init(named: "ic_attechment_red")
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonSend(_ sender: Any) {
        view.endEditing(true)
        
        if self.txtEnterMessage.text!.isEmpty{
            self.view.makeToast("Enter message", duration: 2.0, position: .bottom)
        }else{
            self.createTicketsMessages()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfTicketsMessages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let json = self.arrayOfTicketsMessages.object(at: indexPath.row)as! NSDictionary
        
        print(json)
        
        let message_by = json.value(forKey: "message_by")as! Int
        
        if message_by == 2{
            
            let file_name = json.value(forKey: "file_name")as! String
            
            if file_name != "" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "imageCellLeft", for: indexPath)
                
                if let lblTitle = cell.viewWithTag(1)as? UILabel{
                    lblTitle.text = json.value(forKey: "message")as? String
                }
                
                if let lblCreatedAt = cell.viewWithTag(2)as? UILabel{
                    let dt =  json.value(forKey: "created_at")as? String
                    lblCreatedAt.text = self.elapsedTime(dateValue: dt!)
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "textCellLeft", for: indexPath)
                
                if let lblTitle = cell.viewWithTag(4)as? UILabel{
                    lblTitle.text = json.value(forKey: "message")as? String
                }
                
                if let lblCreatedAt = cell.viewWithTag(5)as? UILabel{
                    let dt =  json.value(forKey: "created_at")as? String
                    lblCreatedAt.text = self.elapsedTime(dateValue: dt!)
                }
                
                return cell
            }
            
        }else{
            
            let file_name = json.value(forKey: "file_name")as! String
            
            if file_name != "" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "imageCellRight", for: indexPath)
                
                if let lblTitle = cell.viewWithTag(6)as? UILabel{
                    lblTitle.text = json.value(forKey: "message")as? String
                }
                
                if let lblCreatedAt = cell.viewWithTag(7)as? UILabel{
                    let dt =  json.value(forKey: "created_at")as? String
                    lblCreatedAt.text = self.elapsedTime(dateValue: dt!)
                }
                
                if let tiketImage = cell.viewWithTag(8)as? UIImageView{
                    if let link = json.value(forKey: "file_name")as? String{
                        let url = URL(string: link)
                        tiketImage.sd_setImage(with: url) { (image, error, imageCacheType, imageUrl) in }
                        tiketImage.layer.cornerRadius = 5
                        tiketImage.clipsToBounds = true
                    }
                }
                
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "textCellRight", for: indexPath)
                
                if let lblTitle = cell.viewWithTag(9)as? UILabel{
                    lblTitle.text = json.value(forKey: "message")as? String
                }
                
                if let lblCreatedAt = cell.viewWithTag(10)as? UILabel{
                    let dt =  json.value(forKey: "created_at")as? String
                    lblCreatedAt.text = self.elapsedTime(dateValue: dt!)
                }
                
                return cell
            }
            
        }
    }
    
    
    
    
    func getDate(dateString:String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let showDate = inputFormatter.date(from: dateString)
        inputFormatter.dateFormat = "dd-MM-yyyy"
        let resultString = inputFormatter.string(from: showDate!)
        return resultString
    }
    
    func fetchTicketsMessages(){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kTicketMessageList)
        let param = ["ticket_id":self.ticketID]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                        if let tickets = json.value(forKey: "ticket")as? NSDictionary{
                            if let message_list = tickets.value(forKey: "message_list")as? NSArray{
                                self.arrayOfTicketsMessages.removeAllObjects()
                                for dic in message_list{
                                    self.arrayOfTicketsMessages.add(dic as! NSDictionary)
                                }
                            }
                        }
                        
                        if self.arrayOfTicketsMessages.count == 0{
                            SVProgressHUD.dismiss()
                            self.tblView.isHidden = true
                            self.lblNoMessageFound.isHidden = false
                        }else{
                            SVProgressHUD.dismiss()
                            self.tblView.isHidden = false
                            self.lblNoMessageFound.isHidden = true
                            self.tblView.reloadData()
                            let indexPath = NSIndexPath(row: self.arrayOfTicketsMessages.count - 1, section: 0)
                            self.tblView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: false)
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
            if InternetReachability.isConnectedToNetwork(){
                giveMeFailure(error: error as NSError, completionHandler: {
                    isTokedUpdated in
                    if isTokedUpdated == true{
                        self.fetchTicketsMessages()
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
        
    }
    
    func elapsedTime (dateValue:String) -> String
    {
        //just to create a date that is before the current time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        let before = dateFormatter.date(from: dateValue)!
        
        //getting the current time
        let now = Date()
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1 //increase it if you want more precision
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute]
        formatter.includesApproximationPhrase = false //to write "About" at the beginning
        
        
        let formatString = NSLocalizedString("%@ ago", comment: "Used to say how much time has passed. e.g. '2 hours ago'")
        let timeString = formatter.string(from: before, to: now)
        return String(format: formatString, timeString!)
    }
    
    func createTicketsMessages(){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kCreateTicketMessage)
        
        var base64 = ""
        if self.isPhotoSelected{
            let imageData = UIImageJPEGRepresentation(profileImage.image!,0)
            base64 = (imageData?.base64EncodedString())!
        }
        
        let param = ["extension":"png","ticket_id":self.ticketID,"message":self.txtEnterMessage.text!,"base64Data": self.isPhotoSelected == true ? base64 : ""]
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        self.txtEnterMessage.text = ""
                        self.isPhotoSelected = false
                        self.imgAttechment.image = UIImage.init(named: "ic_attechmet")
                        self.fetchTicketsMessages()
                    }
                }
                
                SVProgressHUD.dismiss()
                
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
                        self.createTicketsMessages()
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
