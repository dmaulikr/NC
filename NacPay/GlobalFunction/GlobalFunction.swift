//
//  GlobalFunction.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import Foundation
import UIKit
import AFNetworking


/*===============================================================================
 * Extention Purpose: Return Color from hexValue
 * How to Use: -> UIColor(hexString: "5CC152")
 * ============================================================================*/
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
//===============================end extention================================



/*===============================================================================
 * Function Purpose: Set placeHolder color for textField
 * How to Use: -> setTextFieldPlaceHolderColor(txtName: nameOfTextField, placeHolderText: textOfPlaceHolder)
 * ============================================================================*/
func setTextFieldPlaceHolderColor(txtName:UITextField,placeHolderText:String){
    txtName.attributedPlaceholder = NSAttributedString(string: placeHolderText,
                                                           attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(hexString: "FFD700")])
}
//===============================end function================================

/*===============================================================================
 * Function Purpose: Set placeHolder color for textField
 * How to Use: -> setTextFieldPlaceHolderColor(txtName: nameOfTextField, placeHolderText: textOfPlaceHolder)
 * ============================================================================*/
func setWhiteTextFieldPlaceHolderColor(txtName:UITextField,placeHolderText:String){
    txtName.attributedPlaceholder = NSAttributedString(string: placeHolderText,
                                                       attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
}
//===============================end function================================





/*===============================================================================
 * Function Purpose: Set corner radiou to UIView
 * How to Use: -> setCornerRadiouToView(viewName: viewname)
 * ============================================================================*/
func setCornerRadiouToView(viewName:UIView){
    viewName.layer.cornerRadius = 3
    viewName.clipsToBounds = true
}
//===============================end function================================





func alert(title:String,msg:String){
    let alert = UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle: "OK")
    alert.show()
}



func sessionManager () -> AFHTTPSessionManager{
    
    let sessionManager : URLSessionConfiguration = {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10
        sessionConfig.timeoutIntervalForResource = 10
        return sessionConfig
    }()
    
    let manager = AFHTTPSessionManager.init(sessionConfiguration: sessionManager)
    manager.requestSerializer = AFHTTPRequestSerializer()
    manager.responseSerializer = AFHTTPResponseSerializer()
    
    var access_token = ""
    if UserDefaults.standard.value(forKey: ACCESS_TOKEN) != nil{
        access_token = "\(UserDefaults.standard.value(forKey: ACCESS_TOKEN)!)"
    }
    
    var token_type = ""
    if UserDefaults.standard.value(forKey: TOKEN_TYPE) != nil{
        token_type = "\(UserDefaults.standard.value(forKey: TOKEN_TYPE)!)"
    }
    
    let token = "\(token_type) \(access_token)"
    
    let serializer = AFJSONRequestSerializer()
    serializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
    serializer.setValue("application/json", forHTTPHeaderField: "Accept")
    serializer.setValue(token, forHTTPHeaderField: "Authorization")
    manager.requestSerializer = serializer    
    return manager
}


func giveMeFailure(error : NSError,completionHandler : @escaping ((Bool) -> Void))  {
    
    if let dataError = (error as NSError).userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as? Data {
        if let ErrorResponse = String(data: dataError, encoding: String.Encoding.utf8){
            if ErrorResponse != ""{
                print("Token Expired..")
                //print(ErrorResponse)
                
                let json = convertToDictionary(text: ErrorResponse)
                if let errorMSG = json?.value(forKey: "error")as? String{
                    if errorMSG == "invalid_request"{
                        
                        var number = ""
                        if UserDefaults.standard.value(forKey: PHONE_NUMBER) != nil{
                            number = "\(UserDefaults.standard.value(forKey: PHONE_NUMBER)!)"
                        }
                        
                        var pin = ""
                        if UserDefaults.standard.value(forKey: PIN) != nil{
                            pin = "\(UserDefaults.standard.value(forKey: PIN)!)"
                        }
                        
                        let appDel = UIApplication.shared.delegate as! AppDelegate
                        appDel.issuesUserAccessToken(number: number, pin: pin, completionHandler: { (isUpdated) in
                            completionHandler(isUpdated)
                        })
                        
                    }else{
                        var refresh_token = ""
                        if UserDefaults.standard.value(forKey: REFRESH_TOKEN) != nil{
                            refresh_token = "\(UserDefaults.standard.value(forKey: REFRESH_TOKEN)!)"
                        }
                        
                        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDel.refreshUserAccessToken(refresh_token: refresh_token, completionHandler: { (isUpdated) in
                            completionHandler(isUpdated)
                        })
                    }
                }
            }
        }
    }
}


func convertToDictionary(text: String) -> NSDictionary? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}


/*===============================================================================
 * struct Purpose: check the device is simulator or real
 * How to Use: -> if Platform.isSimulator {
 print("Running on Simulator")
 }
 * ============================================================================*/
struct Platform {
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
    }
    
}
//===============================end struct================================


extension String {
    func countInstances(of stringToFind: String) -> Int {
        assert(!stringToFind.isEmpty)
        var searchRange: Range<String.Index>?
        var count = 0
        while let foundRange = range(of: stringToFind, options: .diacriticInsensitive, range: searchRange) {
            searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
            count += 1
        }
        return count
    }
}


extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

