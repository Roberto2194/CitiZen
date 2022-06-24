//
//  OnBoardingCollectionViewCell.swift
//  citZen
//
//  Created by Domenico Varchetta on 10/06/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class OnBoardingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pageImageView: UIImageView!
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var pageDescription: UILabel!
    @IBOutlet weak var playerView: UIView!
    
    static var avPlayerLayer : AVPlayerLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(page: Page) {
        self.pageImageView.image = UIImage(named: page.imageName)
        self.pageTitle.text = page.title
        self.pageDescription.text = page.description
    }
    
    @objc func videoLoop() {
      OnBoardingCollectionViewCell.avPlayerLayer?.player?.pause()
        OnBoardingCollectionViewCell.avPlayerLayer?.player?.seek(to: CMTime.zero)
      OnBoardingCollectionViewCell.avPlayerLayer?.player?.play()
    }
    
    func playVideo() {
		guard  let videoPath = Bundle.main.path(forResource: "videoTutorial", ofType: "mp4") else {
			print("Errore Lettura")
			return
		}
		
        let playerURL = URL(fileURLWithPath: videoPath)
        
        let player = AVPlayer(url: playerURL)
        OnBoardingCollectionViewCell.avPlayerLayer = AVPlayerLayer(player: player)
        
        OnBoardingCollectionViewCell.avPlayerLayer?.frame = self.playerView.bounds
        OnBoardingCollectionViewCell.avPlayerLayer?.fillMode = .both
        self.playerView.layer.addSublayer(OnBoardingCollectionViewCell.avPlayerLayer!)
        OnBoardingCollectionViewCell.avPlayerLayer?.player?.actionAtItemEnd = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.videoLoop), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: OnBoardingCollectionViewCell.avPlayerLayer?.player?.currentItem)
    }
    
    
    
}
