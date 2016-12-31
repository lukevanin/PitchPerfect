//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Luke Van In on 2016/12/31.
//  Copyright © 2016 Luke Van In. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var outerStackView: UIStackView!
    @IBOutlet weak var effects1StackView: UIStackView!
    @IBOutlet weak var effects2StackView: UIStackView!
    @IBOutlet weak var effects3StackView: UIStackView!
    
    var recordedAudioURL:URL!
    var audioFile:AVAudioFile!
    var audioEngine:AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
    enum ButtonType: Int {
        case slow = 0, fast, chipmunk, vader, echo, reverb
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI(.notPlaying)
    }
    
//    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
//        coordinator.animate(alongsideTransition: { [weak self] (context) in
//            guard let `self` = self else {
//                return
//            }
//            if newCollection.verticalSizeClass == .compact {
//                self.outerStackView.axis = .horizontal
//                self.effects1StackView.axis = .vertical
//                self.effects2StackView.axis = .vertical
//                self.effects3StackView.axis = .vertical
//            }
//            else {
//                self.outerStackView.axis = .vertical
//                self.effects1StackView.axis = .horizontal
//                self.effects2StackView.axis = .horizontal
//                self.effects3StackView.axis = .horizontal
//            }
//        }) { (context) in
//            
//        }
//    }
    
    // MARK: Actions
    
    @IBAction func playSoundForButton(_ sender: UIButton) {
        print("Play Sound Button Pressed")
        switch(ButtonType(rawValue: sender.tag)!) {
        case .slow:
            playSound(rate: 0.5)
        case .fast:
            playSound(rate: 1.5)
        case .chipmunk:
            playSound(pitch: 1000)
        case .vader:
            playSound(pitch: -1000)
        case .echo:
            playSound(echo: true)
        case .reverb:
            playSound(reverb: true)
        }
        
        configureUI(.playing)
    }
    
    @IBAction func stopButtonPressed(_ sender: AnyObject) {
        print("Stop Audio Button Pressed")
        stopAudio()
    }
}
