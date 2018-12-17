//
//  CreateTicketVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import SVProgressHUD
import AFNetworking

class CreateTicketVC: UIViewController,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var noteView: UIView!
    @IBOutlet weak var attechmentView: UIView!
    @IBOutlet weak var btnAttechment: UIButton!
    @IBOutlet weak var txtSelectCategory: UITextField!
    @IBOutlet weak var textViewNotes: UITextView!
    
    var TextView_Placeholder = "Write your note here"
    
    var arrayOfCategory:[String] = []
    var arrayOfCategoryID:[String] = []
    
    var catID = ""
    var profileImage = UIImageView()
    var isPhotoSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = "CREATE TICKET"
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        //set corner radious to textField view
        setCornerRadiouToView(viewName:self.categoryView)
        setCornerRadiouToView(viewName:self.noteView)
        setCornerRadiouToView(viewName:self.attechmentView)
        
        //set textField Placeholder color
        setTextFieldPlaceHolderColor(txtName: self.txtSelectCategory, placeHolderText: "Please select category")
        
        //set delegate for textView
        self.textViewNotes.delegate = self
        
        //set placeHolder to textViewComment
        self.textViewNotes.text = TextView_Placeholder
        self.textViewNotes.textColor = UIColor.gray
        
        //fetch category for creating ticket
        self.fetchCategory()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func buttonSelectCategory(_ sender: UIButton) {
        view.endEditing(true)
        
        ActionSheetStringPicker.show(withTitle: "Select category", rows:arrayOfCategory
            , initialSelection: 0, doneBlock: {
                picker, values, indexes in
                
                self.txtSelectCategory.text = "\(indexes!)"

                self.catID = self.arrayOfCategoryID[values]
                
                return
        }, cancel: { ActionMultipleStringCancelBlock in return
            
        }, origin: sender)
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
            self.btnAttechment.setImage(UIImage(named:"ic_attechment_red"), for: .normal)
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func buttonSubmit(_ sender: Any) {
        self.view.endEditing(true)
        
        if self.txtSelectCategory.text!.isEmpty{
            alert(title: "", msg: "Select category")
        }else if self.textViewNotes.text!.isEmpty || self.textViewNotes.text == TextView_Placeholder{
            alert(title: "", msg: "Enter notes")
        }else{
            
            SVProgressHUD.show()
            
            let manager = sessionManager()
            
            let url = kBaseUrl.appending(kCreateTicket)
            
            if self.isPhotoSelected{
                
                let imageData = UIImageJPEGRepresentation(profileImage.image!,0)
                let base64:String = (imageData?.base64EncodedString())!
                
                let param = ["extension":"png","category_id":self.catID,"ticket_message":self.textViewNotes.text!,"base64Data":base64]
                
                
                print(param)
                
                manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
                    
                    do{
                        let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                        
                        print(json)
                        
                        if let status = json.value(forKey: STATUS) as? Int{
                            if status == 1{
                                
                                SVProgressHUD.dismiss()
                                self.txtSelectCategory.text = ""
                                self.catID = ""
                                self.textViewNotes.text = self.TextView_Placeholder
                                self.view.makeToast("Ticket submitted successfully!", duration: 2.0, position: .bottom)
                                self.isPhotoSelected = false
                                self.btnAttechment.setImage(UIImage(named:"ic_attechmet"), for: .normal)
                            }
                        }
                        
                        SVProgressHUD.dismiss()
                       
                    } catch {
                        SVProgressHUD.dismiss()
                        alert(title: "Server didnt get any responding", msg: "Please try again")
                        print("error getting string: \(error)")
                    }
                    
                }, failure: { (operation, error) in
                    SVProgressHUD.dismiss()
                    print(error.localizedDescription)
                })
            }else{
                
                let param = ["extension":"png","category_id":self.catID,"ticket_message":self.textViewNotes.text!,"base64Data":""]
                 print(param)
                
                manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
                    
                    do{
                        let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                        
                        print(json)
                        
                        if let status = json.value(forKey: STATUS) as? Int{
                            if status == 1{
                                
                                SVProgressHUD.dismiss()
                                self.txtSelectCategory.text = ""
                                self.catID = ""
                                self.textViewNotes.text = self.TextView_Placeholder
                                self.view.makeToast("Ticket submitted successfully!", duration: 2.0, position: .bottom)
                                
                            }
                        }
                        
                        SVProgressHUD.dismiss()
                        
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
            
        }
        
    }
    
    
    //MARK: textView delegate methods
    /*===============================================================================
     * Function Purpose: textField Delegate functions for setup PlaceHolder
     * =============================================================================*/
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == self.TextView_Placeholder
        {
            textView.text = ""
            self.textViewNotes.textColor = UIColor.black
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty
        {
            textView.text = self.TextView_Placeholder
            self.textViewNotes.textColor = UIColor.gray
        }
    }
    //=======================end textField Delegate functions======================
    
    
    func fetchCategory(){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kTicketCategoryList)
        
        print(url)
        
        manager.get(url, parameters: nil, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                        if let ticket_categories = json.value(forKey: "ticket_categories") as? NSArray{
                            for j in ticket_categories{
                                if let name = (j as AnyObject).value(forKey: "category_name")as? String{
                                    self.arrayOfCategory.append(name)
                                }
                                if let nameID = (j as AnyObject).value(forKey: "_id")as? String{
                                    self.arrayOfCategoryID.append(nameID)
                                }
                            }
                        }
                        SVProgressHUD.dismiss()
                        
                    }else{
                        SVProgressHUD.dismiss()
                        alert(title: "", msg: json.value(forKey: MSG)as! String)
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
                        self.fetchCategory ()
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
