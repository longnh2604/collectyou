//
//  VideoPlayerView.swift
//  ABCarte2
//
//  Created by Long on 2019/05/10.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import MMPlayerView

class VideoPlayerView: UIViewController {
    
    var downloadObservation: MMPlayerObservation?
    var data: VideoData? {
        didSet {
            if !self.isViewLoaded {
                return
            }
//            self.addDownloadObservation()
        }
    }
    var videosData : [VideoData] = []
    fileprivate var playerLayer: MMPlayerLayer?
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var playerContainer: UIView!
    @IBOutlet weak var lblTag: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectSubVideo: UICollectionView!
    //    @IBOutlet weak var downloadBtn: UIButton!
//    @IBOutlet weak var progress: UIProgressView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.mmPlayerTransition.present.pass { (config) in
            config.duration = 0.3
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        if let d = data {
            self.title = d.title
            textView.text = d.desc
            lblTitle.text = " # " + d.title
            
            if d.tags.isEmpty {
                lblTag.text = ""
            } else {
                let arr = d.tags.components(separatedBy: ",")
                let stringArr = arr.map { String($0)}
                var string = ""
                for i in 0 ..< stringArr.count {
                    string.append(" #\(stringArr[i])")
                }
                lblTag.text = string
            }
        }
        
        collectSubVideo.delegate = self
        collectSubVideo.dataSource = self
        let nib = UINib(nibName: "SubVideoCell", bundle: nil)
        collectSubVideo.register(nib, forCellWithReuseIdentifier: "subVideoCell")
//        self.addDownloadObservation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        videosData.removeAll()
    }
    
//    fileprivate func addDownloadObservation() {
//
//        guard let downloadURL = self.data?.url else {
//            return
//        }
//        downloadObservation = MMPlayerDownloader.shared.observe(downloadURL: URL(string: downloadURL)!) { [weak self] (status) in
//            DispatchQueue.main.async {
//                self?.setWith(status: status)
//            }
//        }
//    }
    
//    func setWith(status: MMPlayerDownloader.DownloadStatus) {
//        switch status {
//        case .downloadWillStart:
//            self.downloadBtn.isHidden = true
//            self.progress.isHidden = false
//            self.progress.progress = 0
//        case .cancelled:
//            print("Cancel")
//        case .completed:
//            self.downloadBtn.setTitle("Delete", for: .normal)
//            self.downloadBtn.isHidden = false
//            self.progress.isHidden = true
//        case .downloading(let value):
//            self.downloadBtn.isHidden = true
//            self.progress.isHidden = false
//            self.progress.progress = value
//        case .failed(let err):
//            self.downloadBtn.setTitle("Download", for: .normal)
//            let alert = UIAlertController(title: err, message: "", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//            self.downloadBtn.isHidden = false
//            self.progress.isHidden = true
//        case .none:
//            self.downloadBtn.setTitle("Download", for: .normal)
//            self.downloadBtn.isHidden = false
//            self.progress.isHidden = true
//        case .exist:
//            self.downloadBtn.setTitle("Delete", for: .normal)
//            self.downloadBtn.isHidden = false
//            self.progress.isHidden = true
//        }
//
//    }
    
    @IBAction func shrinkVideoAction() {
        (self.presentationController as? MMPlayerPassViewPresentatinController)?.shrinkView()
    }
    
    @IBAction func dismiss() {
        self.dismiss(animated: true) {
            self.playerLayer?.invalidate()
        }
    }
    
//    @IBAction func downloadAction() {
//        guard let downloadURL = self.data?.url else {
//            return
//        }
//        if let info = MMPlayerDownloader.shared.localFileFrom(url: URL(string: downloadURL)!)  {
//            MMPlayerDownloader.shared.deleteVideo(info)
//            let alert = UIAlertController(title: "Delete completed", message: "", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//            return
//        }
//
//        DispatchQueue.main.async {
//            MMPlayerDownloader.shared.download(url: URL(string: downloadURL)!)
//        }
//    }
//    deinit {
//        print("DetailViewController deinit")
//    }
}

extension VideoPlayerView: MMPlayerToProtocol {
    
    func transitionCompleted(player: MMPlayerLayer) {
        self.playerLayer = player
    }
    
    var containerView: UIView {
        get {
            return playerContainer
        }
    }
}

extension VideoPlayerView: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videosData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"subVideoCell", for: indexPath) as! SubVideoCell
        cell.configure(video: videosData[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.data = videosData[indexPath.row]
        if let url = self.data?.url {
            self.playerLayer?.set(url: URL(string: url))
            self.playerLayer?.resume()
        }
        self.viewDidLoad()
    }
}
