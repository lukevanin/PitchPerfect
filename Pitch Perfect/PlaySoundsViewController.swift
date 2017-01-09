//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Luke Van In on 2016/12/31.
//  Copyright © 2016 Luke Van In. All rights reserved.
//
//  Plays a recorded file using a variety of synthesized sound effects. The sound effects are produced by adjusting the
//  rate and pitch of the audio, as well as applying echo and reverb.
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
    
    // MARK: Actions
    
    //
    //  Sound effect button tapped. Play the current audio file with an applied sound effect.
    //  The button is determined by the tag property value set in interface builder, which corresponds to a ButtonType
    //  enum value.
    //
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
    
    //
    //  Stop button tapped. Stop playing audio.
    //
    @IBAction func stopButtonPressed(_ sender: AnyObject) {
        print("Stop Audio Button Pressed")
        stopAudio()
    }
}
