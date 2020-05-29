//
//  penToolCell.swift
//  ABCarte2
//
//  Created by Long on 2019/03/14.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

class penToolCell: UICollectionViewCell {

    //IBOutlet
    @IBOutlet weak var imvButton: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewBlock: UIView!
    @IBOutlet weak var imvPay: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderWidth = 3.0
                layer.borderColor = COLOR_SET.kBORDER.cgColor
            } else {
                layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    func configure(type: Int,style:Int) {
        if style == 1 {
            switch type {
            case 0:
                imvButton.image = UIImage(named: "icon_draw_pen.png")
                lblTitle.text = "描画ペン"
            case 1:
                imvButton.image = UIImage(named: "icon_draw_shape.png")
                lblTitle.text = "形状"
            case 2:
                imvButton.image = UIImage(named: "icon_draw_eraser.png")
                lblTitle.text = "消ゴム"
            case 3:
                imvButton.image = UIImage(named: "icon_draw_stamp.png")
                lblTitle.text = "スタンプ"
            case 4:
                imvButton.image = UIImage(named: "icon_draw_pickcolor.png")
                lblTitle.text = "スポイト"
                if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kEyeDrop.rawValue) {
                    viewBlock.isHidden = false
                }
            case 5:
                imvButton.image = UIImage(named: "icon_draw_text.png")
                lblTitle.text = "テキスト"
                if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kTextSticker.rawValue) {
                    viewBlock.isHidden = false
                }
            case 6:
                imvButton.image = UIImage(named: "icon_draw_mosaic.png")
                lblTitle.text = "モザイク"
                if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMosaic.rawValue) {
                    viewBlock.isHidden = false
                }
            case 7:
                imvButton.image = UIImage(named: "icon_printer.png")
                lblTitle.text = "プリンター"
                if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kDrawingPrinter.rawValue) {
                    viewBlock.isHidden = false
                }
            default:
                break
            }
        } else {
            switch type {
            case 0:
                imvButton.image = UIImage(named: "icon_draw_pen.png")
                lblTitle.text = "描画ペン"
            case 1:
                imvButton.image = UIImage(named: "icon_draw_shape.png")
                lblTitle.text = "形状"
            case 2:
                imvButton.image = UIImage(named: "icon_draw_eraser.png")
                lblTitle.text = "消ゴム"
            case 3:
                imvButton.image = UIImage(named: "icon_draw_stamp.png")
                lblTitle.text = "スタンプ"
            case 4:
                imvButton.image = UIImage(named: "icon_draw_palette.png")
                lblTitle.text = "パレット"
            case 5:
                imvButton.image = UIImage(named: "icon_draw_save.png")
                lblTitle.text = "保存"
            case 6:
                imvButton.image = UIImage(named: "icon_draw_pickcolor.png")
                lblTitle.text = "スポイト"
                if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kEyeDrop.rawValue) {
                    viewBlock.isHidden = false
                }

            case 7:
                imvButton.image = UIImage(named: "icon_draw_text.png")
                lblTitle.text = "テキスト"
                if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kTextSticker.rawValue) {
                    viewBlock.isHidden = false
                }
            case 8:
                imvButton.image = UIImage(named: "icon_draw_mosaic.png")
                lblTitle.text = "モザイク"
                if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMosaic.rawValue) {
                    viewBlock.isHidden = false
                }
            case 9:
                imvButton.image = UIImage(named: "icon_printer.png")
                lblTitle.text = "プリンター"
                if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kDrawingPrinter.rawValue) {
                    viewBlock.isHidden = false
                }
            default:
                break
            }
        }
    }

}
