//
//  SyllabaryPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/07/06.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol SyllabaryPopupVCDelegate: class {
    func onSyllabarySearch(characters:[String])
}

class SyllabaryPopupVC: UIViewController {

    //Variable
    weak var delegate:SyllabaryPopupVCDelegate?
    
    var alphaSelect = [Int]()
    var alphabetDict : [Int: String] = [1:"あ",
                                        2:"い",
                                        3:"う",
                                        4:"え",
                                        5:"お",
                                        6:"か",
                                        7:"き",
                                        8:"く",
                                        9:"け",
                                        10:"こ",
                                        11:"さ",
                                        12:"し",
                                        13:"す",
                                        14:"せ",
                                        15:"そ",
                                        16:"た",
                                        17:"ち",
                                        18:"つ",
                                        19:"て",
                                        20:"と",
                                        21:"な",
                                        22:"に",
                                        23:"ぬ",
                                        24:"ね",
                                        25:"の",
                                        26:"は",
                                        27:"ひ",
                                        28:"ふ",
                                        29:"へ",
                                        30:"ほ",
                                        31:"ま",
                                        32:"み",
                                        33:"む",
                                        34:"め",
                                        35:"も",
                                        36:"や",
                                        37:"ゆ",
                                        38:"よ",
                                        39:"ら",
                                        40:"り",
                                        41:"る",
                                        42:"れ",
                                        43:"ろ",
                                        44:"わ",
                                        45:"を",
                                        46:"ん",
                                        51:"A",
                                        52:"B",
                                        53:"C",
                                        54:"D",
                                        55:"E",
                                        56:"F",
                                        57:"G",
                                        58:"H",
                                        59:"I",
                                        60:"J",
                                        61:"K",
                                        62:"L",
                                        63:"M",
                                        64:"N",
                                        65:"O",
                                        66:"P",
                                        67:"Q",
                                        68:"R",
                                        69:"S",
                                        70:"T",
                                        71:"U",
                                        72:"V",
                                        73:"W",
                                        74:"X",
                                        75:"Y",
                                        76:"Z",
                                        77:"1",
                                        78:"2",
                                        79:"3",
                                        80:"4",
                                        81:"5",
                                        82:"6",
                                        83:"7",
                                        84:"8",
                                        85:"9"
    ]
    
    //Japanese Alphabet
    @IBOutlet weak var a: RoundButton!
    @IBOutlet weak var i: RoundButton!
    @IBOutlet weak var u: RoundButton!
    @IBOutlet weak var e: RoundButton!
    @IBOutlet weak var o: RoundButton!
    @IBOutlet weak var ka: RoundButton!
    @IBOutlet weak var ki: RoundButton!
    @IBOutlet weak var ku: RoundButton!
    @IBOutlet weak var ke: RoundButton!
    @IBOutlet weak var ko: RoundButton!
    @IBOutlet weak var sa: RoundButton!
    @IBOutlet weak var shi: RoundButton!
    @IBOutlet weak var su: RoundButton!
    @IBOutlet weak var se: RoundButton!
    @IBOutlet weak var so: RoundButton!
    @IBOutlet weak var ta: RoundButton!
    @IBOutlet weak var chi: RoundButton!
    @IBOutlet weak var tsu: RoundButton!
    @IBOutlet weak var te: RoundButton!
    @IBOutlet weak var to: RoundButton!
    @IBOutlet weak var na: RoundButton!
    @IBOutlet weak var ni: RoundButton!
    @IBOutlet weak var nu: RoundButton!
    @IBOutlet weak var ne: RoundButton!
    @IBOutlet weak var no: RoundButton!
    @IBOutlet weak var ha: RoundButton!
    @IBOutlet weak var hi: RoundButton!
    @IBOutlet weak var fu: RoundButton!
    @IBOutlet weak var he: RoundButton!
    @IBOutlet weak var ho: RoundButton!
    @IBOutlet weak var ma: RoundButton!
    @IBOutlet weak var mi: RoundButton!
    @IBOutlet weak var mu: RoundButton!
    @IBOutlet weak var me: RoundButton!
    @IBOutlet weak var mo: RoundButton!
    @IBOutlet weak var ya: RoundButton!
    @IBOutlet weak var yu: RoundButton!
    @IBOutlet weak var yo: RoundButton!
    @IBOutlet weak var ra: RoundButton!
    @IBOutlet weak var ri: RoundButton!
    @IBOutlet weak var ru: RoundButton!
    @IBOutlet weak var re: RoundButton!
    @IBOutlet weak var ro: RoundButton!
    @IBOutlet weak var wa: RoundButton!
    @IBOutlet weak var wo: RoundButton!
    @IBOutlet weak var n: RoundButton!
    
