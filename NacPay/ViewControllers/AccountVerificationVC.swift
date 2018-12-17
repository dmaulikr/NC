//
//  AccountVerificationVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import Photos
import AFNetworking
import SVProgressHUD


class AccountVerificationVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    
    @IBOutlet weak var IDCardView: UIView!
    @IBOutlet weak var bankDetailView: UIView!
    @IBOutlet weak var otherDetailView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtPANCardNumber: UITextField!
    @IBOutlet weak var txtBirthdate: UITextField!
    @IBOutlet weak var txtGender: UITextField!
    @IBOutlet weak var txtIFSCCode: UITextField!
    @IBOutlet weak var txtBankName: UITextField!
    @IBOutlet weak var txtBranchName: UITextField!
    @IBOutlet weak var txtAccounHolderName: UITextField!
    @IBOutlet weak var txtAccounNumber: UITextField!
    @IBOutlet weak var txtConformAccounNumber: UITextField!
    @IBOutlet weak var txtOtherIDNumber: UITextField!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var firstNameVew: UIView!
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var PANCardView: UIView!
    @IBOutlet weak var bdayView: UIView!
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var IFSCView: UIView!
    @IBOutlet weak var bankNameView: UIView!
    @IBOutlet weak var branchNameView: UIView!
    @IBOutlet weak var accountNameView: UIView!
    @IBOutlet weak var accountNumberView: UIView!
    @IBOutlet weak var confirmAccountNumberView: UIView!
    @IBOutlet weak var otherIDView: UIView!
    @IBOutlet weak var otherProfileViwe: UIView!
    @IBOutlet weak var lblIDCardLine: UILabel!
    @IBOutlet weak var lblBankDetailLine: UILabel!
    @IBOutlet weak var lblOtherDetailLine: UILabel!
    @IBOutlet weak var btnBday: UIButton!
    @IBOutlet weak var btnGender: UIButton!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnGallery: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnOtherSubmit: UIButton!
    @IBOutlet weak var otherProofImage: UIImageView!
    @IBOutlet weak var btnOtherCamera: UIButton!
    @IBOutlet weak var btnOtherGallery: UIButton!
    @IBOutlet weak var backImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var backImageView: UIView!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var buttonBackCamera: UIButton!
    @IBOutlet weak var buttonBackGallery: UIButton!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtState: UITextField!
    @IBOutlet weak var txtPincode: UITextField!
    @IBOutlet weak var btnIDnext: UIButton!
    @IBOutlet weak var btnNextSubmit: UIButton!
    
    
    var isPhotoSelected = false
    var isOther = false
    var isOtherIDPhotoSelected = false
    var isOtherDetailsUpdates = false
    var isVerify = false
    var isType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = "ACCOUNT VERIFICATION"
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
        
        btnSubmit.layer.cornerRadius = 10
        btnSubmit.layer.borderWidth = 1
        btnSubmit.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        btnIDnext.layer.cornerRadius = 10
        btnIDnext.layer.borderWidth = 1
        btnIDnext.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor

        btnOtherSubmit.layer.cornerRadius = 10
        btnOtherSubmit.layer.borderWidth = 1
        btnOtherSubmit.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor


        
        //set corner radious to textField view
        setCornerRadiouToView(viewName:self.profileView)
        setCornerRadiouToView(viewName:self.firstNameVew)
        setCornerRadiouToView(viewName:self.lastNameView)
        setCornerRadiouToView(viewName:self.PANCardView)
        setCornerRadiouToView(viewName:self.bdayView)
        setCornerRadiouToView(viewName:self.genderView)
        setCornerRadiouToView(viewName:self.IFSCView)
        setCornerRadiouToView(viewName:self.bankNameView)
        setCornerRadiouToView(viewName:self.branchNameView)
        setCornerRadiouToView(viewName:self.accountNameView)
        setCornerRadiouToView(viewName:self.accountNumberView)
        setCornerRadiouToView(viewName:self.confirmAccountNumberView)
        setCornerRadiouToView(viewName:self.otherProfileViwe)
        setCornerRadiouToView(viewName:self.otherIDView)
        setCornerRadiouToView(viewName: self.backImageView)
    
        
        //set textField Placeholder color
        setTextFieldPlaceHolderColor(txtName: self.txtFirstName, placeHolderText: "First name")
        setTextFieldPlaceHolderColor(txtName: self.txtLastName, placeHolderText: "Last name")
        setTextFieldPlaceHolderColor(txtName: self.txtPANCardNumber, placeHolderText: "PAN card number")
        setTextFieldPlaceHolderColor(txtName: self.txtBirthdate, placeHolderText: "Birthdate")
        setTextFieldPlaceHolderColor(txtName: self.txtGender, placeHolderText: "Gender")
        setTextFieldPlaceHolderColor(txtName: self.txtIFSCCode, placeHolderText: "IFSC code")
        setTextFieldPlaceHolderColor(txtName: self.txtBankName, placeHolderText: "Bank name")
        setTextFieldPlaceHolderColor(txtName: self.txtBranchName, placeHolderText: "Branch name")
        setTextFieldPlaceHolderColor(txtName: self.txtAccounHolderName, placeHolderText: "Account holder name")
        setTextFieldPlaceHolderColor(txtName: self.txtAccounNumber, placeHolderText: "Account number")
        setTextFieldPlaceHolderColor(txtName: self.txtConformAccounNumber, placeHolderText: "Confirm account number")
        setTextFieldPlaceHolderColor(txtName: self.txtOtherIDNumber, placeHolderText: "Aadhaar Number")
        setTextFieldPlaceHolderColor(txtName: self.txtPincode, placeHolderText: "Pincode")
        setTextFieldPlaceHolderColor(txtName: self.txtAddress, placeHolderText: "Address")
        setTextFieldPlaceHolderColor(txtName: self.txtState, placeHolderText: "State")

        self.setupData()

        // Do any additional setup after loading the view.
    }
    
    func setupData(){
        
        if let firstname = UserDefaults.standard.value(forKey: FIRSTNAME)as? String{
            print(firstname)
            self.txtFirstName.text = firstname
        }
        
        if let lastname = UserDefaults.standard.value(forKey: LASTNAME)as? String{
            print(lastname)
            self.txtLastName.text = lastname
        }
        
        if let pan_card_no = UserDefaults.standard.value(forKey: PAN_CARD_NUMBER)as? String{
            print(pan_card_no)
            self.txtPANCardNumber.text = pan_card_no
        }
        
        if let birthdate = UserDefaults.standard.value(forKey: BIRTHDATE)as? String{
            print(birthdate)
            self.txtBirthdate.text = birthdate
        }
        
        if let gender = UserDefaults.standard.value(forKey: GENDER)as? String{
            print(gender)
            self.txtGender.text = gender
        }
        
        if let ifsc_code = UserDefaults.standard.value(forKey: IFSC_CODE)as? String{
            print(ifsc_code)
            self.txtIFSCCode.text = ifsc_code
        }
        
        if let bank_name = UserDefaults.standard.value(forKey: BANK_NAME)as? String{
            print(bank_name)
            self.txtBankName.text = bank_name
        }
        
        if let branch_name = UserDefaults.standard.value(forKey: BRANCH_NAME)as? String{
            print(branch_name)
            self.txtBranchName.text = branch_name
        }
        
        if let account_holder_name = UserDefaults.standard.value(forKey: ACCOUNT_HOLDER_NAME)as? String{
            print(account_holder_name)
            self.txtAccounHolderName.text = account_holder_name
        }
        
        if let account_number = UserDefaults.standard.value(forKey: ACCOUNT_NUMBER)as? String{
            print(account_number)
            self.txtAccounNumber.text = account_number
            self.txtConformAccounNumber.text = account_number
        }
        
        if let pan_card_photo = UserDefaults.standard.value(forKey: PAN_CARD_PHOTO)as? String{
            self.isPhotoSelected = true
            let link = "\(imageUpload)\(pan_card_photo)"
            let url = URL(string: link)
            profileImage.sd_setImage(with: url) { (image, error, imageCacheType, imageUrl) in }
        }
        
        if let other_id_proof_no = UserDefaults.standard.value(forKey: OTHER_ID_PROOF_NO)as? String{
            self.txtOtherIDNumber.text = other_id_proof_no
        }
        
        if let other_id_proof_no_photo = UserDefaults.standard.value(forKey: OTHER_ID_PROOF_NO_PHOTO)as? String{
            let url = URL(string: other_id_proof_no_photo)
            otherProofImage.sd_setImage(with: url) { (image, error, imageCacheType, imageUrl) in }
        }
        
        if let other_id_proof_no_photo2 = UserDefaults.standard.value(forKey: OTHER_ID_PROOF_NO_PHOTO_2)as? String{
            let url = URL(string: other_id_proof_no_photo2)
            backImage.sd_setImage(with: url) { (image, error, imageCacheType, imageUrl) in }
        }
        
        if let address = UserDefaults.standard.value(forKey: AADHAAR_ADDRESS)as? String{
            txtAddress.text = address
        }
        
        if let isVal = UserDefaults.standard.value(forKey: IS_VERIFIED) as? Int{
            if isVal == 1{
                
                self.isVerify = true
                
                //set textField Placeholder color
                self.txtFirstName.isUserInteractionEnabled = false
                self.txtLastName.isUserInteractionEnabled = false
                self.txtPANCardNumber.isUserInteractionEnabled = false
                self.txtBirthdate.isUserInteractionEnabled = false
                self.btnBday.isUserInteractionEnabled = false
                self.txtGender.isUserInteractionEnabled = false
                self.btnGender.isUserInteractionEnabled = false
                self.txtIFSCCode.isUserInteractionEnabled = false
                self.txtBankName.isUserInteractionEnabled = false
                self.txtBranchName.isUserInteractionEnabled = false
                self.txtAccounHolderName.isUserInteractionEnabled = false
                self.txtAccounNumber.isUserInteractionEnabled = false
                self.txtConformAccounNumber.isUserInteractionEnabled = false
                self.btnCamera.isUserInteractionEnabled = false
                self.btnGallery.isUserInteractionEnabled = false
                self.buttonBackCamera.isUserInteractionEnabled = false
                self.buttonBackGallery.isUserInteractionEnabled = false
                txtState.isUserInteractionEnabled = false
                txtAddress.isUserInteractionEnabled = false
                txtPincode.isUserInteractionEnabled = false
                
                if let otherNumber = UserDefaults.standard.value(forKey: OTHER_ID_PROOF_NO) as? String , let otherPhoto = UserDefaults.standard.value(forKey: OTHER_ID_PROOF_NO_PHOTO) as? String{
                    if otherNumber != "" && otherPhoto != ""{
                        self.btnOtherSubmit.isUserInteractionEnabled = false
                        self.txtOtherIDNumber.isUserInteractionEnabled = false
                        self.btnOtherCamera.isUserInteractionEnabled = false
                        self.btnOtherGallery.isUserInteractionEnabled = false
                        self.isOtherDetailsUpdates = true
                    }else{
                        self.isOtherDetailsUpdates = false
                    }
                }
            }else{
                self.isVerify = false
            }
        }
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
        button.addTarget(self, action: #selector(AccountVerificationVC.openDrawer), for: UIControlEvents.touchUpInside)
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

    
    
    @IBAction func buttonIDCard(_ sender: UIButton) {
        self.setupPANCard()
    }
    
    func setupPANCard(){
        self.isOther = false
        self.IDCardView.isHidden = false
        self.bankDetailView.isHidden = true
        self.otherDetailView.isHidden = true
        self.lblIDCardLine.backgroundColor = UIColor.init(hexString: "FFD700")
        self.lblBankDetailLine.backgroundColor = UIColor.clear
        self.lblOtherDetailLine.backgroundColor = UIColor.clear
    }
    
    @IBAction func buttonBankDetail(_ sender: Any) {
        self.setupBankDetails()
    }
    
    func setupBankDetails(){
        self.isOther = false
        self.IDCardView.isHidden = true
        self.bankDetailView.isHidden = false
        self.otherDetailView.isHidden = true
        self.lblIDCardLine.backgroundColor = UIColor.clear
        self.lblBankDetailLine.backgroundColor = UIColor.init(hexString: "FFD700")
        self.lblOtherDetailLine.backgroundColor = UIColor.clear
    }
    
    @IBAction func buttonOther(_ sender: Any) {
       self.setupOtherDetails()
    }
    
    func setupOtherDetails(){
        self.isOther = true
        self.IDCardView.isHidden = true
        self.bankDetailView.isHidden = true
        self.otherDetailView.isHidden = false
        self.lblIDCardLine.backgroundColor = UIColor.clear
        self.lblBankDetailLine.backgroundColor = UIColor.clear
        self.lblOtherDetailLine.backgroundColor = UIColor.init(hexString: "FFD700")
    }
    
    
    
    @IBAction func buttonCameraAndGallery(_ sender: UIButton) {
        //hide keyboard if open
        self.view.endEditing(true)
        self.isType = "1"
        if sender.tag == 1{
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
        }else{
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            OperationQueue.main.addOperation({
                self.present(imagePicker, animated: true, completion: nil)
            })
        }
    }
    
    
    @IBAction func buttonOtherCameraAndGallery(_ sender: UIButton) {
        //hide keyboard if open
        self.view.endEditing(true)
        self.isType = "2"
        if sender.tag == 1{
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
        }else{
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            OperationQueue.main.addOperation({
                self.present(imagePicker, animated: true, completion: nil)
            })
        }
    }
    
    
    @IBAction func buttonBackCamera(_ sender: UIButton) {
        //hide keyboard if open
        self.view.endEditing(true)
        self.isType = "3"
        if sender.tag == 1{
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
        }else{
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            OperationQueue.main.addOperation({
                self.present(imagePicker, animated: true, completion: nil)
            })
        }
    }
    
    
    
    @IBAction func buttonSelectBirthday(_ sender: UIButton) {
        view.endEditing(true)
        let datePicker = ActionSheetDatePicker(title: "Select Date", datePickerMode: .date, selectedDate: NSDate() as Date!, doneBlock: { (picker, selectedValueIndex, selectedValue) -> Void in
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-YYYY"
            self.txtBirthdate.text = dateFormatter.string(from: (selectedValueIndex as! NSDate) as Date)
            
        }, cancel: { (picker) -> Void in
            
        }, origin: sender)
        
        datePicker?.maximumDate = Date()
        
        datePicker?.show()
        
    }
    
    
   
    @IBAction func buttonGender(_ sender: UIButton) {
        view.endEditing(true)
        ActionSheetStringPicker.show(withTitle: "Gender", rows:["Male","Female"]
            , initialSelection: 0, doneBlock: {
                picker, values, indexes in
                
                self.txtGender.text = "\(indexes!)"
                
                return
        }, cancel: { ActionMultipleStringCancelBlock in return
            
        }, origin: sender)
    }
    
    @IBAction func buttonNext(_ sender: Any) {
        self.IDCardView.isHidden = true
        self.bankDetailView.isHidden = false
        self.lblIDCardLine.backgroundColor = UIColor.clear
        self.lblBankDetailLine.backgroundColor = UIColor.init(hexString: "FFD700")
    }
    
    @IBAction func buttonSubmit(_ sender: Any) {
        self.isOther = true
        self.IDCardView.isHidden = true
        self.bankDetailView.isHidden = true
        self.otherDetailView.isHidden = false
        self.lblIDCardLine.backgroundColor = UIColor.clear
        self.lblBankDetailLine.backgroundColor = UIColor.clear
        self.lblOtherDetailLine.backgroundColor = UIColor.init(hexString: "FFD700")
    }

    @IBAction func buttonOtherSubmit(_ sender: Any) {
        
        view.endEditing(true)
        
        if !self.isPhotoSelected{
            self.setupPANCard()
            self.view.makeToast("Please provice PAN card photo", duration: 2.0, position: .bottom)
        }else if self.txtFirstName.text!.isEmpty{
            self.setupPANCard()
            self.view.makeToast("Please enter first name", duration: 2.0, position: .bottom)
        }else if self.txtLastName.text!.isEmpty{
            self.setupPANCard()
            self.view.makeToast("Please enter last name", duration: 2.0, position: .bottom)
        }else if self.txtPANCardNumber.text!.isEmpty{
            self.setupPANCard()
            self.view.makeToast("Please enter PAN card number", duration: 2.0, position: .bottom)
        }else if self.txtBirthdate.text!.isEmpty{
            self.setupPANCard()
            self.view.makeToast("Please select birthdate", duration: 2.0, position: .bottom)
        }else if self.txtGender.text!.isEmpty{
            self.setupPANCard()
            self.view.makeToast("Please select gender", duration: 2.0, position: .bottom)
        }else if self.txtIFSCCode.text!.isEmpty{
            self.setupBankDetails()
            self.view.makeToast("Please enter IFSC code", duration: 2.0, position: .bottom)
        }else if self.txtBankName.text!.isEmpty{
            self.setupBankDetails()
            self.view.makeToast("Please enter bank name", duration: 2.0, position: .bottom)
        }else if self.txtBranchName.text!.isEmpty{
            self.setupBankDetails()
            self.view.makeToast("Please enter branch name", duration: 2.0, position: .bottom)
        }else if self.txtAccounHolderName.text!.isEmpty{
            self.setupBankDetails()
            self.view.makeToast("Please enter account holder name", duration: 2.0, position: .bottom)
        }else if self.txtAccounNumber.text!.isEmpty{
            self.setupBankDetails()
            self.view.makeToast("Please enter account number", duration: 2.0, position: .bottom)
        }else if self.txtConformAccounNumber.text!.isEmpty{
            self.setupBankDetails()
            self.view.makeToast("Please confirm account number", duration: 2.0, position: .bottom)
        }else if self.txtConformAccounNumber.text! != self.txtAccounNumber.text!{
            self.setupBankDetails()
            self.view.makeToast("Account number is not match", duration: 2.0, position: .bottom)
        }else if !self.isOtherIDPhotoSelected{
            self.view.makeToast("Please provice other id photo", duration: 2.0, position: .bottom)
        }else if self.txtOtherIDNumber.text!.isEmpty{
            self.view.makeToast("Please enter other id number", duration: 2.0, position: .bottom)
        }else if self.txtPincode.text!.isEmpty{
            self.view.makeToast("Please enter Pincode", duration:2.0, position: .bottom)
        }else if self.txtAddress.text!.isEmpty{
            self.view.makeToast("Please enter Address", duration:2.0, position: .bottom)
        }else if self.txtState.text!.isEmpty{
            self.view.makeToast("Please enter State", duration:2.0, position: .bottom)
        }
        
        else{
            if self.isVerify{
                if !self.isOtherDetailsUpdates{
                    self.updateProofIDDetails()
                }
            }else{
                self.accountVerification()
            }
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
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            if self.isType == "1"{
                self.profileImage.image = pickedImage
                self.isPhotoSelected = true
            }else if self.isType == "2"{
                self.otherProofImage.image = pickedImage
                self.isOtherIDPhotoSelected = true
            }else if self.isType == "3"{
                self.backImage.image = pickedImage
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func accountVerification(){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let imageData = UIImageJPEGRepresentation(profileImage.image!,0)
        let base64:String = (imageData?.base64EncodedString())!
        
        let imageData1 = UIImageJPEGRepresentation(otherProofImage.image!,0)
        let base641:String = (imageData1?.base64EncodedString())!
        
        let imageData2 = UIImageJPEGRepresentation(backImage.image!,0)
        let base6412:String = (imageData2?.base64EncodedString())!
        
        let url = kBaseUrl.appending(kAccountVerification)
        let param = ["extension":"png","firstname":self.txtFirstName.text!,"lastname":self.txtLastName.text!,"gender":self.txtGender.text!,"birthdate":self.txtBirthdate.text!,"pan_card_no":self.txtPANCardNumber.text!,"ifsc_code":self.txtIFSCCode.text!,"branch_name":self.txtBranchName.text!,"bank_name":self.txtBankName.text!,"account_holder_name":self.txtAccounHolderName.text!,"account_number":self.txtAccounNumber.text!,"base64Data":base64,"aadhaar_extension_1":"png","aadhaar_card_no":self.txtOtherIDNumber.text!,"aadhaar_base64Data_1":base641,"aadhaar_base64Data_2":base6412,"aadhaar_extension_2":"png","aadhaar_card_address":self.txtAddress.text!,"aadhaar_card_state": self.txtState.text!,"aadhaar_card_pincode":self.txtPincode.text!]
        
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                        if let user = json.value(forKey: USER) as? NSDictionary{
                            
                            if let account_holder_name = user.value(forKey: ACCOUNT_HOLDER_NAME)as? String{
                                UserDefaults.standard.set(account_holder_name, forKey: ACCOUNT_HOLDER_NAME)
                            }
                            
                            if let account_number = user.value(forKey: ACCOUNT_NUMBER)as? String{
                                UserDefaults.standard.set(account_number, forKey: ACCOUNT_NUMBER)
                            }
                            
                            if let balance_btc = user.value(forKey: BALANCE_BTC)as? String{
                                UserDefaults.standard.set(balance_btc, forKey: BALANCE_BTC)
                            }
                            
                            if let balance_rs = user.value(forKey: BALANCE_RS)as? String{
                                UserDefaults.standard.set(balance_rs, forKey: BALANCE_RS)
                            }
                            
                            if let bank_name = user.value(forKey: BANK_NAME)as? String{
                                UserDefaults.standard.set(bank_name, forKey: BANK_NAME)
                            }
                            
                            if let birthdate = user.value(forKey: BIRTHDATE)as? String{
                                UserDefaults.standard.set(birthdate, forKey: BIRTHDATE)
                            }
                            
                            if let branch_name = user.value(forKey: BRANCH_NAME)as? String{
                                UserDefaults.standard.set(branch_name, forKey: BRANCH_NAME)
                            }
                            
                            if let email = user.value(forKey: EMAIL)as? String{
                                UserDefaults.standard.set(email, forKey: EMAIL)
                            }
                            
                            if let firstname = user.value(forKey: FIRSTNAME)as? String{
                                UserDefaults.standard.set(firstname, forKey: FIRSTNAME)
                            }
                            
                            if let frozen_btc = user.value(forKey: FROZEN_BTC)as? String{
                                UserDefaults.standard.set(frozen_btc, forKey: FROZEN_BTC)
                            }
                            
                            if let gender = user.value(forKey: GENDER)as? String{
                                UserDefaults.standard.set(gender, forKey: GENDER)
                            }
                            
                            if let ifsc_code = user.value(forKey: IFSC_CODE)as? String{
                                UserDefaults.standard.set(ifsc_code, forKey: IFSC_CODE)
                            }
                            
                            if let is_active = user.value(forKey: IS_ACTIVE)as? Int{
                                UserDefaults.standard.set(is_active, forKey: IS_ACTIVE)
                            }
                            
                            if let is_email_verified = user.value(forKey: IS_EMAIL_VERIFIED)as? Int{
                                UserDefaults.standard.set(is_email_verified, forKey: IS_EMAIL_VERIFIED)
                            }
                            
                            if let is_phone_verified = user.value(forKey: IS_PHONE_VERIFIED)as? Int{
                                UserDefaults.standard.set(is_phone_verified, forKey: IS_PHONE_VERIFIED)
                            }
                            
                            if let is_verified = user.value(forKey: IS_VERIFIED)as? Int{
                                UserDefaults.standard.set(is_verified, forKey: IS_VERIFIED)
                            }
                            
                            if let lastname = user.value(forKey: LASTNAME)as? String{
                                UserDefaults.standard.set(lastname, forKey: LASTNAME)
                            }
                            
                            if let lock_btc = user.value(forKey: LOCK_BTC)as? Float{
                                UserDefaults.standard.set(lock_btc, forKey: LOCK_BTC)
                            }
                            
                            if let lock_rs = user.value(forKey: LOCK_RS)as? String{
                                UserDefaults.standard.set(lock_rs, forKey: LOCK_RS)
                            }
                            
                            if let name = user.value(forKey: NAME)as? String{
                                UserDefaults.standard.set(name, forKey: NAME)
                            }
                            
                            if let pan_card_no = user.value(forKey: PAN_CARD_NUMBER)as? String{
                                UserDefaults.standard.set(pan_card_no, forKey: PAN_CARD_NUMBER)
                            }
                            
                            if let pan_card_photo = user.value(forKey: PAN_CARD_PHOTO)as? String{
                                UserDefaults.standard.set(pan_card_photo, forKey: PAN_CARD_PHOTO)
                            }
                            
                            if let phone_number = user.value(forKey: PHONE_NUMBER)as? String{
                                UserDefaults.standard.set(phone_number, forKey: PHONE_NUMBER)
                            }
                            
                            if let pin_tries = user.value(forKey: PIN_TRIES)as? Int{
                                UserDefaults.standard.set(pin_tries, forKey: PIN_TRIES)
                            }
                            
                            if let profile_image = user.value(forKey: PROFILE_IMAGE)as? String{
                                UserDefaults.standard.set(profile_image, forKey: PROFILE_IMAGE)
                            }
                            
                            if let profile_image_url = user.value(forKey: PROFILE_IMAGE_URL)as? String{
                                UserDefaults.standard.set(profile_image_url, forKey: PROFILE_IMAGE_URL)
                            }
                            
                            if let withdraw_rs = user.value(forKey: WITHDRAW_RS)as? Int{
                                UserDefaults.standard.set(withdraw_rs, forKey: WITHDRAW_RS)
                            }
                            
                            if let other_id_proof_no = user.value(forKey: OTHER_ID_PROOF_NO)as? String{
                                UserDefaults.standard.set(other_id_proof_no, forKey: OTHER_ID_PROOF_NO)
                            }
                            
                            if let other_id_proof_no_photo = user.value(forKey: OTHER_ID_PROOF_NO_PHOTO)as? String{
                                UserDefaults.standard.set(other_id_proof_no_photo, forKey: OTHER_ID_PROOF_NO_PHOTO)
                            }
                            
                            if let other_id_proof_no = user.value(forKey: OTHER_ID_PROOF_NO_PHOTO_2)as? String{
                                UserDefaults.standard.set(other_id_proof_no, forKey: OTHER_ID_PROOF_NO_PHOTO_2)
                            }
                            
                            if let other_id_proof_no_photo = user.value(forKey: OTHER_ID_PROOF_NO_PHOTO_2_URL)as? String{
                                UserDefaults.standard.set(other_id_proof_no_photo, forKey: OTHER_ID_PROOF_NO_PHOTO_2_URL)
                            }
                            
                            if let aadhaar_address = user.value(forKey: AADHAAR_ADDRESS)as? String{
                                UserDefaults.standard.set(aadhaar_address, forKey: AADHAAR_ADDRESS)
                            }
                            
                            if let pincode = user.value(forKey: PINCODE)as? String{
                                UserDefaults.standard.set(pincode, forKey: PINCODE)
                            }
                            
                            if let state = user.value(forKey: STATE)as? String{
                                UserDefaults.standard.set(state, forKey: STATE)
                            }
                            
                            SVProgressHUD.dismiss()
                            self.setupData()
                            self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
                        }
                        
                    }else{
                        SVProgressHUD.dismiss()
                        self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
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
                        self.accountVerification()
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
        
    }
    
    func updateProofIDDetails(){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let imageData = UIImageJPEGRepresentation(otherProofImage.image!,0)
        let base64:String = (imageData?.base64EncodedString())!
        
        
        
        let imageData2 = UIImageJPEGRepresentation(backImage.image!,0)
        let base6412:String = (imageData2?.base64EncodedString())!
        
        let url = kBaseUrl.appending(kUpdateProofIDDetails)
        let param = ["aadhaar_extension_1":"png","other_id_proof_no":self.txtOtherIDNumber.text!,"aadhaar_base64Data_1":base64,"aadhaar_base64Data_2":base6412 != "" ? base6412 : "","aadhaar_extension_2":"png"]
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                        if let user = json.value(forKey: USER) as? NSDictionary{
                            
                            if let account_holder_name = user.value(forKey: ACCOUNT_HOLDER_NAME)as? String{
                                UserDefaults.standard.set(account_holder_name, forKey: ACCOUNT_HOLDER_NAME)
                            }
                            
                            if let account_number = user.value(forKey: ACCOUNT_NUMBER)as? String{
                                UserDefaults.standard.set(account_number, forKey: ACCOUNT_NUMBER)
                            }
                            
                            if let balance_btc = user.value(forKey: BALANCE_BTC)as? String{
                                UserDefaults.standard.set(balance_btc, forKey: BALANCE_BTC)
                            }
                            
                            if let balance_rs = user.value(forKey: BALANCE_RS)as? String{
                                UserDefaults.standard.set(balance_rs, forKey: BALANCE_RS)
                            }
                            
                            if let bank_name = user.value(forKey: BANK_NAME)as? String{
                                UserDefaults.standard.set(bank_name, forKey: BANK_NAME)
                            }
                            
                            if let birthdate = user.value(forKey: BIRTHDATE)as? String{
                                UserDefaults.standard.set(birthdate, forKey: BIRTHDATE)
                            }
                            
                            if let branch_name = user.value(forKey: BRANCH_NAME)as? String{
                                UserDefaults.standard.set(branch_name, forKey: BRANCH_NAME)
                            }
                            
                            if let email = user.value(forKey: EMAIL)as? String{
                                UserDefaults.standard.set(email, forKey: EMAIL)
                            }
                            
                            if let firstname = user.value(forKey: FIRSTNAME)as? String{
                                UserDefaults.standard.set(firstname, forKey: FIRSTNAME)
                            }
                            
                            if let frozen_btc = user.value(forKey: FROZEN_BTC)as? String{
                                UserDefaults.standard.set(frozen_btc, forKey: FROZEN_BTC)
                            }
                            
                            if let gender = user.value(forKey: GENDER)as? String{
                                UserDefaults.standard.set(gender, forKey: GENDER)
                            }
                            
                            if let ifsc_code = user.value(forKey: IFSC_CODE)as? String{
                                UserDefaults.standard.set(ifsc_code, forKey: IFSC_CODE)
                            }
                            
                            if let is_active = user.value(forKey: IS_ACTIVE)as? Int{
                                UserDefaults.standard.set(is_active, forKey: IS_ACTIVE)
                            }
                            
                            if let is_email_verified = user.value(forKey: IS_EMAIL_VERIFIED)as? Int{
                                UserDefaults.standard.set(is_email_verified, forKey: IS_EMAIL_VERIFIED)
                            }
                            
                            if let is_phone_verified = user.value(forKey: IS_PHONE_VERIFIED)as? Int{
                                UserDefaults.standard.set(is_phone_verified, forKey: IS_PHONE_VERIFIED)
                            }
                            
                            if let is_verified = user.value(forKey: IS_VERIFIED)as? Int{
                                UserDefaults.standard.set(is_verified, forKey: IS_VERIFIED)
                            }
                            
                            if let lastname = user.value(forKey: LASTNAME)as? String{
                                UserDefaults.standard.set(lastname, forKey: LASTNAME)
                            }
                            
                            if let lock_btc = user.value(forKey: LOCK_BTC)as? String{
                                UserDefaults.standard.set(lock_btc, forKey: LOCK_BTC)
                            }
                            
                            if let lock_rs = user.value(forKey: LOCK_RS)as? String{
                                UserDefaults.standard.set(lock_rs, forKey: LOCK_RS)
                            }
                            
                            if let name = user.value(forKey: NAME)as? String{
                                UserDefaults.standard.set(name, forKey: NAME)
                            }
                            
                            if let pan_card_no = user.value(forKey: PAN_CARD_NUMBER)as? String{
                                UserDefaults.standard.set(pan_card_no, forKey: PAN_CARD_NUMBER)
                            }
                            
                            if let pan_card_photo = user.value(forKey: PAN_CARD_PHOTO)as? String{
                                UserDefaults.standard.set(pan_card_photo, forKey: PAN_CARD_PHOTO)
                            }
                            
                            if let phone_number = user.value(forKey: PHONE_NUMBER)as? String{
                                UserDefaults.standard.set(phone_number, forKey: PHONE_NUMBER)
                            }
                            
                            if let pin_tries = user.value(forKey: PIN_TRIES)as? Int{
                                UserDefaults.standard.set(pin_tries, forKey: PIN_TRIES)
                            }
                            
                            if let profile_image = user.value(forKey: PROFILE_IMAGE)as? String{
                                UserDefaults.standard.set(profile_image, forKey: PROFILE_IMAGE)
                            }
                            
                            if let profile_image_url = user.value(forKey: PROFILE_IMAGE_URL)as? String{
                                UserDefaults.standard.set(profile_image_url, forKey: PROFILE_IMAGE_URL)
                            }
                            
                            if let withdraw_rs = user.value(forKey: WITHDRAW_RS)as? Int{
                                UserDefaults.standard.set(withdraw_rs, forKey: WITHDRAW_RS)
                            }
                            
                            if let other_id_proof_no = user.value(forKey: OTHER_ID_PROOF_NO)as? String{
                                UserDefaults.standard.set(other_id_proof_no, forKey: OTHER_ID_PROOF_NO)
                            }
                            
                            if let other_id_proof_no_photo = user.value(forKey: OTHER_ID_PROOF_NO_PHOTO)as? String{
                                UserDefaults.standard.set(other_id_proof_no_photo, forKey: OTHER_ID_PROOF_NO_PHOTO)
                            }
                            
                            if let other_id_proof_no = user.value(forKey: OTHER_ID_PROOF_NO_PHOTO_2)as? String{
                                UserDefaults.standard.set(other_id_proof_no, forKey: OTHER_ID_PROOF_NO_PHOTO_2)
                            }
                            
                            if let other_id_proof_no_photo = user.value(forKey: OTHER_ID_PROOF_NO_PHOTO_2_URL)as? String{
                                UserDefaults.standard.set(other_id_proof_no_photo, forKey: OTHER_ID_PROOF_NO_PHOTO_2_URL)
                            }
                            
                            if let aadhaar_address = user.value(forKey: AADHAAR_ADDRESS)as? String{
                                UserDefaults.standard.set(aadhaar_address, forKey: AADHAAR_ADDRESS)
                            }
                            
                            if let pincode = user.value(forKey: PINCODE)as? String{
                                UserDefaults.standard.set(pincode, forKey: PINCODE)
                            }
                            
                            if let state = user.value(forKey: STATE)as? String{
                                UserDefaults.standard.set(state, forKey: STATE)
                            }
                            
                            SVProgressHUD.dismiss()
                            self.setupData()
                            self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
                        }
                        
                    }else{
                        SVProgressHUD.dismiss()
                        self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
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
                        self.updateProofIDDetails()
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
