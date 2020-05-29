//
//  VideoMainVC.swift
//  ABCarte2
//
//  Created by Long on 2019/04/11.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import AVFoundation
import MMPlayerView
import RealmSwift

class VideoMainVC: UIViewController {
    var videos: Results<VideoData>!
    var videosData : [VideoData] = []
    
    var offsetObservation: NSKeyValueObservation?
    lazy var mmPlayerLayer: MMPlayerLayer = {
        let l = MMPlayerLayer()
        l.cacheType = .memory(count: 5)
        l.coverFitType = .fitToPlayerView
        l.videoGravity = AVLayerVideoGravity.resizeAspect
        l.replace(cover: CoverA.instantiateFromNib())
        l.repeatWhenEnd = true
        return l
    }()
    
    @IBOutlet weak var playerCollect: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVideoStream()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
        offsetObservation?.invalidate()
        offsetObservation = nil
        print("ViewController deinit")
    }
    
    fileprivate func setupLayout() {
        //navigation title
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationItem.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "動画画面", comment: "")
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.contentMode = .scaleAspectFit
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(VideoData.self))
        }
        
        APIRequest.onGetAllVideos { (success) in
            if success {
                self.videos = realm.objects(VideoData.self)
                self.videosData.removeAll()
                
                for i in 0 ..< self.videos.count {
                    self.videosData.append(self.videos[i])
                }
                
                self.playerCollect.reloadData()
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupVideoStream() {
        // remove previous download fails file
        MMPlayerDownloader.cleanTmpFile()
        self.navigationController?.mmPlayerTransition.push.pass(setting: { (_) in
            
        })
        offsetObservation = playerCollect.observe(\.contentOffset, options: [.new]) { [weak self] (_, value) in
            guard let self = self, self.presentedViewController == nil else {return}
            self.updateByContentOffset()
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(self.startLoading), with: nil, afterDelay: 0.3)
        }
        playerCollect.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.updateByContentOffset()
            self?.startLoading()
        }
        
        mmPlayerLayer.getStatusBlock { [weak self] (status) in
            switch status {
            case .failed(let err):
                let alert = UIAlertController(title: "err", message: err.description, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            case .ready:
                print("Ready to Play")
            case .playing:
                print("Playing")
            case .pause:
                print("Pause")
            case .end:
                print("End")
            default: break
            }
        }
        mmPlayerLayer.getOrientationChange { (status) in
            print("Player OrientationChange \(status)")
        }
    }
}

// This protocol use to pass playerLayer to second UIViewcontroller
extension VideoMainVC: MMPlayerFromProtocol {
    // when second controller pop or dismiss, this help to put player back to where you want
    // original was player last view ex. it will be nil because of this view on reuse view
    func backReplaceSuperView(original: UIView?) -> UIView? {
        playerCollect.reloadData()
        setupVideoStream()
        return original
    }
    
    // add layer to temp view and pass to another controller
    var passPlayer: MMPlayerLayer {
        return self.mmPlayerLayer
    }
    // current playview is cell.image hide prevent ui error
    func transitionWillStart() {
        self.mmPlayerLayer.playView?.isHidden = true
    }
    // show cell.image
    func transitionCompleted() {
        self.mmPlayerLayer.playView?.isHidden = false
    }
    
    func dismissViewFromGesture() {
        mmPlayerLayer.thumbImageView.image = nil
        self.updateByContentOffset()
        self.startLoading()
    }
    
    func presentedView(isShrinkVideo: Bool) {
        self.playerCollect.visibleCells.forEach {
            if ($0 as? PlayerCell)?.imgView.isHidden == true && isShrinkVideo {
                ($0 as? PlayerCell)?.imgView.isHidden = false
            }
        }
    }
}

extension VideoMainVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let m = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        return CGSize.init(width: m, height: m*0.75)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async { [unowned self] in
            if self.presentedViewController != nil {
                self.playerCollect.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                self.updateDetail(at: indexPath)
            } else {
                self.presentDetail(at: indexPath)
            }
        }
    }
    
    fileprivate func updateByContentOffset() {
        let p = CGPoint(x: playerCollect.frame.width/2, y: playerCollect.contentOffset.y + playerCollect.frame.width/2)
        
        if let path = playerCollect.indexPathForItem(at: p),
            self.presentedViewController == nil {
            self.updateCell(at: path)
        }
    }
    
    fileprivate func updateDetail(at indexPath: IndexPath) {
        let value = videosData[indexPath.row]
        if let detail = self.presentedViewController as? VideoPlayerView {
            detail.data = value
        }
        let url = URL(string: value.thumbnail)
        let data = try? Data(contentsOf: url!)
        self.mmPlayerLayer.thumbImageView.image = UIImage(data: data!)
        self.mmPlayerLayer.set(url: URL(string: videosData[indexPath.row].url))
        self.mmPlayerLayer.resume()
    }
    
    fileprivate func presentDetail(at indexPath: IndexPath) {
        self.updateCell(at: indexPath)
        self.startLoading()
        if let vc = UIStoryboard.init(name: "Video", bundle: nil).instantiateViewController(withIdentifier: "VideoPlayerView") as? VideoPlayerView {
            vc.data = videosData[indexPath.row]
            vc.videosData = videosData
            self.present(vc, animated: true, completion: nil)
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    fileprivate func updateCell(at indexPath: IndexPath) {
        if let cell = playerCollect.cellForItem(at: indexPath) as? PlayerCell, let playURL = URL(string: cell.data!.url) {
            // this thumb use when transition start and your video dosent start
            mmPlayerLayer.thumbImageView.image = cell.imgView.image
            // set video where to play
            mmPlayerLayer.playView = cell.imgView
            mmPlayerLayer.set(url: playURL)
        }
    }
    
    @objc fileprivate func startLoading() {
        if self.presentedViewController != nil {
            return
        }
        // start loading video
        mmPlayerLayer.resume()
    }
    
}

extension VideoMainVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videosData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCell", for: indexPath) as? PlayerCell {
            cell.data = videosData[indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
}
