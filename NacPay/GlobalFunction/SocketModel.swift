//
//  SocketModel.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit

class SocketModel: NSObject {

    init(dict:NSDictionary) {
        
       // print(dict)

        if let val = dict.value(forKey: "buyPrice")as? Int{
            buyPrice = val
           
        }
        
        if let val = dict.value(forKey: "is_maintenance_mode")as? Int{
            is_maintenance_mode = String(val)
            
        }
        
        if let val = dict.value(forKey: "sellPrice")as? Int{
            sellPrice = val
            
        }
        
        if let val = dict.value(forKey: "max_ask_amount")as? Int{
            max_ask_amount = String(val)
           
        }
        
        if let val = dict.value(forKey: "max_bank_deposit_amount")as? Double{
            max_bank_deposit_amount = String(val)
            print(max_bank_deposit_amount)
        }
        
        if let val = dict.value(forKey: "max_bid_amount")as? Int{
            max_bid_amount = String(val)
            
        }
        
        if let val = dict.value(forKey: "max_buy_bitcoin_amount")as? Int{
            max_buy_bitcoin_amount = String(val)
            
        }
        
        if let val = dict.value(forKey: "max_payumoney_deposit_amount")as? Int{
            max_PayU_deposit_amount = String(val)
            
        }
        
        if let val = dict.value(forKey: "max_sell_bitcoin_amount")as? Int{
            max_sell_bitcoin_amount = String(val)
            
        }
        
        if let val = dict.value(forKey: "max_send_bitcoin")as? Int{
            max_send_bitcoin = String(val)
            
        }
        
        if let val = dict.value(forKey: "max_withdraw_amount")as? Int{
            max_withdraw_amount = String(val)
          
        }
        
        if let val = dict.value(forKey: "min_ask_amount")as? Int{
            min_ask_amount = String(val)
            
        }
        
        if let val = dict.value(forKey: "min_bank_deposit_amount")as? Int{
            min_bank_deposit_amount = String(val)
            
        }
        
        if let val = dict.value(forKey: "min_bid_amount")as? Int{
            min_bid_amount = String(val)
            
        }
        
        if let val = dict.value(forKey: "min_buy_bitcoin_amount")as? Int{
            min_buy_bitcoin_amount = String(val)
            
        }
        
        if let val = dict.value(forKey: "min_payumoney_deposit_amount")as? Int{
            min_PayU_deposit_amount = String(val)
            
        }
        
        if let val = dict.value(forKey: "min_sell_bitcoin_amount")as? Int{
            min_sell_bitcoin_amount = String(val)
           
        }
        
        if let val = dict.value(forKey: "min_send_bitcoin")as? String{
            min_send_bitcoin = String(val)
        }
        else if let val = dict.value(forKey: "min_send_bitcoin")as?Double{
            min_send_bitcoin = String(val)
        }

        if let val = dict.value(forKey: "min_withdraw_amount")as? Double{
            min_withdraw_amount = String(val)
           
        }
        
        if let val = dict.value(forKey: "support_phone_number")as? String{
            support_phone_number = val
        }
        
        if let val = dict.value(forKey: "ask_amount_interval")as? Int{
            ask_amount_interval = String(val)
           
        }
        
        if let val = dict.value(forKey: "bid_amount_interval")as? Int{
            bid_amount_interval = String(val)
           
        }
        
        // Post notification
        NotificationCenter.default.post(name: Notification.Name(SOCKET_DATA), object: nil)
        
    }
    
    
}
