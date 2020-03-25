//
//  ToastMessage.swift
//  Together
//
//  Created by apple on 2/13/19.
//  Copyright © 2019 Zerones. All rights reserved.
//

import UIKit

class Toast
{
    class private func showAlert(backgroundColor:UIColor, textColor:UIColor, message:String)
    {
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = NSTextAlignment.center
        label.text = message
        label.font = UIFont(name: "", size: 11)
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor =  backgroundColor //UIColor.whiteColor()
        label.textColor = textColor //TEXT COLOR
        label.sizeToFit()
        label.numberOfLines = 4
        label.layer.shadowColor = UIColor.gray.cgColor
        label.layer.shadowOffset = CGSize(width: 4, height: 3)
        label.layer.shadowOpacity = 0.3
        
        label.frame = CGRect(x: appDelegate.window!.frame.size.width, y: 64, width: appDelegate.window!.frame.size.width - 40, height: 44)
        label.layer.cornerRadius = label.frame.height / 2
        label.clipsToBounds = true
        label.alpha = 1
        
        appDelegate.window!.addSubview(label)
        var basketTopFrame: CGRect = label.frame;
        basketTopFrame.origin.x = 20;
        basketTopFrame.origin.y = appDelegate.window!.frame.size.height - 70;
        //basketTopFrame.origin.y = appDelegate.window!.center.y + 50
        label.frame = basketTopFrame
        label.alpha = 0
        
        UIView.animate(withDuration
            :1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
                label.alpha = 1.0
        },  completion: {
            (value: Bool) in
            UIView.animate(withDuration:1.0, delay: 1.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: UIView.AnimationOptions.curveEaseIn, animations: { () -> Void in
                label.alpha = 0
            },  completion: {
                (value: Bool) in
                label.removeFromSuperview()
            })
        })
    }
    class func showPositiveMessage(message:String)
    {
        let clr = UIColor(red: 90/255.0, green: 90/255.0, blue: 90/255.0, alpha: 0.7)
        showAlert(backgroundColor: clr, textColor: UIColor.white, message: message)
    }
    class func showNegativeMessage(message:String)
    {
        showAlert(backgroundColor: UIColor.red, textColor: UIColor.white, message: message)
    }
}
