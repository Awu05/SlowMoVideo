//
//  SecondViewController.swift
//  SlowMoVideoApp
//
//  Created by Andy Wu on 1/10/17.
//  Copyright © 2017 Andy Wu. All rights reserved.
//

import UIKit
import AVFoundation


//Capture Video/Picture
@available(iOS 10.0, *)
class SecondViewController: UIViewController, AVCaptureFileOutputRecordingDelegate  {
    
    @IBOutlet weak var videoProperty: UIButton!
    
    @IBOutlet weak var recordProperty: UIButton!
    
    @IBOutlet weak var photoProperty: UIButton!
    
    @IBOutlet weak var previewView: UIView!
    
    @IBOutlet weak var recordLength: UITextField!
    
    var imagesDirectoryPath:String!
    
    var isRecording = false
    
    var recordCount = 0
    
    var isPhoto = false
    
    var timeElapsed = 0
    
    var timer = Timer()
    
    var stopVideo: AVCaptureFileOutput?
    
    let videoFileOutput = AVCaptureMovieFileOutput()
    
    var captureDevice : AVCaptureDevice? // check capture device availability
    let captureSession = AVCaptureSession() // to create capture session
    var previewLayer : AVCaptureVideoPreviewLayer? // to add video inside container
    
    //var captureDevice : AVCaptureDevice?
    var captureAudio :AVCaptureDevice?
    
    @IBAction func photoBtn(_ sender: Any) {
        takePhoto()
        self.photoProperty.isEnabled = false
        self.videoProperty.isEnabled = true
        self.videoProperty.backgroundColor = .white
        self.photoProperty.backgroundColor = .red
    }
    
    
    @IBAction func videoBtn(_ sender: Any) {
        self.recordLength.isHidden = false
        
        self.photoProperty.isEnabled = true
        self.videoProperty.isEnabled = false
        self.videoProperty.backgroundColor = .red
        self.photoProperty.backgroundColor = .white
        
        self.recordLength.text = String(timeElapsed)
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        
        var captureDeviceVideoFound: Bool = false
        var captureDeviceAudioFound:Bool = false
        
        // Loop through all the capture devices on this phone
        for device in devices! {
            // Make sure this particular device supports video
            if ((device as AnyObject).hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the front camera
                if((device as AnyObject).position == AVCaptureDevicePosition.back) {
                    //print((device as AnyObject).activeFormat)
                    captureDevice = device as? AVCaptureDevice //initialize video
                    if captureDevice != nil {
                        //print("Capture device found")
                        captureDeviceVideoFound = true;
                    }
                }
            }
            if((device as AnyObject).hasMediaType(AVMediaTypeAudio)){
                //print("Capture device audio init")
                captureAudio = device as? AVCaptureDevice //initialize audio
                captureDeviceAudioFound = true
            }
        }
        if(captureDeviceAudioFound && captureDeviceVideoFound){
            if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                for input in inputs {
                    captureSession.removeInput(input)
                }
            }
            beginSession() 
        }
        
