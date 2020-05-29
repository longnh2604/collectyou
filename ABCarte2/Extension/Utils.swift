//
//  Utils.swift
//  ABCarte2
//
//  Created by Long on 2018/05/09.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork
import Alamofire
import SwiftyJSON
import Photos
import PDFGenerator

class Utils: NSObject {
    
    //*****************************************************************
    // MARK: - Get UUID and store keychain
    //*****************************************************************
    
    // Creates a new unique user identifier or retrieves the last one created
    static func getUUID() -> String? {
        // create a keychain helper instance
        let keychain = KeychainAccess()
        // this is the key we'll use to store the uuid in the keychain
        let uuidKey = "oluxe.co.jp.unique_uuid"
        // check if we already have a uuid stored, if so return it
        if let uuid = try? keychain.queryKeychainData(itemKey: uuidKey), uuid != nil {
            return uuid
        }
        // generate a new id
        guard let newId = UIDevice.current.identifierForVendor?.uuidString else {
            return nil
        }
        // store new identifier in keychain
        try? keychain.addKeychainData(itemKey: uuidKey, itemValue: newId)
        // return new id
        return newId
    }
    
    //*****************************************************************
    // MARK: - Find correct value in array
    //*****************************************************************
    
    static func checkRemainingStorage()->String {
        let percent = Float(GlobalVariables.sharedManager.currentSize ?? 0) * 100 / Float(GlobalVariables.sharedManager.limitSize ?? 0)
        if percent >= 80 {
            if percent >= 90 {
                if percent >= 95 {
                    if percent >= 100 {
                        return "ご利用可能な使用容量が 100% を超えました。\n容量の追加をご希望されますか？"
                    }
                    return "ご利用可能な使用容量が 95% を超えました。\n容量の追加をご希望されますか？"
                }
                return "ご利用可能な使用容量が 90% を超えました。\n容量の追加をご希望されますか？"
            }
            return "ご利用可能な使用容量が 80% を超えました。\n容量の追加をご希望されますか？"
        }
        return "OK"
    }
    
    //*****************************************************************
    // MARK: - Find correct value in array
    //*****************************************************************
    
    static func findObjectArrayInt(value searchValue: Int, in array: [Int]) -> Bool
    {
        for (_, value) in array.enumerated()
        {
            if value == searchValue {
                return true
            }
        }
        return false
    }
    
    //*****************************************************************
    // MARK: - Store Document PDF and Retrieve
    //*****************************************************************
    
