//
//  CarteCell.swift
//  ABCarte2
//
//  Created by Wayne Lee on 2018/05/14.
//  Copyright © 2018年 Oluxe. All rights reserved.
//

import UIKit
import SDWebImage

protocol CarteCellDelegate: class {
    func didAvatarPress(tag:Int)
    func didCounsellingPress(cellIndex:Int,index:Int)
    func didConsentPress(cellIndex:Int,index:Int)
    func didHandwrittingPress(cellIndex:Int,index:Int)
    func didFreeMemoPress(cellIndex:Int,index:Int)
    func didStampMemoPress(cellIndex:Int,index:Int)
    func onEditCarte(cellIndex:Int)
}

class CarteCell: UITableViewCell {

    //Variable
    weak var delegate:CarteCellDelegate?
    
    var categories: [String] = []
    var cellIndex: Int?
    var maxFree: Int = 1
    var maxStamp: Int = 1
    
    //IBOutlet
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnImage: UIButton!
    @IBOutlet weak var btnNoImage: UIButton!
    @IBOutlet weak var imvCheckBox: UIImageView!
    @IBOutlet weak var lblShopCreated: UILabel!
    @IBOutlet weak var lblRepresentativeName: UILabel!
    @IBOutlet weak var lblBedNo: UILabel!
    @IBOutlet weak var btnCarteEdit: RoundButton!
    
