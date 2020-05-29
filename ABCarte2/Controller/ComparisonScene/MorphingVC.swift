//
//  MorphingVC.swift
//  ABCarte2
//
//  Created by Long on 2018/07/30.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage

class MorphingVC: UIViewController, UIScrollViewDelegate {
    
    //Variable
    var customer = CustomerData()
    var carte = CarteData()
    var mediasData : [MediaData] = []
    var cartesData : [CarteData] = []
    var lockStatus: Bool = false
    var currIndex: Int?
    var lastIndex: Int?
    var onSlideIndex: Int?
    var imageConverted: Data?
    var carteIDTemp: Int?
    var onTemp: Bool = false
    var startPosition: CGPoint?
    
    //IBOutlet
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var lblDayCome: UILabel!
    @IBOutlet weak var collectionImg: UICollectionView!
    @IBOutlet weak var viewGeneral: UIView!
    @IBOutlet weak var sliderTrans: MySlider!
    @IBOutlet weak var btnLock: RoundButton!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }

    fileprivate func setupLayout() {
        //set navigation bar title
        let logo = UIImage(named: "CarteImageNav.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView

        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton

        updateTopView()

        collectionImg.delegate = self
        collectionImg.dataSource = self

        arrangeImage()
        currIndex = 0
        lastIndex = 0

        sliderTrans.minimumValue = 1
        sliderTrans.maximumValue = Float(mediasData.count)
        sliderTrans.value = 1

        sliderTrans.isEnabled = true
        viewGeneral.isUserInteractionEnabled = false
        
        sliderTrans.isContinuous = true
//        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updateSlider(timer:)), userInfo: nil, repeats: false)
    }
    
    fileprivate func updateTopView() {
        if customer.thumb != "" {
            let url = URL(string: customer.thumb)
            imvCus.sd_setImage(with: url, completed: nil)
        } else {
            imvCus.image = UIImage(named: "img_no_photo")
        }
        
        imvCus.layer.cornerRadius = 25
        imvCus.clipsToBounds = true
        
        lblCusName.text = customer.last_name + " " + customer.first_name
        
        if onTemp == false {
            let dayCome = Utils.convertUnixTimestamp(time: carte.select_date)
            lblDayCome.text = dayCome
        } else {
            let currDate = Date()
            let timeInterval = Int(currDate.timeIntervalSince1970)
            let date = Utils.convertUnixTimestamp(time: timeInterval)
            lblDayCome.text = date
        }
    }

    fileprivate func arrangeImage() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        for subview in viewGeneral.subviews {
            subview.removeFromSuperview()
        }

        for i in 0 ..< mediasData.count {
            
            let imageView = UIImageView()
            imageView.sd_setImage(with: URL(string: mediasData[i].url), completed: nil)
            imageView.frame = viewGeneral.bounds
            imageView.contentMode = .scaleAspectFit
            imageView.tag = i
            
            if i == 0 {
                imageView.alpha = 1
            } else {
                imageView.alpha = 0
            }
            
            imageView.isUserInteractionEnabled = true

            viewGeneral.addSubview(imageView)

        }
        viewGeneral.clipsToBounds = true
        
        SVProgressHUD.dismiss()
    }
    
    fileprivate func reArrangeImage() {
        
        for i in 0 ..< viewGeneral.subviews.count {
            
            if i == 0 {
                viewGeneral.subviews[i].alpha = 1
            } else {
                viewGeneral.subviews[i].alpha = 0
            }
        }
    }

    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        GlobalVariables.sharedManager.selectedImageIds.removeAll()
        _ = navigationController?.popViewController(animated: true)
    }

    //*****************************************************************
    // MARK: - Gestures
    //*****************************************************************

    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
    }

    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {

        // Allows smooth movement of stickers.
        if recognizer.state == .began || recognizer.state == .changed
        {
            let point = recognizer.location(in: self.viewGeneral)
            if let superview = self.viewGeneral
            {
                let restrictByPoint : CGFloat = 30.0
                let superBounds = CGRect(x: superview.bounds.origin.x + restrictByPoint, y: superview.bounds.origin.y + restrictByPoint, width: superview.bounds.size.width - 2*restrictByPoint, height: superview.bounds.size.height - 2*restrictByPoint)
                if (superBounds.contains(point))
                {
                    let translation = recognizer.translation(in: self.viewGeneral)
                    recognizer.view!.center = CGPoint(x: recognizer.view!.center.x + translation.x, y: recognizer.view!.center.y + translation.y)
                    recognizer.setTranslation(CGPoint.zero, in: self.viewGeneral)
                }
            }
        }

    }

    fileprivate func removeAllGestures() {
        for subview in viewGeneral.subviews {
            for recognizer in subview.gestureRecognizers ?? [] {
                subview.removeGestureRecognizer(recognizer)
            }
        }
    }

    fileprivate func onSaveImage(image: UIImage) {
        SVProgressHUD.showProgress(0.3, status: "サーバーにアップロード中:30%")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        self.imageConverted = image.jpegData(compressionQuality: 0.75)
        
        if onTemp == false {
            APIRequest.onAddMediaIntoCarte(carteID: self.carte.id, mediaData: self.imageConverted!) { (success) in
                if success {
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                }
                SVProgressHUD.dismiss()
            }
        } else {
            for i in 0 ..< cartesData.count {
                let today = Date()
                
                let date = Date(timeIntervalSince1970: TimeInterval(cartesData[i].select_date))
                let isSame = date.isInSameDay(date: today)
                
                if isSame {
                    APIRequest.onAddMediaIntoCarte(carteID: self.cartesData[i].id, mediaData: self.imageConverted!) { (success) in
                        if success {
                        } else {
                            Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                        }
                        SVProgressHUD.dismiss()
                    }
                    return
                } else {
                    if let carteID = self.carteIDTemp {
                        APIRequest.onAddMediaIntoCarte(carteID: carteID, mediaData: self.imageConverted!) { (success) in
                            if success {
                            } else {
                                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                            }
                            SVProgressHUD.dismiss()
                        }
                        return
                    }
                }
            }
            
            let currDate = Date()
            let timeInterval = Int(currDate.timeIntervalSince1970)
            
            //Create Carte first
            APIRequest.onAddCarteWithMedias(cusID: self.customer.id, date: timeInterval, mediaData: self.imageConverted!, completion: { (status,carteData) in
                if status == 1 {
                    self.onTemp = false
                    self.carteIDTemp = carteData.id
                    
                    Utils.showAlert(message: "画像の保存しました。", view: self)
                } else if status == 2 {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CARTE_EXISTS_ALREADY, view: self)
                     _ = self.navigationController?.popViewController(animated: true)
                } else {
                    Utils.showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
                }
                SVProgressHUD.dismiss()
            })
        }
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************

    @IBAction func onSlideTransChange(_ sender: UISlider) {
       
        let sliderValue = Int(sender.value)

        let remainder = sender.value.truncatingRemainder(dividingBy: 1)
       
        for i in 0 ..< viewGeneral.subviews.count {
            
            if viewGeneral.subviews[i].tag + 1 == sliderValue {
                viewGeneral.subviews[i].alpha = CGFloat(1 - remainder)
            } else if viewGeneral.subviews[i].tag + 1 == sliderValue + 1 {
                viewGeneral.subviews[i].alpha = CGFloat(remainder)
            } else {
                viewGeneral.subviews[i].alpha = 0
            }
        }
    }

    @IBAction func onLockScreen(_ sender: UIButton) {
        if lockStatus == false {
            
            lockStatus = true
            btnLock.setImage(UIImage(named:"icon_unlock"), for: .normal)
            
            collectionImg.isUserInteractionEnabled = true
            let index = IndexPath(row: 0, section: 0)
            collectionImg.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
            
            for i in 0 ..< viewGeneral.subviews.count {
                
                    if i == 0 {
                        viewGeneral.subviews[i].isUserInteractionEnabled = true
                        viewGeneral.subviews[i].alpha = 0.6
                        viewGeneral.subviews[i].addGestureRecognizer(panGesture)
                        viewGeneral.subviews[i].addGestureRecognizer(pinchGesture)
                    }
                    else if i == 1 {
                        viewGeneral.subviews[i].isUserInteractionEnabled = false
                        viewGeneral.subviews[i].alpha = 0.3
                    } else {
                        viewGeneral.subviews[i].isUserInteractionEnabled = false
                        viewGeneral.subviews[i].alpha = 0
                    }
            }
            viewGeneral.isUserInteractionEnabled = true
            sliderTrans.isEnabled = false
            
        } else {
            
            lockStatus = false
            btnLock.setImage(UIImage(named:"icon_lock"), for: .normal)
            
            //remove all select
            collectionImg.isUserInteractionEnabled = false
            if let indexPath = collectionImg.indexPathsForSelectedItems?.first {
                collectionImg.deselectItem(at: indexPath, animated: false)
            }
            
            viewGeneral.isUserInteractionEnabled = false
            sliderTrans.isEnabled = true
            sliderTrans.value = 1
            
            reArrangeImage()
        }
    }

    @IBAction func onSaveImage(_ sender: UIButton) {
        onSaveImage(image: Utils.saveImageEdit(viewMake: viewGeneral))
    }
    
}

