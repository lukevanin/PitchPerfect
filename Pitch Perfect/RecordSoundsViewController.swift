//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Luke Van In on 2016/12/30.
//  Copyright © 2016 Luke Van In. All rights reserved.
//
//  Allow the user to record audio with the microphone to a WAV file. The file can be played back at a later time.
//
//  The recorder transitions through three states:
//      1. Stopped state: The recorder is idle and no audio is being recorded. The record button is enabled. Tapping the
//         record button transitions to the Recording state.
//      2. Recording state: Audio is being recorded. While in this state, the record button is disabled, and the stop 
//         button is enabled. Tapping on the stop button transitions to the Saving state. If for some reason the 
//         recorder fails to initialize, an error is displayed and the view controller transitions back to the stopped 
//         state.
//      3. Saving state: Audio is saved to a file. During this state the record button and stop button are disabled, and
//         an activity indicator appears. When the recording is saved, the view controller returns to the stopped state.
//         If the recording is saved successfully, then the app transitions to the playback view controller. If the 
//         recording cannot be saved, then an error is displayed and the app remains on the current view controller.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController {
    
    //
    // Defines the possible states for the recording screen.
    //
    enum State {
        // Not recording. Waiting for record button to be tapped.
        case stopped
        
        // Recording audio.
        case recording
        
        // Saving current recording.
        case saving
    }
    
    // Set a default "stopped" state (not recording), so that a new recording can be made.
    fileprivate var state : State = .stopped {
        didSet {
            // Update the view controller's state when the internal state is changed.
            self.updateState()
        }
    }
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var audioRecorder : AVAudioRecorder?
    
    
    // MARK: View controller life cycle.

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure that the view appearance matches the internal state variable.
        updateState()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Handle segue to PlaySoundsViewController after stop button is tapped. The segue is handled in code, rather 
        // than using a direct storyboard segue, so that we are able to control the segue to ensure that the playback
        // view controller only appears after the audio is saved, to avoid transitioning to an invalid state.
        if segue.identifier == "stopRecording" {
            if let viewController = segue.destination as? PlaySoundsViewController {
                let recordedAudioURL = sender as? URL
                viewController.recordedAudioURL = recordedAudioURL
            }
        }
    }
    
    
    // MARK: User interface

    //
    //  Record button tapped. Start recording audio.
    //
    @IBAction func onRecordAction(_ sender: Any) {
        print("Record button tapped")
        state = .recording
    }
    
    //
    //  Stop button tapped. Save current recording.
    //
    @IBAction func onStopRecordingAction(_ sender: Any) {
        print("Stop recording button tapped")
        state = .saving
    }
    
    //
    //  Update the view controller's display state based on the internal model state.
    //
    private func updateState() {
        switch state {
        case .stopped:
            setUIState(
                isRecording: false,
                isSaving: false,
                recordingText: "Tap to record"
            )
            
        case .recording:
            setUIState(
                isRecording: true,
                isSaving: false,
                recordingText: "Recording in progress"
            )
            beginRecording()
            
        case .saving:
            setUIState(
                isRecording: false,
                isSaving: true,
                recordingText: "Saving recording"
            )
            endRecording()
        }
    }
    
    //
    //  Update the view according to the view state.
    //  Set the prompt text, and visibility for the stop and record buttons, and activity indicator.
    //
    private func setUIState(isRecording: Bool, isSaving: Bool, recordingText: String) {
        recordingLabel.text = recordingText
        recordButton.isEnabled = !isRecording
        stopRecordingButton.isEnabled = isRecording
        stopRecordingButton.isHidden = isSaving
        
        if isSaving {
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.stopAnimating()
        }
    }
    
    //
    //  Show an error alert.
    //
    fileprivate func showAlert(error message: String) {
        let controller = UIAlertController(title: "Oops, something went wrong", message: message, preferredStyle: .alert)
        controller.addAction(
            UIAlertAction(
                title: "Dismiss",
                style: .cancel,
                handler: nil
            )
        )
        present(controller, animated: true, completion: nil)
    }

    
    // MARK: Recording
    
    //
    //  Begin recording.
    //  Instantiate an AVAudioRecorder configured to record to a predefined file location. If the recorder cannot be 
    //  initialized, then an error is displayed.
    //
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
            showAlert(error: "Cannot initialize audio recorder. Check that you have allowed microphone access for this app.")
            // Transition back to the stopped state to create a new recording.
            state = .stopped
        }
    }
    
    //
    //  Stop the recording.
    //
    private func endRecording() {
        audioRecorder?.stop()
        let session = AVAudioSession.sharedInstance()
        try! session.setActive(false)
    }
}

//
//  AVAudioRecorder delegate methods for the RecordSoundsViewController.
//
extension RecordSoundsViewController: AVAudioRecorderDelegate {

    //
    //  Called when the AVRecorder has finished saving the recording.
    //  If the recording was saved successfully, then transition to the playback view controller, otherwise show an 
    //  error.
    //
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Finished recording")
            // The segue is initiated programatically (instead of directly through the storyboard) so that we can 
            // transition to the playback view controller only after the audio is saved. 
            // If the segue were set to execute immediately when the stop button is tapped, then when the playback 
            // controller appears it could be possible that the recording has not finished saving, resulting in 
            // unexpected behavior.
            performSegue(withIdentifier: "stopRecording", sender: recorder.url)
        }
        else {
            print("Recording failed")
            // Show an alert if recording failed.
            showAlert(error: "There was a problem saving the recording.")
        }

        // Transition to the stopped state.
        state = .stopped
    }
}