    //memo
    @IBOutlet weak var btnFree1: UIButton!
    @IBOutlet weak var btnFree2: UIButton!
    @IBOutlet weak var btnFree3: UIButton!
    @IBOutlet weak var btnFree4: UIButton!
    @IBOutlet weak var btnStamp1: UIButton!
    @IBOutlet weak var btnStamp2: UIButton!
    @IBOutlet weak var btnStamp3: UIButton!
    @IBOutlet weak var btnStamp4: UIButton!
    //document
    @IBOutlet weak var btnHandwriting1: UIButton!
    @IBOutlet weak var btnHandwriting2: UIButton!
    @IBOutlet weak var btnHandwriting3: UIButton!
    @IBOutlet weak var btnHandwriting4: UIButton!
    @IBOutlet weak var btnConsent1: UIButton!
    @IBOutlet weak var btnConsent2: UIButton!
    @IBOutlet weak var btnConsent3: UIButton!
    @IBOutlet weak var btnConsent4: UIButton!
    @IBOutlet weak var btnCounselling1: UIButton!
    @IBOutlet weak var btnCounselling2: UIButton!
    @IBOutlet weak var btnCounselling3: UIButton!
    @IBOutlet weak var btnCounselling4: UIButton!
    @IBOutlet weak var titleDayVisit: UILabel!
    @IBOutlet weak var heightCarteTitleConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewAddition: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(carte: CarteData){
        titleDayVisit.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Day Visit", comment: "")
        
        if carte.staff_name == "" {
            lblRepresentativeName.text = "未登録"
        } else {
            lblRepresentativeName.text = carte.staff_name
        }
        
        if carte.bed_name == "" {
            lblBedNo.text = "未登録"
        } else {
            lblBedNo.text = carte.bed_name
        }
        
        btnImage.tag = carte.id
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kShop.rawValue) {
            lblShopCreated.text = carte.account_name
        }
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCarteEdit.rawValue) {
            btnCarteEdit.isHidden = false
        } else {
            btnCarteEdit.isHidden = true
            heightCarteTitleConstraint.constant = 30
            viewAddition.isHidden = true
        }
        
        btnImage.imageView?.contentMode = .scaleAspectFit
        //check carte has representative photo or not
        if carte.carte_photo.isEmpty {
            if carte.medias.count > 0 {
                btnNoImage.setTitle("\(carte.medias.count)", for: .normal)
                let url = URL(string: (carte.medias.last?.url)!)

                btnImage.sd_setImage(with: url, for: .normal) { (image, error, cache, url) in
                    guard let img = image else {
                        self.btnImage.setImage(UIImage(named: "img_no_photo"), for: .normal)
                        return
                    }

                    self.btnImage.setImage(img, for: .normal)
                }
            } else {
                btnNoImage.setTitle("\(carte.medias.count)", for: .normal)
                btnImage.setImage(UIImage(named: "img_no_photo"), for: .normal)
            }
        } else {
            btnNoImage.setTitle("\(carte.medias.count)", for: .normal)
            if let url = URL(string: carte.carte_photo) {
                do {
                    let imgData = try Data(contentsOf: url, options: NSData.ReadingOptions())
                    btnImage.setImage(UIImage(data: imgData), for: .normal)
                } catch {
                    btnImage.setImage(UIImage(named: "icon_error_cloud"), for: .normal)
                    print(error)
                }
            }
        }
        
        //carte date
        convertDateTime(date: Date(timeIntervalSince1970: TimeInterval(carte.select_date)))

        //checkbox
        if GlobalVariables.sharedManager.onMultiSelect == true {
            imvCheckBox.isHidden = false
            if carte.selected_status == 1 {
                imvCheckBox.image = UIImage(named: "icon_check_box")
            } else {
                imvCheckBox.image = UIImage(named: "icon_uncheck_box")
            }
        } else {
            imvCheckBox.isHidden = true
        }
        
        //set empty freememo
        for i in 1 ..< 5 {
            setMemoUnSelect(position: i, title: "フリーメモ \(i)", content: "")
        }

        //check free memo has included or not
        if carte.free_memo.count > 0 {
            for i in 0 ..< carte.free_memo.count {
                setFreeMemo(position: carte.free_memo[i].position, title: carte.free_memo[i].title, content: carte.free_memo[i].content)
            }
        }
        
        //set empty stampmemo
        for j in 5 ..< (categories.count + 5)  {
            setStampMemoUnSelect(position: j, title: categories[j - 5], content: "")
        }

        //check stamp memo has included or not
        if categories.count > 0 {
            if carte.stamp_memo.count > 0 {
                for i in 0 ..< carte.stamp_memo.count {
                    setStampMemo(position: carte.stamp_memo[i].position, title: categories[i], content: carte.stamp_memo[i].content)
                }
            }
        }

        //Check account's memo limitation
        switch maxFree {
        case 2:
            btnFree2.isHidden = false
        case 3:
            btnFree2.isHidden = false
            btnFree3.isHidden = false
        case 4:
            btnFree2.isHidden = false
            btnFree3.isHidden = false
            btnFree4.isHidden = false
        default:
            break
        }

        switch maxStamp {
        case 2:
            btnStamp2.isHidden = false
        case 3:
            btnStamp2.isHidden = false
            btnStamp3.isHidden = false
        case 4:
            btnStamp2.isHidden = false
            btnStamp3.isHidden = false
            btnStamp4.isHidden = false
        default:
            break
        }
        
        //set empty document
        for i in 1 ..< 4 {
            setDocumentEmpty(type: i)
        }
        
        //check document has included or not
        for i in 0 ..< carte.doc.count {
            switch carte.doc[i].type {
            case 1:
                if carte.doc[i].sub_type == 1 {
                    btnCounselling1.setBackgroundImage(UIImage(named: "btn_comment_green.png"), for: .normal)
                } else if carte.doc[i].sub_type == 2 {
                    btnCounselling2.setBackgroundImage(UIImage(named: "btn_comment_green.png"), for: .normal)
                } else if carte.doc[i].sub_type == 3 {
                    btnCounselling3.setBackgroundImage(UIImage(named: "btn_comment_green.png"), for: .normal)
                } else if carte.doc[i].sub_type == 4 {
                    btnCounselling4.setBackgroundImage(UIImage(named: "btn_comment_green.png"), for: .normal)
                }
            case 2:
                if carte.doc[i].sub_type == 1 {
                    btnConsent1.setBackgroundImage(UIImage(named: "btn_comment_yellow.png"), for: .normal)
                } else if carte.doc[i].sub_type == 2 {
                    btnConsent2.setBackgroundImage(UIImage(named: "btn_comment_yellow.png"), for: .normal)
                } else if carte.doc[i].sub_type == 3 {
                    btnConsent3.setBackgroundImage(UIImage(named: "btn_comment_yellow.png"), for: .normal)
                } else if carte.doc[i].sub_type == 4 {
                    btnConsent4.setBackgroundImage(UIImage(named: "btn_comment_yellow.png"), for: .normal)
                }
            case 3:
                if carte.doc[i].sub_type == 1 {
                    btnHandwriting1.setBackgroundImage(UIImage(named: "btn_comment_purple.png"), for: .normal)
                } else if carte.doc[i].sub_type == 2 {
                    btnHandwriting2.setBackgroundImage(UIImage(named: "btn_comment_purple.png"), for: .normal)
                } else if carte.doc[i].sub_type == 3 {
                    btnHandwriting3.setBackgroundImage(UIImage(named: "btn_comment_purple.png"), for: .normal)
                } else if carte.doc[i].sub_type == 4 {
                    btnCounselling4.setBackgroundImage(UIImage(named: "btn_comment_purple.png"), for: .normal)
                }
            default:
                break
            }
        }
    }
    
    fileprivate func convertDateTime(date:Date) {
        let dayDateFormatter = DateFormatter()
        dayDateFormatter.dateFormat = "yyyy年MM月dd日"
        let dayTimeDateFormatter = DateFormatter()
        dayTimeDateFormatter.dateFormat = "HH時mm分"
        
        let strDate = dayDateFormatter.string(from: date)
        let strTime = dayTimeDateFormatter.string(from: date)
        let strWeek = "\(Utils.getDayOfWeek(strDate) ?? "")"
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCarteTime.rawValue) {
            lblDate.text = strDate + strWeek + strTime
        } else {
            lblDate.text = strDate + strWeek
        }
    }
    
    fileprivate func setDocumentEmpty(type:Int) {
        switch type {
        case 1:
            btnCounselling1.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
            btnCounselling2.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
            btnCounselling3.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
            btnCounselling4.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
        case 2:
            btnConsent1.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
            btnConsent2.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
            btnConsent3.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
            btnConsent4.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
        case 3:
            btnHandwriting1.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
            btnHandwriting2.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
            btnHandwriting3.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
            btnCounselling4.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
        default:
            break
        }
    }
    
    fileprivate func setMemoUnSelect(position:Int,title:String,content:String) {
        switch position {
        case 1:
            btnFree1.setTitle("\(title)", for: .normal)
            btnFree1.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
        case 2:
            btnFree2.setTitle("\(title)", for: .normal)
            btnFree2.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
        case 3:
            btnFree3.setTitle("\(title)", for: .normal)
            btnFree3.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
        case 4:
            btnFree4.setTitle("\(title)", for: .normal)
            btnFree4.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
        default:
            break
        }
    }

    fileprivate func setFreeMemo(position:Int,title:String,content:String) {
        switch position {
        case 1:
            if content.isEmpty {
                btnFree1.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
            } else {
                btnFree1.setTitle("\(title)", for: .normal)
                btnFree1.setBackgroundImage(UIImage(named: "btn_comment_red.png"), for: .normal)
            }
        case 2:
            if content.isEmpty {
                btnFree2.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
            } else {
                btnFree2.setTitle("\(title)", for: .normal)
                btnFree2.setBackgroundImage(UIImage(named: "btn_comment_red.png"), for: .normal)
            }
        case 3:
            if content.isEmpty {
                btnFree3.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
            } else {
                btnFree3.setTitle("\(title)", for: .normal)
                btnFree3.setBackgroundImage(UIImage(named: "btn_comment_red.png"), for: .normal)
            }
        case 4:
            if content.isEmpty {
                btnFree4.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
            } else {
                btnFree4.setTitle("\(title)", for: .normal)
                btnFree4.setBackgroundImage(UIImage(named: "btn_comment_red.png"), for: .normal)
            }
        default:
            break
        }
    }
    
    fileprivate func setStampMemoUnSelect(position:Int,title:String,content:String) {
        switch position {
        case 5:
            btnStamp1.setTitle("\(title)", for: .normal)
            btnStamp1.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
        case 6:
            btnStamp2.setTitle("\(title)", for: .normal)
            btnStamp2.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
        case 7:
            btnStamp3.setTitle("\(title)", for: .normal)
            btnStamp3.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
        case 8:
            btnStamp4.setTitle("\(title)", for: .normal)
            btnStamp4.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
        default:
            break
        }
    }
    
    fileprivate func setStampMemo(position:Int,title:String,content:String) {
        switch position {
        case 5:
            if content.isEmpty {
                btnStamp1.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
            } else {
                btnStamp1.setBackgroundImage(UIImage(named: "btn_comment_blue.png"), for: .normal)
            }
        case 6:
            if content.isEmpty {
                btnStamp2.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
            } else {
                btnStamp2.setBackgroundImage(UIImage(named: "btn_comment_blue.png"), for: .normal)
            }
        case 7:
            if content.isEmpty {
                btnStamp3.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
            } else {
                btnStamp3.setBackgroundImage(UIImage(named: "btn_comment_blue.png"), for: .normal)
            }
        case 8:
            if content.isEmpty {
                btnStamp4.setBackgroundImage(UIImage(named: "btn_comment_gray.png"), for: .normal)
            } else {
                btnStamp4.setBackgroundImage(UIImage(named: "btn_comment_blue.png"), for: .normal)
            }
        default:
            break
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************

    @IBAction func onAvatarPress(_ sender: UIButton) {
        delegate?.didAvatarPress(tag: sender.tag)
    }
    
    @IBAction func onCounsellingSelect(_ sender: UIButton) {
        delegate?.didCounsellingPress(cellIndex: cellIndex!, index: sender.tag)
    }
    
    @IBAction func onConsentSelect(_ sender: UIButton) {
        delegate?.didConsentPress(cellIndex: cellIndex!, index: sender.tag)
    }
    
    @IBAction func onHandwritingSelect(_ sender: UIButton) {
        delegate?.didHandwrittingPress(cellIndex: cellIndex!, index: sender.tag)
    }
    
    @IBAction func onFreeMemoSelect(_ sender: UIButton) {
        delegate?.didFreeMemoPress(cellIndex: cellIndex!, index: sender.tag)
    }
    
    @IBAction func onStampMemoSelect(_ sender: UIButton) {
        delegate?.didStampMemoPress(cellIndex: cellIndex!, index: sender.tag)
    }
    
    @IBAction func onEditCarte(_ sender: UIButton) {
        delegate?.onEditCarte(cellIndex: cellIndex!)
    }
}