    //Eng Alphabet
    @IBOutlet weak var AA: RoundButton!
    @IBOutlet weak var BB: RoundButton!
    @IBOutlet weak var CC: RoundButton!
    @IBOutlet weak var DD: RoundButton!
    @IBOutlet weak var EE: RoundButton!
    @IBOutlet weak var FF: RoundButton!
    @IBOutlet weak var GG: RoundButton!
    @IBOutlet weak var HH: RoundButton!
    @IBOutlet weak var II: RoundButton!
    @IBOutlet weak var JJ: RoundButton!
    @IBOutlet weak var KK: RoundButton!
    @IBOutlet weak var LL: RoundButton!
    @IBOutlet weak var MM: RoundButton!
    @IBOutlet weak var NN: RoundButton!
    @IBOutlet weak var OO: RoundButton!
    @IBOutlet weak var PP: RoundButton!
    @IBOutlet weak var QQ: RoundButton!
    @IBOutlet weak var RR: RoundButton!
    @IBOutlet weak var SS: RoundButton!
    @IBOutlet weak var TT: RoundButton!
    @IBOutlet weak var UU: RoundButton!
    @IBOutlet weak var VV: RoundButton!
    @IBOutlet weak var WW: RoundButton!
    @IBOutlet weak var XX: RoundButton!
    @IBOutlet weak var YY: RoundButton!
    @IBOutlet weak var ZZ: RoundButton!
    @IBOutlet weak var no1: RoundButton!
    @IBOutlet weak var no2: RoundButton!
    @IBOutlet weak var no3: RoundButton!
    @IBOutlet weak var no4: RoundButton!
    @IBOutlet weak var no5: RoundButton!
    @IBOutlet weak var no6: RoundButton!
    @IBOutlet weak var no7: RoundButton!
    @IBOutlet weak var no8: RoundButton!
    @IBOutlet weak var no9: RoundButton!
    
