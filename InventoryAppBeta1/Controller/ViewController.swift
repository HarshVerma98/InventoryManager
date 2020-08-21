//
//  ViewController.swift
//  InventoryAppBeta1
//
//  Created by Harsh Verma on 18/05/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    var videoPlayer: AVPlayer?
    var layer: AVPlayerLayer?
    
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    func setup() {
        
    }

    override func viewWillAppear(_ animated: Bool) {
        setupVideo()
    }
    
    func setupVideo() {
        
        let path = Bundle.main.path(forResource: "Dwell", ofType: "mp4")
        
        guard path != nil else {
            return
        }
        let url = URL(fileURLWithPath: path!)
        
        let i = AVPlayerItem(url: url)
        
        videoPlayer = AVPlayer(playerItem: i)
        
        layer = AVPlayerLayer(player: videoPlayer!)
        
        layer?.frame = CGRect(x: -self.view.frame.size.width*1.5, y: 0, width: self.view.frame.size.width*4, height: self.view.frame.size.height/2)
        view.layer.insertSublayer(layer!, at: 0)
        videoPlayer?.playImmediately(atRate: 1.0)
        
    }
    
    
}

