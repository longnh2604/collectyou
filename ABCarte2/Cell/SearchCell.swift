//
//  SearchCell.swift
//  ABCarte2
//
//  Created by Long on 2018/05/11.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    //IBOutlet
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewBG: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if let set = UserPreferences.appColorSet {
            switch set {
            case AppColorSet.standard.rawValue:
                viewBG.backgroundColor = COLOR_SET000.kEDIT_SCREEN_BACKGROUND_COLOR
            case AppColorSet.jbsattender.rawValue:
                viewBG.backgroundColor = COLOR_SET001.kEDIT_SCREEN_BACKGROUND_COLOR
            case AppColorSet.romanpink.rawValue:
                viewBG.backgroundColor = COLOR_SET002.kEDIT_SCREEN_BACKGROUND_COLOR
            case AppColorSet.hisul.rawValue:
                viewBG.backgroundColor = COLOR_SET003.kEDIT_SCREEN_BACKGROUND_COLOR
            case AppColorSet.lavender.rawValue:
                viewBG.backgroundColor = COLOR_SET004.kEDIT_SCREEN_BACKGROUND_COLOR
            case AppColorSet.pinkgold.rawValue:
                viewBG.backgroundColor = COLOR_SET005.kEDIT_SCREEN_BACKGROUND_COLOR
            case AppColorSet.mysteriousnight.rawValue:
                viewBG.backgroundColor = COLOR_SET006.kEDIT_SCREEN_BACKGROUND_COLOR
            case AppColorSet.gardenparty.rawValue:
                viewBG.backgroundColor = COLOR_SET007.kEDIT_SCREEN_BACKGROUND_COLOR
            default:
                break
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
