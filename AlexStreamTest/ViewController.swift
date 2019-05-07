//
//  ViewController.swift
//  AlexStreamTest
//
//  Created by Alexey Kuznetsov on 07/05/2019.
//  Copyright © 2019 admin. All rights reserved.


import UIKit
import LFLiveKit
import AVKit

class ViewController: UIViewController, LFLiveSessionDelegate {
	
	@IBOutlet weak var viewPreview: UIView!
	@IBOutlet weak var viewCam: UIView!
	var playerViewController: AVPlayerViewController?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		session.delegate = self
		session.preView = self.viewCam
		
		self.requestAccessForVideo()
		self.requestAccessForAudio()
		self.view.backgroundColor = UIColor.clear
		
		viewCam.backgroundColor = .clear
		viewCam.addSubview(beautyButton)
		viewCam.addSubview(cameraButton)
		viewCam.addSubview(startLiveButton)
		viewCam.addSubview(showLiveButton)
		
		cameraButton.addTarget(self, action: #selector(didTappedCameraButton(_:)), for:.touchUpInside)
		beautyButton.addTarget(self, action: #selector(didTappedBeautyButton(_:)), for: .touchUpInside)
		startLiveButton.addTarget(self, action: #selector(didTappedStartLiveButton(_:)), for: .touchUpInside)
		showLiveButton.addTarget(self, action: #selector(didTappedShowLivebutton(_:)), for: .touchUpInside)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//MARK: AccessAuth
	func requestAccessForVideo() -> Void {
		let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video);
		switch status  {
		case AVAuthorizationStatus.notDetermined:
			AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
				if(granted){
					DispatchQueue.main.async {
						self.session.running = true
					}
				}
			})
			break;
		case AVAuthorizationStatus.authorized:
			session.running = true;
			break;
		case AVAuthorizationStatus.denied: break
		case AVAuthorizationStatus.restricted:break;
		default:
			break;
		}
	}
	
	func requestAccessForAudio() -> Void {
		let status = AVCaptureDevice.authorizationStatus(for:AVMediaType.audio)
		switch status  {
		case AVAuthorizationStatus.notDetermined:
			AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (granted) in
				
			})
			break;
		case AVAuthorizationStatus.authorized:
			break;
		case AVAuthorizationStatus.denied: break
		case AVAuthorizationStatus.restricted:break;
		default:
			break;
		}
	}
	
	//MARK: - Callbacks
	
	func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
		print("debugInfo: \(debugInfo?.currentBandwidth)")
	}
	
	func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
		print("errorCode: \(errorCode.rawValue)")
	}
	
	func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
		print("liveStateDidChange: \(state.rawValue)")
		switch state {
		case LFLiveState.ready:
			startLiveButton.setTitle("Ready to stream", for: UIControl.State())
			break;
		case LFLiveState.pending:
			startLiveButton.setTitle("Pending...", for: UIControl.State())
			break;
		case LFLiveState.start:
			startLiveButton.setTitle("Started", for: UIControl.State())
			break;
		case LFLiveState.error:
			startLiveButton.setTitle("Error..", for: UIControl.State())
			break;
		case LFLiveState.stop:
			startLiveButton.setTitle("Stopped", for: UIControl.State())
			break;
		default:
			break;
		}
	}
	
	//MARK: - Events
	@objc func didTappedShowLivebutton(_ button: UIButton) -> Void {
		if playerViewController == nil {
			addPlayer()
		} else {
			removePlayer()
		}
	}
	
	@objc func didTappedStartLiveButton(_ button: UIButton) -> Void {
		startLiveButton.isSelected = !startLiveButton.isSelected;
		if (startLiveButton.isSelected) {
			let stream = LFLiveStreamInfo()
			stream.url = "rtmp://104.248.90.197/app/mystream"
			session.startLive(stream)
		} else {
			session.stopLive()
		}
	}
	
	@objc func didTappedBeautyButton(_ button: UIButton) -> Void {
		session.beautyFace = !session.beautyFace;
		beautyButton.isSelected = !session.beautyFace
	}
	
	@objc func didTappedCameraButton(_ button: UIButton) -> Void {
		let devicePositon = session.captureDevicePosition;
		session.captureDevicePosition = (devicePositon == AVCaptureDevice.Position.back) ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back;
	}
	
	func didTappedCloseButton(_ button: UIButton) -> Void  {
		
	}
	
	//MARK: - Getters and Setters
	func addPlayer() {
		guard let url = URL(string: "http://104.248.90.197/live/mystream/index.m3u8") else { return }
		
		let player = AVPlayer(url: url)
		playerViewController = AVPlayerViewController()
		playerViewController!.player = player
		player.rate = 1 //auto play
		playerViewController!.view.frame = viewPreview.frame
		
		addChild(playerViewController!)
		view.addSubview(playerViewController!.view)
		playerViewController!.didMove(toParent: self)
	}
	
	func removePlayer() {
		guard let playerVC = playerViewController else { return }
		playerVC.player?.pause()
		playerVC.willMove(toParent: nil)
		playerVC.view.removeFromSuperview()
		playerVC.removeFromParent()
		playerViewController = nil
	}
	
	var session: LFLiveSession = {
		let audioConfiguration = LFLiveAudioConfiguration.defaultConfiguration(for: LFLiveAudioQuality.high)
		let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality.low3)
		let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
		return session!
	}()
	
	var cameraButton: UIButton = {
		let cameraButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 54 * 2, y: 20, width: 44, height: 44))
		cameraButton.setImage(UIImage(named: "camra_preview"), for: UIControl.State())
		return cameraButton
	}()
	
	var beautyButton: UIButton = {
		let beautyButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 54 * 3, y: 20, width: 44, height: 44))
		beautyButton.setImage(UIImage(named: "camra_beauty"), for: UIControl.State.selected)
		beautyButton.setImage(UIImage(named: "camra_beauty_close"), for: UIControl.State())
		return beautyButton
	}()
	
	var showLiveButton: UIButton = {
		let beautyButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 54, y: 20, width: 44, height: 44))
		beautyButton.setImage(UIImage(named: "show_live"), for: UIControl.State.selected)
		beautyButton.setImage(UIImage(named: "show_live"), for: UIControl.State())
		return beautyButton
	}()
	
	var startLiveButton: UIButton = {
		let startLiveButton = UIButton(frame: CGRect(x: 20, y: 20, width: 200, height: 40))
		startLiveButton.layer.cornerRadius = 22
		startLiveButton.setTitleColor(UIColor.black, for: UIControl.State())
		startLiveButton.setTitle("Start stream", for: UIControl.State())
		startLiveButton.titleLabel!.font = UIFont.systemFont(ofSize: 14)
		startLiveButton.backgroundColor = UIColor(red: 50/255, green: 32/255, blue: 50/255, alpha: 0.5)
		return startLiveButton
	}()
}