        isRecording = true
        
    
    }
    
    func beginSession() {
        configureDevice()
        let err : NSError? = nil
        do{
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            try captureSession.addInput(AVCaptureDeviceInput(device: captureAudio))
        }catch{
            print("error")
        }
        if err != nil {
            print("error: \(err?.localizedDescription)")
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewView.layer.addSublayer(previewLayer!)
        self.previewView.bringSubview(toFront: photoProperty)
        self.previewView.bringSubview(toFront: videoProperty)
        self.previewView.bringSubview(toFront: recordProperty)
        self.previewView.bringSubview(toFront: recordLength)
        
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
    }
    
    func configureDevice() {
        /*
        if let device = captureDevice {
            do{
                try device.lockForConfiguration()
                //print(device.activeFormat)
                let minFrameRate: Int32 = Int32(device.activeVideoMinFrameDuration.timescale)
                let maxFrameRate: Int32 = Int32(device.activeVideoMaxFrameDuration.timescale)
                //print("Min Frame rate: \(minFrameRate)\nMax Frame rate: \(maxFrameRate)")
                
                device.activeVideoMinFrameDuration = CMTimeMake(1, minFrameRate)
                device.activeVideoMaxFrameDuration = CMTimeMake(1, maxFrameRate)
                device.unlockForConfiguration()
                
            }catch{
                print("error")
            }
        }
        */
        
        if let device = captureDevice {
            
            // 1
            for vFormat in captureDevice!.formats {
                
                // 2
                var ranges = (vFormat as AnyObject).videoSupportedFrameRateRanges as! [AVFrameRateRange]
                let frameRates = ranges[0]
                
                // 3
                if frameRates.maxFrameRate == 60 {
                    
                    // 4
                    do {
                        try device.lockForConfiguration()
                        device.activeFormat = vFormat as! AVCaptureDeviceFormat
                        device.activeVideoMinFrameDuration = frameRates.minFrameDuration
                        device.activeVideoMaxFrameDuration = frameRates.maxFrameDuration
                        print("Min Frame rate: \(device.activeVideoMinFrameDuration)\nMax Frame rate: \(device.activeVideoMaxFrameDuration)")
                        device.unlockForConfiguration()
                    }
                    catch {
                        print("error")
                    }
                    
                }
            }
        }
        
        
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("capture output: started recording to \(fileURL)")
        self.stopVideo = captureOutput
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print("capture output : finish recording to \(outputFileURL)")
        
        
        print("capture did finish")
//        print(captureOutput);
//        print(outputFileURL);
        
    }
    
    
    @IBAction func didTakePhoto(_ sender: Any) {
        
        if(recordCount != 0 && isRecording == true) {
            recordCount = 0
            
            self.timer.invalidate()
            self.recordLength.text = "0"
            
            self.stopVideo?.stopRecording()
            print("Stopped Recording")
            
            self.savedFile()
            
        }
        else if(isRecording == true && recordCount == 0) {
            self.recordCount += 1
            self.isPhoto = false
            
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(addTime), userInfo: nil, repeats: true)
            
            let videoName = UUID().uuidString
            let fileURL = NSURL(fileURLWithPath: self.imagesDirectoryPath.appending("/\(videoName).mp4"))
            
            let recordingDelegate:AVCaptureFileOutputRecordingDelegate? = self
            
            let videoFileOutput = AVCaptureMovieFileOutput()
            self.captureSession.addOutput(videoFileOutput)
            
            videoFileOutput.startRecording(toOutputFileURL: fileURL as URL!, recordingDelegate: recordingDelegate)
            
            
            print("Started Recording")
            
        }
        else if(isPhoto == true) {
            self.isRecording = false
            
            if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
                // ...
                stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) -> Void in
                    // ...
                    if sampleBuffer != nil {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                        let dataProvider = CGDataProvider(data: imageData as! CFData)
                        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.relativeColorimetric)
                        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                        
                        // create a name for your image
                        let imageName = UUID().uuidString
                        
                        let fileURL = NSURL( string: self.imagesDirectoryPath.appending("/\(imageName).jpg"))!
                        
                        //print("File URL: \(fileURL)")
                        
                        if !FileManager.default.fileExists(atPath: (fileURL.path)!) {
                            do {
                                try UIImagePNGRepresentation(image)!.write(to: fileURL as URL)
                                print("Image Added Successfully")
                                self.savedFile()
                            } catch {
                                print(error)
                                self.saveError()
                            }
                        } else {
                            print("Image Not Added")
                            self.saveError()
                        }
                        
                        
                    }
                })
            }
            
            
        }
        
        
        
    }
    
    func addTime(){
        timeElapsed += 1
        self.recordLength.text = String(timeElapsed)
    }
    
    var session = AVCaptureSession()
    var stillImageOutput = AVCaptureStillImageOutput()
    var videoPreviewLayer = AVCaptureVideoPreviewLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.recordLength.isHidden = true
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        imagesDirectoryPath = documentDirectorPath.appending("/SlowMoFolder")
        var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: imagesDirectoryPath, isDirectory: &objcBool)
        // If the folder with the given path doesn't exist already, create it
        if isExist == false{
            do{
                try FileManager.default.createDirectory(atPath: imagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
                print("Creating new folder")
                
            }catch{
                print("Something went wrong while creating a new folder")
            }
        }
        
    }
    
    func takePhoto() {
        self.isPhoto = true
        self.isRecording = false
        
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        if error == nil && session.canAddInput(input) {
            session.addInput(input)
            // ...
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect
            videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            videoPreviewLayer.frame = self.view.bounds;
            self.previewView.layer.addSublayer(videoPreviewLayer)
            self.previewView.bringSubview(toFront: photoProperty)
            self.previewView.bringSubview(toFront: videoProperty)
            self.previewView.bringSubview(toFront: recordProperty)
            
            session.startRunning()
            
            self.previewView.setNeedsDisplay()
            
        }
        
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        if session.canAddOutput(stillImageOutput) {
            session.addOutput(stillImageOutput)
            
            // ...
            // Configure the Live Preview here...
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoPreviewLayer.frame = self.view.bounds
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func savedFile() {
        let ac = UIAlertController(title: "File Saved!", message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func saveError () {
        let ac = UIAlertController(title: "Error Saving File", message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
}


