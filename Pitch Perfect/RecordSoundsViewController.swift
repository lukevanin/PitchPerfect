//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Luke Van In on 2016/12/30.
//  Copyright © 2016 Luke Van In. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    enum State {
        case stopped
        case recording
        case saving
    }
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    private var audioRecorder : AVAudioRecorder?
    
    private var state : State = .stopped {
        didSet {
            self.updateState()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateState()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            if let viewController = segue.destination as? PlaySoundsViewController {
                let recordedAudioURL = sender as? URL
                viewController.recordedAudioURL = recordedAudioURL
            }
        }
    }

    @IBAction func onRecordAction(_ sender: Any) {
        print("Record button tapped")
        state = .recording
    }
    
    @IBAction func onStopRecordingAction(_ sender: Any) {
        print("Stop recording button tapped")
        state = .saving
    }
    
    private func updateState() {
        switch state {
        case .stopped:
            recordingLabel.text = "Tap to record"
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
            
        case .recording:
            recordingLabel.text = "Recording in progress"
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = true
            beginRecording()
            
        case .saving:
            recordingLabel.text = "Saving recording"
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = false
            endRecording()
        }
    }
    
    private func beginRecording() {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = directoryURL?.appendingPathComponent("recordedVoice.wav")
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL!, settings: [:])
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            print("Recording to : \(fileURL)")
        }
        catch {
            print("Cannot initialize audio recorder : \(error)")
        }
    }
    
    private func endRecording() {
        audioRecorder?.stop()
        
        let session = AVAudioSession.sharedInstance()
        try! session.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Finished recording")
            performSegue(withIdentifier: "stopRecording", sender: recorder.url)
        }
        else {
            print("Recording failed")
        }
        state = .stopped
    }
}

