//
//  OnBoardingViewController.swift
//  citZen
//
//  Created by Domenico Varchetta on 10/06/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit

import AVKit
import AVFoundation

class OnBoardingViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var onBoardingCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var onBoardingButton: UIButton!
    
    var pages: [Page] = [Page(imageName: "Artboard IMAGE ONBOARDING 1", title: "Join Call to Action", description: "Get involved and partecipate in sustainable challenges."),
                         Page(imageName: "Artboard IMAGE ONBOARDING 2", title: "Add Call to Action", description: "Become a better citizen, create your Call to Action."),
                         Page(imageName: "Artboard IMAGE ONBOARDING 3", title: "Check the Chart", description: "Discover your ranking position, find out how green you are."),
                         Page(imageName: "Artboard IMAGE ONBOARDING 3", title: "Video", description: "Video tutorial")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign the delegates to the ViewController
        self.onBoardingCollectionView.dataSource = self
        self.onBoardingCollectionView.delegate = self

        // set the number of pages to the number of Onboarding Screens
        self.pageControl.numberOfPages = self.pages.count
        
    }
    
    @IBAction func pageChanged(_ sender: Any) {
        let pc = sender as! UIPageControl
        
        if pc.currentPage == 3 {
            OnBoardingCollectionViewCell.avPlayerLayer?.player?.play()
        } else {
            OnBoardingCollectionViewCell.avPlayerLayer?.player?.pause()
            OnBoardingCollectionViewCell.avPlayerLayer?.player?.seek(to: CMTime.zero)
        }
        
        // scrolling the collectionView to the selected page
        self.onBoardingCollectionView.scrollToItem(at: IndexPath(item: pc.currentPage, section: 0),
                                    at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func getStartedPressed(_ sender: UIButton) {
        
        self.animateButton(sender)
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "LogIn") as! LoginViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCollectionViewCell", for: indexPath) as! OnBoardingCollectionViewCell
        if indexPath.row == 3 {
            cell.playVideo()
            cell.playerView.isHidden = false
        } else {
            cell.playerView.isHidden = true
        }
        cell.configureCell(page: pages[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.onBoardingCollectionView.frame.width, height: self.onBoardingCollectionView.frame.height)
    }
    
    // to update the UIPageControl
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        switch pageControl.currentPage {
            case 0 ... 2:
                OnBoardingCollectionViewCell.avPlayerLayer?.player?.pause()
                OnBoardingCollectionViewCell.avPlayerLayer?.player?.seek(to: CMTime.zero)
                self.onBoardingButton.setTitle("      Skip      ", for: .normal)
            case 3:
                OnBoardingCollectionViewCell.avPlayerLayer?.player?.play()
                self.onBoardingButton.setTitle("      Get started      ", for: .normal)
            default:
                break
        }
        print(pageControl.currentPage)
    }
    
    func animateButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }) { (_) in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                sender.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
}