    static func savePdf(urlString:String, fileName:String,completion:@escaping(Bool) -> ()) {
        if pdfFileAlreadySaved(url: urlString, fileName: fileName) {
            completion(true)
            return
        }
            
        let url = URL(string: urlString)
        let pdfData = try? Data.init(contentsOf: url!)
        let resourceDocPath = (FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)).last! as URL
        let nameFromUrl = "\(fileName).pdf"
        let actualPath = resourceDocPath.appendingPathComponent(nameFromUrl)
        do {
            try pdfData?.write(to: actualPath, options: .atomic)
            print("pdf successfully saved!")
            completion(true)
        } catch {
            print("Pdf could not be saved")
            completion(false)
        }
    }
    
    static func showSavedPdf(url:String, fileName:String,completion:@escaping(String) -> ()) {
            if #available(iOS 10.0, *) {
                do {
                    let docURL = try FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                    for url in contents {
                        if url.description.contains("\(fileName).pdf") {
                            completion(url.relativePath)
                            return
                    }
                }
                completion("")
            } catch {
                completion("")
                print("could not locate pdf file !!!!!!!")
            }
        }
    }
    
    // check to avoid saving a file multiple times
    static func pdfFileAlreadySaved(url:String, fileName:String)-> Bool {
        var status = false
        if #available(iOS 10.0, *) {
            do {
                let docURL = try FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                for url in contents {
                    if url.description.contains("\(fileName).pdf") {
                        status = true
                    }
                }
            } catch {
                print("could not locate pdf file !!!!!!!")
            }
        }
        return status
    }
    
    //*****************************************************************
    // MARK: - Store Image and Retrieve
    //*****************************************************************
    
    static func saveImage(urlString:String, fileName:String,completion:@escaping(Bool) -> ()) {
        if imageFileAlreadySaved(url: urlString, fileName: fileName) {
            completion(true)
            return
        }
            
        let url = URL(string: urlString)
        let imgData = try? Data.init(contentsOf: url!)
        let resourceDocPath = (FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)).last! as URL
        let nameFromUrl = "\(fileName).png"
        let actualPath = resourceDocPath.appendingPathComponent(nameFromUrl)
        do {
            try imgData?.write(to: actualPath, options: .atomic)
            print("image successfully saved!")
            completion(true)
        } catch {
            print("image could not be saved")
            completion(false)
        }
    }
    
    static func showSavedImage(url:String, fileName:String,completion:@escaping(String) -> ()) {
            if #available(iOS 10.0, *) {
                do {
                    let imgURL = try FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let contents = try FileManager.default.contentsOfDirectory(at: imgURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                    for url in contents {
                        if url.description.contains("\(fileName).png") {
                            completion(url.relativePath)
                            return
                    }
                }
                completion("")
            } catch {
                completion("")
                print("could not locate image file !!!!!!!")
            }
        }
    }
    
    // check to avoid saving a file multiple times
    static func imageFileAlreadySaved(url:String, fileName:String)-> Bool {
        var status = false
        if #available(iOS 10.0, *) {
            do {
                let imgURL = try FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let contents = try FileManager.default.contentsOfDirectory(at: imgURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                for url in contents {
                    if url.description.contains("\(fileName).png") {
                        status = true
                    }
                }
            } catch {
                print("could not locate image file !!!!!!!")
            }
        }
        return status
    }
    
    //*****************************************************************
    // MARK: - Generate Random Password
    //*****************************************************************
    
    static func onGenerateRandomPassword(length:Int)->String {
        let pswdChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        let rndPswd = String((0..<length).compactMap{ _ in pswdChars.randomElement() })
        return rndPswd
    }
    
    //*****************************************************************
    // MARK: - Generate Document No
    //*****************************************************************
    
    static func onGenerateDocumentNoFromNumber(accID:Int,total:Int,existed:Int)->String? {
        
        var docNo: String = "\(String(accID))-"
        for _ in 0 ..< existed {
            docNo.append("0")
        }
        docNo.append("\(String(total))")
        return docNo
    }
    
    static func onGenerateDocumentNoFromImage(accID:Int,image:UIImage,total:Int,existed:Int,extraText:String)->UIImage? {
        
        var docNo: String = ""
        for _ in 0 ..< existed {
            docNo.append("0")
        }
        docNo.append("\(String(total))")
        
        let img = Utils.textToImage(drawText: "\(String(accID))\(extraText)-\(docNo)" as NSString, inImage: image, atPoint: CGPoint(x:image.size.width - 400, y: 190))
        return img
    }
    
    static func onGenerateDocumentNumber(number:String,image:UIImage)->UIImage? {
        let img = Utils.textToImage(drawText: "\(number)" as NSString, inImage: image, atPoint: CGPoint(x:image.size.width - 400, y: 190))
        return img
    }
    
    static func onGenerateContractSerialNumber(number:String,image:UIImage)->UIImage? {
        let img = Utils.textToImage(drawText: "\(number)" as NSString, inImage: image, atPoint: CGPoint(x:image.size.width - 590, y: 1590))
        return img
    }
    
    //*****************************************************************
    // MARK: - Generate QR Code
    //*****************************************************************
    
    static func onGenerateQRCode(from text:String)->UIImage {
        
        var processedImage = UIImage()
        // Get data from the string
        let data = text.data(using: String.Encoding.ascii)
        // Get a QR CIFilter
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return processedImage }
        // Input the data
        qrFilter.setValue(data, forKey: "inputMessage")
        // Get the output image
        guard let qrImage = qrFilter.outputImage else { return processedImage }
        // Scale the image
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        // Do some processing to get the UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) else { return processedImage }
        processedImage = UIImage(cgImage: cgImage)
        
        return processedImage
    }
    
    //*****************************************************************
    // MARK: - Check Limit Characters
    //*****************************************************************
    static func checkLimitCharacter(number: Int,type:Int)->(status: Bool,msg: String) {
        if number == 0 {
            return (false,MSG_ALERT.kALERT_PLEASE_INPUT_CONTENT)
        }
        
        switch type {
        case 1:
            if number <= 50 {
                return (true,"")
            } else {
                return (false,MSG_ALERT.kALERT_KEYWORD_RESTRICT)
            }
        case 2:
            if number <= 250 {
                return (true,"")
            } else {
                return (false,MSG_ALERT.kALERT_SECRET_MEMO_RESTRICT)
            }
        case 3:
            if number <= 250 {
                return (true,"")
            } else {
                return (false,MSG_ALERT.kALERT_REMARKS_RESTRICT)
            }
        case 4:
            if number <= 1000 {
                return (true,"")
            } else {
                return (false,MSG_ALERT.kALERT_FREE_MEMO_RESTRICT)
            }
        case 5:
            if number <= 25 {
                return (true,"")
            } else {
                return (false,MSG_ALERT.kALERT_LAST_NAME_RESTRICT)
            }
        case 6:
            if number <= 25 {
                return (true,"")
            } else {
                return (false,MSG_ALERT.kALERT_FIRST_NAME_RESTRICT)
            }
        case 7:
            if number <= 40 {
                return (true,"")
            } else {
                return (false,MSG_ALERT.kALERT_LAST_NAME_KANA_RESTRICT)
            }
        case 8:
            if number <= 40 {
                return (true,"")
            } else {
                return (false,MSG_ALERT.kALERT_FIRST_NAME_KANA_RESTRICT)
            }
        case 9:
            if number <= 25 {
                return (true,"")
            } else {
                return (false,MSG_ALERT.kALERT_CUSTOMER_NO_RESTRICT)
            }
        case 10:
            if number <= 25 {
                return (true,"")
            } else {
                return (false,MSG_ALERT.kALERT_CUSTOMER_URGENT_CONTACT_RESTRICT)
            }
        case 11:
            if number <= 25 {
                return (true,"")
            } else {
                return (false,MSG_ALERT.kALERT_RESPONSIBLE_RESTRICT)
            }
        case 12:
            if number <= 10 {
                return (true,"")
            } else {
                return (false,MSG_ALERT.kALERT_POSTAL_CODE_RESTRICT)
            }
        case 13:
            if number <= 8 {
                return (true,"")
            } else {
                return (false,MSG_ALERT.kALERT_PREFECTURE_RESTRICT)
            }
        case 14:
            if number <= 20 {
                return (true,"")
            } else {
                return (false,MSG_ALERT.kALERT_CITY_RESTRICT)
            }
        case 15:
            if number <= 40 {
                return (true,"")
            } else {
                return (false,MSG_ALERT.kALERT_ADDRESS_RESTRICT)
            }
        case 16:
            if number <= 50 {
                return (true,"")
            } else {
                return (false,MSG_ALERT.kALERT_EMAIL_RESTRICT)
            }
        case 17:
            if number <= 200 {
                return (true,"")
            } else {
                return (false,MSG_ALERT.kALERT_HOBBY_RESTRICT)
            }
        case 18:
            if number <= 10 {
                return (true,"")
            } else {
                return (false,MSG_ALERT.kALERT_STAMP_TITLE_RESTRICT)
            }
        default:
            return (false,"")
        }
    }
    
    //*****************************************************************
    // MARK: - Color Style
    //*****************************************************************
    static func setButtonColorStyle(button:UIButton,type:Int) {
        if let set = UserPreferences.appColorSet {
            switch set {
            case AppColorSet.standard.rawValue:
                if type == 0 {
                    button.backgroundColor = COLOR_SET000.kACCENT_COLOR
                } else {
                    button.backgroundColor = COLOR_SET000.kCOMMAND_BUTTON_BACKGROUND_COLOR
                }
            case AppColorSet.jbsattender.rawValue:
                if type == 0 {
                    button.backgroundColor = COLOR_SET001.kACCENT_COLOR
                } else {
                    button.backgroundColor = COLOR_SET001.kCOMMAND_BUTTON_BACKGROUND_COLOR
                }
            case AppColorSet.romanpink.rawValue:
                if type == 0 {
                    button.backgroundColor = COLOR_SET002.kACCENT_COLOR
                } else {
                    button.backgroundColor = COLOR_SET002.kCOMMAND_BUTTON_BACKGROUND_COLOR
                }
            case AppColorSet.hisul.rawValue:
                if type == 0 {
                    button.backgroundColor = COLOR_SET003.kACCENT_COLOR
                } else {
                    button.backgroundColor = COLOR_SET003.kCOMMAND_BUTTON_BACKGROUND_COLOR
                }
            case AppColorSet.lavender.rawValue:
                if type == 0 {
                    button.backgroundColor = COLOR_SET004.kACCENT_COLOR
                } else {
                    button.backgroundColor = COLOR_SET004.kCOMMAND_BUTTON_BACKGROUND_COLOR
                }
            case AppColorSet.pinkgold.rawValue:
                if type == 0 {
                    button.backgroundColor = COLOR_SET005.kACCENT_COLOR
                } else {
                    button.backgroundColor = COLOR_SET005.kCOMMAND_BUTTON_BACKGROUND_COLOR
                }
            case AppColorSet.mysteriousnight.rawValue:
                if type == 0 {
                    button.backgroundColor = COLOR_SET006.kACCENT_COLOR
                } else {
                    button.backgroundColor = COLOR_SET006.kCOMMAND_BUTTON_BACKGROUND_COLOR
                }
            case AppColorSet.gardenparty.rawValue:
                if type == 0 {
                    button.backgroundColor = COLOR_SET007.kACCENT_COLOR
                } else {
                    button.backgroundColor = COLOR_SET007.kCOMMAND_BUTTON_BACKGROUND_COLOR
                }
            default:
                break
            }
        }
    }
    
    static func setViewColorStyle(view:UIView,type:Int) {
        if let set = UserPreferences.appColorSet {
            switch set {
            case AppColorSet.standard.rawValue:
                if type == 0 {
                    view.backgroundColor = COLOR_SET000.kACCENT_COLOR
                } else {
                    view.backgroundColor = COLOR_SET000.kCOMMAND_BUTTON_BACKGROUND_COLOR
                }
            case AppColorSet.jbsattender.rawValue:
                if type == 0 {
                    view.backgroundColor = COLOR_SET001.kACCENT_COLOR
                } else {
                    view.backgroundColor = COLOR_SET001.kCOMMAND_BUTTON_BACKGROUND_COLOR
                }
            case AppColorSet.romanpink.rawValue:
                if type == 0 {
                    view.backgroundColor = COLOR_SET002.kACCENT_COLOR
                } else {
                    view.backgroundColor = COLOR_SET002.kCOMMAND_BUTTON_BACKGROUND_COLOR
                }
            case AppColorSet.hisul.rawValue:
                if type == 0 {
                    view.backgroundColor = COLOR_SET003.kACCENT_COLOR
                } else {
                    view.backgroundColor = COLOR_SET003.kCOMMAND_BUTTON_BACKGROUND_COLOR
                }
            case AppColorSet.lavender.rawValue:
                if type == 0 {
                    view.backgroundColor = COLOR_SET004.kACCENT_COLOR
                } else {
                    view.backgroundColor = COLOR_SET004.kCOMMAND_BUTTON_BACKGROUND_COLOR
                }
            case AppColorSet.pinkgold.rawValue:
                if type == 0 {
                    view.backgroundColor = COLOR_SET005.kACCENT_COLOR
                } else {
                    view.backgroundColor = COLOR_SET005.kCOMMAND_BUTTON_BACKGROUND_COLOR
                }
            case AppColorSet.mysteriousnight.rawValue:
                if type == 0 {
                    view.backgroundColor = COLOR_SET006.kACCENT_COLOR
                } else {
                    view.backgroundColor = COLOR_SET006.kCOMMAND_BUTTON_BACKGROUND_COLOR
                }
            case AppColorSet.gardenparty.rawValue:
                if type == 0 {
                    view.backgroundColor = COLOR_SET007.kACCENT_COLOR
                } else {
                    view.backgroundColor = COLOR_SET007.kCOMMAND_BUTTON_BACKGROUND_COLOR
                }
            default:
                break
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Get Document Directory Path
    //*****************************************************************
    
    static func getDocumentPath() -> String {
        let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory,
                                                                FileManager.SearchPathDomainMask.userDomainMask, true)
        let documnetPath = documentPaths[0]
        return  documnetPath
    }
    
    //*****************************************************************
    // MARK: - Delay
    //*****************************************************************
    
    static func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    //*****************************************************************
    // MARK: - BloodType Convert
    //*****************************************************************
    
    static func checkBloodType(type:Int) -> String{
        switch type {
        case 0:
            return LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: "")
        case 1:
            return " A "
        case 2:
            return " B "
        case 3:
            return " O "
        case 4:
            return " AB "
        default:
            return LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: "")
        }
    }
    
    //*****************************************************************
    // MARK: - Customer Status Convert
    //*****************************************************************
    
    static func checkCusStatus(status:Int) -> String{
        switch status {
        case 1:
            return "非表示"
        case 2:
            return "問題有"
        case 3:
            return "お試し"
        case 4:
            return "リピート"
        case 5:
            return "VIP"
        default:
            return LocalizationSystem.sharedInstance.localizedStringForKey(key: "Unregistered", comment: "")
        }
    }
    
    //*****************************************************************
    // MARK: - Get Location From Postal Code
    //*****************************************************************
    
    static func getLocationFromPostalCode(postalCode : String,completion: @escaping StringCompletion) {
        
        let url = "https://api.zipaddress.net/?zipcode=\(postalCode)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding:  JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                let code = json["code"]
                if code == 200 {
                    guard let fulladd = json["data"]["fullAddress"].stringValue as String? else { return }
                    completion(true,fulladd)
                } else {
                    guard let msg = json["message"].stringValue as String? else { return }
                    completion(false,msg)
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Display App 's Info
    //*****************************************************************
    
    static func displayInfo(acc_name:String,acc_id:String,view:UIViewController) {
        let version = Bundle.main.infoDictionary!["CFBundleVersion"]!
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Application Info", comment: ""), message: "\n\(appName) ver \(version)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            view.present(alert, animated: true, completion: nil)
        }
    }
    
    //*****************************************************************
    // MARK: - Image Resize (width)
    //*****************************************************************
    
    static func imageWithImage(sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    //*****************************************************************
    // MARK: - Generate PDF
    //*****************************************************************
    
    static func generatePDF(images:[UIImage])->URL {
        
        let dest = URL(fileURLWithPath: NSTemporaryDirectory().appending("printTemp.pdf"))
        // outputs as Data
        do {
            let data = try PDFGenerator.generated(by: images)
            try data.write(to: dest, options: .atomic)
        } catch (let error) {
            print(error)
        }
        
        // writes to Disk directly.
        do {
            try PDFGenerator.generate(images, to: dest)
        } catch (let error) {
            print(error)
        }
        return dest
    }
    
    //*****************************************************************
    // MARK: - Printer
    //*****************************************************************
    
    static func printImageData(data:[Data]) {
        guard (UIPrintInteractionController.canPrint(data[0])) else {
            Swift.print("Unable to print: \(data)")
            return
        }
        showPrintInteractionData(data)
    }
    
    static func showPrintInteractionData(_ data: [Data]) {
        let controller = UIPrintInteractionController.shared
        controller.accessibilityLanguage = "ja"
        controller.printingItem = data
        let printInfo = UIPrintInfo.printInfo()
        printInfo.outputType = .general
        printInfo.jobName = "PrintJob"
        printInfo.duplex = .longEdge
        controller.printInfo = printInfo
        controller.present(animated: true, completionHandler: nil)
    }
    
    static func printUrl(url:URL) {
        guard (UIPrintInteractionController.canPrint(url)) else {
            Swift.print("Unable to print: \(url)")
            return
        }
        showPrintInteraction(url)
    }
    
    static func showPrintInteraction(_ url: URL) {
        let controller = UIPrintInteractionController.shared
        controller.accessibilityLanguage = "ja"
        controller.printingItem = url
        controller.printInfo = printerInfo(url.lastPathComponent)
        controller.present(animated: true, completionHandler: nil)
    }
    
    static func printerInfo(_ jobName: String) -> UIPrintInfo {
        let printInfo = UIPrintInfo.printInfo()
        printInfo.outputType = .general
        printInfo.jobName = jobName
        printInfo.duplex = .longEdge
        Swift.print("Printing: \(jobName)")
        return printInfo
    }
    
    static func printUrlNew(url:URL,completion:@escaping(Bool) -> ()) {
        guard (UIPrintInteractionController.canPrint(url)) else {
            completion(false)
            return
        }
        
        let controller = UIPrintInteractionController.shared
        controller.accessibilityLanguage = "ja"
        controller.printingItem = url
        controller.printInfo = printerInfo(url.lastPathComponent)
        controller.present(animated: true) { (controller, success, error) in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Email Validation
    //*****************************************************************
    
    static func isValidEmail(email:String) -> Bool {
        
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: email)
        return result
    }
    
    //*****************************************************************
    // MARK: - Phone Validation
    //*****************************************************************
    
    static func isValidPhone(phone: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: phone)
        return result
    }
    
    //*****************************************************************
    // MARK: - Check Internet Connection
    //*****************************************************************
    
    static func getWiFiSsid() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
    
    //*****************************************************************
    // MARK: - Get Header Key Value from URL Response
    //*****************************************************************
    
    static func onConvertHeaderResult(res: HTTPURLResponse) {
        
        let keyValues = res.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
        
        // Now filter the array, searching for your header-key, also lowercased
        if let myHeaderValue = keyValues.filter({ $0.0 == "X-Pagination-Page-Count".lowercased() }).first {
            GlobalVariables.sharedManager.pageTotal = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageTotal = 1
        }
        
        //get total customer
        if let myHeaderValue = keyValues.filter({ $0.0 == "X-Pagination-Total-Count".lowercased() }).first {
            GlobalVariables.sharedManager.totalCus = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.totalCus = 0
        }
        
        //get current page
        if let myHeaderValue = keyValues.filter({ $0.0 == "X-Pagination-Current-Page".lowercased() }).first {
            GlobalVariables.sharedManager.pageCurr = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageCurr = 1
        }
    }
    
    //*****************************************************************
    // MARK: - Merge Two UIImage
    //*****************************************************************
    
    static func mergeTwoUIImage(topImage:UIImage,bottomImage:UIImage,width:CGFloat,height:CGFloat)->UIImage {
        let botImg = bottomImage
        let topImg = topImage
        
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        
        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        botImg.draw(in: areaSize)
        topImg.draw(in: areaSize, blendMode: .normal, alpha: 1)
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    //*****************************************************************
    // MARK: - Save Image
    //*****************************************************************
    
    static func saveImageToCameraRoll(url:URL,completion:@escaping(Bool) -> ()) {
        URLSession.shared.dataTask(
            with: url,
            completionHandler: { (data, response, error) -> Void in
                if let imageData = data {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: UIImage(data: imageData)!)
                    }, completionHandler: { (success, error) -> Void in
                        if error != nil {
                            completion(false)
                        } else {
                            completion(true)
                        }
                    })
                }
        }
            ).resume()
    }
    
    static func saveImageEdit(viewMake:UIView)->UIImage {
        //Create the UIImage
        UIGraphicsBeginImageContext(viewMake.frame.size)
        viewMake.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static func saveImageToLocal(imageDownloaded:UIImage,name:String)->URL {
        
        // get the documents directory url
        let fileManger = FileManager.default
        let documentsDirectory = fileManger.urls(for: .libraryDirectory, in: .userDomainMask).first!
        // choose a name for your image
        let fileName = "\(name).jpg"
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        // get your UIImage jpeg data representation and check if the destination file url already exists
        let data = imageDownloaded.jpegData(compressionQuality: 0.75)
        
        if fileManger.fileExists(atPath: fileURL.path){
            do{
                //            try fileManger.removeItem(atPath: fileURL.path)
                try data?.write(to: fileURL)
            }catch {
                print("error occurred, here are the details:\n \(error)")
            }
        } else {
            do{
                try data?.write(to: fileURL)
            }catch {
                print("error occurred, here are the details:\n \(error)")
            }
        }
        return fileURL
    }
    
    //*****************************************************************
    // MARK: - Lock Screen Orientation
    //*****************************************************************
    
    struct AppUtility {
        
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }
        
        /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
        
    }
    
    //*****************************************************************
    // MARK: - Day Convert
    //*****************************************************************
    
    static func getDayOfWeek(_ day:String) -> String? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        formatter.locale = Locale(identifier: "ja_JP")
        guard let todayDate = formatter.date(from: day) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        
        let stringWeekDay = checkWeekDay(weekday: weekDay)
        return stringWeekDay
    }
    
    static func checkWeekDay(weekday:Int) -> String{
        switch weekday {
        case 1:
            return " (日) "
        case 2:
            return " (月) "
        case 3:
            return " (火) "
        case 4:
            return " (水) "
        case 5:
            return " (木) "
        case 6:
            return " (金) "
        case 7:
            return " (土) "
        default:
            return ""
        }
    }
    
    //*****************************************************************
    // MARK: - Show Alert
    //*****************************************************************
    
    static func showAlert(message :String,view:UIViewController) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(confirm)
        DispatchQueue.main.async {
            view.present(alert, animated: true, completion: nil)
        }
    }
    
    //*****************************************************************
    // MARK: - DateTime Convert
    //*****************************************************************
    
    static func convertUnixTimestampUK(time: Int)->String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(time))
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.locale = Locale(identifier: "ja_JP")
        dayTimePeriodFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        
        return dateString
    }
    
    static func convertUnixTimestamp(time: Int)->String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(time))
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.locale = Locale(identifier: "ja_JP")
        dayTimePeriodFormatter.dateFormat = "yyyy年MM月dd日"
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        
        return dateString
    }
    
    static func convertUnixTimestampHM(time: Int)->String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(time))
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.locale = Locale(identifier: "ja_JP")
        dayTimePeriodFormatter.dateFormat = "yyyy年MM月dd日 HH時mm分"
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        
        return dateString
    }
    
    static func convertUnixTimestampHMOnly(time: Int)->String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(time))
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.locale = Locale(identifier: "ja_JP")
        dayTimePeriodFormatter.dateFormat = "HH時mm分"
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        return dateString
    }
    
    static func convertUnixTimestampDT(time: Int)->String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(time))
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.locale = Locale(identifier: "ja_JP")
        dayTimePeriodFormatter.dateFormat = "yyyy年MM月dd日 HH時mm分ss秒"
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        
        return dateString
    }
    
    static func convertUnixTimestampT(time: Int)->String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(time))
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.locale = Locale(identifier: "ja_JP")
        dayTimePeriodFormatter.dateFormat = "HH時mm分ss秒"
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        
        return dateString
    }
    
    static func formatSecondsToString(_ seconds: TimeInterval) -> String {
        if seconds.isNaN {
            return "00分:00秒"
        }
        let Min = Int(seconds / 60)
        let Sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d分:%02d秒", Min, Sec)
    }
    
    //*****************************************************************
    // MARK: - Text to Image
    //*****************************************************************

    static func textToImage(drawText: NSString, inImage: UIImage, atPoint: CGPoint) -> UIImage? {
        
        // Setup the font specific variables
        let textColor = UIColor.black
        let textFont = UIFont(name: "Helvetica Bold", size: 24)!
        
        // Setup the image context using the passed image
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
        ]
        
        // Put the image into a rectangle as large as the original image
        inImage.draw(in: CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))
        
        // Create a point within the space that is as bit as the image
        let rect = CGRect(x: atPoint.x, y: atPoint.y, width: inImage.size.width, height: inImage.size.height)
        
        // Draw the text into an image
        drawText.draw(in: rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage
    }
}

extension Array where Element: Equatable {

    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