    @IBOutlet weak var rowA: RoundButton!
    @IBOutlet weak var rowKA: RoundButton!
    @IBOutlet weak var rowSA: RoundButton!
    @IBOutlet weak var rowTA: RoundButton!
    @IBOutlet weak var rowNA: RoundButton!
    @IBOutlet weak var rowHA: RoundButton!
    @IBOutlet weak var rowMA: RoundButton!
    @IBOutlet weak var rowYA: RoundButton!
    @IBOutlet weak var rowRA: RoundButton!
    @IBOutlet weak var rowWA: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        unSelectedAll()
    }
   
    func unSelectedAll() {
        rowA.alpha = 0.5
        rowKA.alpha = 0.5
        rowSA.alpha = 0.5
        rowTA.alpha = 0.5
        rowNA.alpha = 0.5
        rowHA.alpha = 0.5
        rowMA.alpha = 0.5
        rowYA.alpha = 0.5
        rowRA.alpha = 0.5
        rowWA.alpha = 0.5
        
        a.backgroundColor = UIColor.clear
        i.backgroundColor = UIColor.clear
        u.backgroundColor = UIColor.clear
        e.backgroundColor = UIColor.clear
        o.backgroundColor = UIColor.clear
        ka.backgroundColor = UIColor.clear
        ki.backgroundColor = UIColor.clear
        ku.backgroundColor = UIColor.clear
        ke.backgroundColor = UIColor.clear
        ko.backgroundColor = UIColor.clear
        sa.backgroundColor = UIColor.clear
        shi.backgroundColor = UIColor.clear
        su.backgroundColor = UIColor.clear
        se.backgroundColor = UIColor.clear
        so.backgroundColor = UIColor.clear
        ta.backgroundColor = UIColor.clear
        chi.backgroundColor = UIColor.clear
        tsu.backgroundColor = UIColor.clear
        te.backgroundColor = UIColor.clear
        to.backgroundColor = UIColor.clear
        na.backgroundColor = UIColor.clear
        ni.backgroundColor = UIColor.clear
        nu.backgroundColor = UIColor.clear
        ne.backgroundColor = UIColor.clear
        no.backgroundColor = UIColor.clear
        ha.backgroundColor = UIColor.clear
        hi.backgroundColor = UIColor.clear
        fu.backgroundColor = UIColor.clear
        he.backgroundColor = UIColor.clear
        ho.backgroundColor = UIColor.clear
        ma.backgroundColor = UIColor.clear
        mi.backgroundColor = UIColor.clear
        mu.backgroundColor = UIColor.clear
        me.backgroundColor = UIColor.clear
        mo.backgroundColor = UIColor.clear
        ya.backgroundColor = UIColor.clear
        yu.backgroundColor = UIColor.clear
        yo.backgroundColor = UIColor.clear
        ra.backgroundColor = UIColor.clear
        ri.backgroundColor = UIColor.clear
        ru.backgroundColor = UIColor.clear
        re.backgroundColor = UIColor.clear
        ro.backgroundColor = UIColor.clear
        wa.backgroundColor = UIColor.clear
        wo.backgroundColor = UIColor.clear
        n.backgroundColor = UIColor.clear
        
        a.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        i.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        u.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        e.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        o.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        ka.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        ki.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        ku.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        ke.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        ko.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        sa.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        shi.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        su.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        se.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        so.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        ta.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        chi.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        tsu.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        te.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        to.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        na.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        ni.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        nu.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        ne.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        no.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        ha.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        hi.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        fu.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        he.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        ho.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        ma.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        mi.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        mu.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        me.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        mo.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        ya.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        yu.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        yo.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        ra.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        ri.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        ru.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        re.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        ro.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        wa.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        wo.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        n.setTitleColor(COLOR_SET.kBLUENAVY, for: .normal)
        
        AA.backgroundColor = UIColor.clear
        BB.backgroundColor = UIColor.clear
        CC.backgroundColor = UIColor.clear
        DD.backgroundColor = UIColor.clear
        EE.backgroundColor = UIColor.clear
        FF.backgroundColor = UIColor.clear
        GG.backgroundColor = UIColor.clear
        HH.backgroundColor = UIColor.clear
        II.backgroundColor = UIColor.clear
        JJ.backgroundColor = UIColor.clear
        KK.backgroundColor = UIColor.clear
        LL.backgroundColor = UIColor.clear
        MM.backgroundColor = UIColor.clear
        NN.backgroundColor = UIColor.clear
        OO.backgroundColor = UIColor.clear
        PP.backgroundColor = UIColor.clear
        QQ.backgroundColor = UIColor.clear
        RR.backgroundColor = UIColor.clear
        SS.backgroundColor = UIColor.clear
        TT.backgroundColor = UIColor.clear
        UU.backgroundColor = UIColor.clear
        VV.backgroundColor = UIColor.clear
        WW.backgroundColor = UIColor.clear
        XX.backgroundColor = UIColor.clear
        YY.backgroundColor = UIColor.clear
        ZZ.backgroundColor = UIColor.clear
        
        no1.backgroundColor = UIColor.clear
        no2.backgroundColor = UIColor.clear
        no3.backgroundColor = UIColor.clear
        no4.backgroundColor = UIColor.clear
        no5.backgroundColor = UIColor.clear
        no6.backgroundColor = UIColor.clear
        no7.backgroundColor = UIColor.clear
        no8.backgroundColor = UIColor.clear
        no9.backgroundColor = UIColor.clear
    }

    func selectButton(button:UIButton,tag:Int) {
        if alphaSelect.contains(tag) {
            button.backgroundColor = UIColor.clear
            if let index = alphaSelect.firstIndex(of: tag) {
                alphaSelect.remove(at: index)
            }
        } else {
            button.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            alphaSelect.append(tag)
        }
    }
    
    func selectButtonWithoutRemove(button:UIButton,tag:Int) {
        if alphaSelect.contains(tag) {
            //do nothing
        } else {
            button.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            alphaSelect.append(tag)
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onRowSelect(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            selectButtonWithoutRemove(button: a, tag: a.tag)
            selectButtonWithoutRemove(button: i, tag: i.tag)
            selectButtonWithoutRemove(button: u, tag: u.tag)
            selectButtonWithoutRemove(button: e, tag: e.tag)
            selectButtonWithoutRemove(button: o, tag: o.tag)
        case 2:
            selectButtonWithoutRemove(button: ka, tag: ka.tag)
            selectButtonWithoutRemove(button: ki, tag: ki.tag)
            selectButtonWithoutRemove(button: ku, tag: ku.tag)
            selectButtonWithoutRemove(button: ke, tag: ke.tag)
            selectButtonWithoutRemove(button: ko, tag: ko.tag)
        case 3:
            selectButtonWithoutRemove(button: sa, tag: sa.tag)
            selectButtonWithoutRemove(button: shi, tag: shi.tag)
            selectButtonWithoutRemove(button: su, tag: su.tag)
            selectButtonWithoutRemove(button: se, tag: se.tag)
            selectButtonWithoutRemove(button: so, tag: so.tag)
        case 4:
            selectButtonWithoutRemove(button: ta, tag: ta.tag)
            selectButtonWithoutRemove(button: chi, tag: chi.tag)
            selectButtonWithoutRemove(button: tsu, tag: tsu.tag)
            selectButtonWithoutRemove(button: te, tag: te.tag)
            selectButtonWithoutRemove(button: to, tag: to.tag)
        case 5:
            selectButtonWithoutRemove(button: na, tag: na.tag)
            selectButtonWithoutRemove(button: ni, tag: ni.tag)
            selectButtonWithoutRemove(button: nu, tag: nu.tag)
            selectButtonWithoutRemove(button: ne, tag: ne.tag)
            selectButtonWithoutRemove(button: no, tag: no.tag)
        case 6:
            selectButtonWithoutRemove(button: ha, tag: ha.tag)
            selectButtonWithoutRemove(button: hi, tag: hi.tag)
            selectButtonWithoutRemove(button: fu, tag: fu.tag)
            selectButtonWithoutRemove(button: he, tag: he.tag)
            selectButtonWithoutRemove(button: ho, tag: ho.tag)
        case 7:
            selectButtonWithoutRemove(button: ma, tag: ma.tag)
            selectButtonWithoutRemove(button: mi, tag: mi.tag)
            selectButtonWithoutRemove(button: mu, tag: mu.tag)
            selectButtonWithoutRemove(button: me, tag: me.tag)
            selectButtonWithoutRemove(button: mo, tag: mo.tag)
        case 8:
            selectButtonWithoutRemove(button: ya, tag: ya.tag)
            selectButtonWithoutRemove(button: yu, tag: yu.tag)
            selectButtonWithoutRemove(button: yo, tag: yo.tag)
        case 9:
            selectButtonWithoutRemove(button: ra, tag: ra.tag)
            selectButtonWithoutRemove(button: ri, tag: ri.tag)
            selectButtonWithoutRemove(button: ru, tag: ru.tag)
            selectButtonWithoutRemove(button: re, tag: re.tag)
            selectButtonWithoutRemove(button: ro, tag: ro.tag)
        case 10:
            selectButtonWithoutRemove(button: wa, tag: wa.tag)
            selectButtonWithoutRemove(button: wo, tag: wo.tag)
            selectButtonWithoutRemove(button: n, tag: n.tag)
        default:
            break
        }
    }
    
    @IBAction func alphabetSelected(_ sender: UIButton) {
        selectButton(button: sender, tag: sender.tag)
    }
    
    @IBAction func onSearch(_ sender: UIButton) {
        var resultArr = [String]()
        for number in alphaSelect {
            let index = alphabetDict.index(forKey: number)
            resultArr.append(alphabetDict[index!].value)
            resultArr.append(contentsOf: addExtraCharacters(number: number))
        }
        self.delegate?.onSyllabarySearch(characters:resultArr)
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func addExtraCharacters(number: Int)->[String] {
        switch number {
        case 1:
            return ["ぁ"]
        case 2:
            return ["ぃ"]
        case 3:
            return ["ぅ"]
        case 4:
            return ["ぇ"]
        case 5:
            return ["ぉ"]
        case 6:
            return ["が"]
        case 7:
            return ["ぎ"]
        case 8:
            return ["ぐ"]
        case 9:
            return ["げ"]
        case 10:
            return ["ご"]
        case 11:
            return ["ざ"]
        case 12:
            return ["じ"]
        case 13:
            return ["ず"]
        case 14:
            return ["ぜ"]
        case 15:
            return ["ぞ"]
        case 16:
            return ["だ"]
        case 17:
            return ["ぢ"]
        case 18:
            return ["づ","っ"]
        case 19:
            return ["で"]
        case 20:
            return ["ど"]
        case 26:
            return ["ば","ぱ"]
        case 27:
            return ["び","ぴ"]
        case 28:
            return ["ぶ","ぷ"]
        case 29:
            return ["べ","ぺ"]
        case 30:
            return ["ぼ","ぽ"]
        case 36:
            return ["ゃ"]
        case 37:
            return ["ゅ"]
        case 38:
            return ["ょ"]
        default:
            return []
        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