//*****************************************************************
// MARK: - CollectionView Delegate
//*****************************************************************

extension MorphingVC: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MorphingCell", for: indexPath) as! MorphingCell
        cell.configure(media: mediasData[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediasData.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        removeAllGestures()
        currIndex = indexPath.row
        
        for i in 0 ..< viewGeneral.subviews.count {
            
            //first time select
            if currIndex == 0 && lastIndex == 0 {
                if i == 0 {
                    viewGeneral.subviews[i].isUserInteractionEnabled = true
                    viewGeneral.subviews[i].alpha = 0.6
                    viewGeneral.subviews[i].addGestureRecognizer(panGesture)
                    viewGeneral.subviews[i].addGestureRecognizer(pinchGesture)
                }
                else if i == 1 {
                    viewGeneral.subviews[i].isUserInteractionEnabled = false
                    viewGeneral.subviews[i].alpha = 0.3
                } else {
                    viewGeneral.subviews[i].isUserInteractionEnabled = false
                    viewGeneral.subviews[i].alpha = 0
                }
            } else {
                //not first time
                
                if currIndex == viewGeneral.subviews[i].tag {
                    viewGeneral.subviews[i].isUserInteractionEnabled = true
                    viewGeneral.subviews[i].alpha = 0.6
                    viewGeneral.subviews[i].addGestureRecognizer(panGesture)
                    viewGeneral.subviews[i].addGestureRecognizer(pinchGesture)
                    lastIndex = currIndex
                } else if viewGeneral.subviews[i].tag == 0 {
                    viewGeneral.subviews[i].isUserInteractionEnabled = false
                    viewGeneral.subviews[i].alpha = 0.3
                } else {
                    viewGeneral.subviews[i].isUserInteractionEnabled = false
                    viewGeneral.subviews[i].alpha = 0
                }
            }
        }
    }
}
