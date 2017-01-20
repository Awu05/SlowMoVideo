//
//  UploadVideoViewController.swift
//  SlowMoVideoApp
//
//  Created by Andy Wu on 1/10/17.
//  Copyright © 2017 Andy Wu. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer
import MobileCoreServices


//Upload file from Library to Firebase
class UploadVideoViewController: UICollectionViewController, UIGestureRecognizerDelegate {
    
    
    //var imagePicker = UIImagePickerController()
    
    var imagesDirectoryPath:String!
    var image = UIImage ()
    var mySharedData = DataAccessObject.sharedManager
    
    var path: String = ""
    
    var thumbnailImg = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        collectionView!.delegate = self
        collectionView!.dataSource = self

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
        
        // Longpress Cell to Delete
        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.minimumPressDuration = 0.5
        
        longPressGesture.addTarget(self, action: #selector(self.handleLongPress(_:)))
        collectionView?.addGestureRecognizer(longPressGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView?.reloadData()
        mySharedData.photos.removeAll()
        reloadImages()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state != UIGestureRecognizerState.ended {
            return
        }
        
        let p = gesture.location(in: self.collectionView)
        let indexPath = self.collectionView?.indexPathForItem(at: p)
        
        if let index = indexPath {
            //print(index.row)
            let tempPhotoURL = self.mySharedData.photos[index.row].imgURL
            deleteFile(fileURL: tempPhotoURL)
            self.mySharedData.photos.remove(at: index.row)
            collectionView?.deleteItems(at: [index])
            
        } else {
            print("Could not find index path")
        }
    }
    
    func deleteFile(fileURL: String) {
        
        do {
            let fileManager = FileManager.default
            
            // Check if file exists
            if fileManager.fileExists(atPath: fileURL) {
                // Delete file
                try fileManager.removeItem(atPath: fileURL)
                //print("Deleting Photo")
            } else {
                print("File does not exist")
            }
            
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photo = mySharedData.photos[(indexPath as IndexPath).row]
        
        if FileManager.default.fileExists(atPath: photo.imgURL) {
            let url = URL(string: photo.imgURL)
            
            if url?.pathExtension == "mp4" {
                //print("This an mp4 file!\n")
                //playVideo(path: photo.imgURL)
                self.path = photo.imgURL
                
                self.performSegue(withIdentifier: "PlayVideo", sender: self)
            }
            else {
                let img = UIImage(contentsOfFile: (url?.path)!)
                let newImage = UIImage(cgImage: (img?.cgImage)!, scale: 1.0, orientation: UIImageOrientation.right)
                self.image = newImage
                
                self.performSegue(withIdentifier: "showDetail", sender: self)
            }
            
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destination as! DetailViewController
            detailVC.img = self.image
        }
        
        if segue.identifier == "PlayVideo" {
            let videoVC = segue.destination as! VideoPlayerViewController
            videoVC.filePath = self.path
            //print("PATH: \(path)")
        }
        
    }
    
    func reloadImages() {
        // Get the SlowMo directory url
        let imagesDirectoryUrl =  NSURL(string: imagesDirectoryPath)
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: imagesDirectoryUrl as! URL, includingPropertiesForKeys: nil, options: [])
            //print(directoryContents)
            
            for file: URL in directoryContents {
                //let mp3Files = directoryContents.filter{ $0.pathExtension == "jpg" }
                
                //print("File Path: \(pic)\n")
                
                let picFileNames = file.deletingPathExtension().lastPathComponent
                
                //print("File Name: \(picFileNames)")
                
                let newPhoto = Photo(url: file.path, uuid: picFileNames)
                self.mySharedData.photos.append(newPhoto)
                
            }
            
            //print("Number of photos in slowmo directory is: \(mySharedData.photos.count)")
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
 }

// MARK: - Private
private extension UploadVideoViewController {
    func photoForIndexPath(indexPath: IndexPath) -> Photo {
        return mySharedData.photos[(indexPath as IndexPath).row]
    }
}

// MARK: - UICollectionViewDataSource
extension UploadVideoViewController {
    //1
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return mySharedData.photos.count
    }
    
    //3
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //1
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell",
                                                      for: indexPath) as! PhotoCollectionViewCell
        //2
        let photo = photoForIndexPath(indexPath: indexPath)
        cell.backgroundColor = UIColor.white
        //3
        
        //print("Photo URL: \(photo.imgURL)")
        //print("Photo UUID: \(photo.uuid)")
        
        
        if FileManager.default.fileExists(atPath: photo.imgURL) {
            let url = URL(string: photo.imgURL)
            //let data = NSData(contentsOf: url!)
            if url?.pathExtension == "mp4" {
                //print("This an mp4 file!\n")
                createThumbnail(vidPath: url!)
                cell.imageView.image = self.thumbnailImg
                cell.playButton.isHidden = false;
            }
            else {
                let img = UIImage(contentsOfFile: (url?.path)!)
                let newImage = UIImage(cgImage: (img?.cgImage)!, scale: 1.0, orientation: UIImageOrientation.right)
                cell.imageView.image = newImage
                cell.playButton.isHidden = true;
            }
            
        }
        
        return cell
    }
    
    func createThumbnail(vidPath: URL) {
        
        let url = URL (fileURLWithPath: vidPath.absoluteString)
        //var err : NSError? = nil
        let asset =  AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: kCMTimeZero, actualTime: nil)
            self.thumbnailImg = UIImage(cgImage: imageRef)
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
        }
    }
    
    func playVideo(path: String) {
        /*
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        player.currentItem?.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed
        
        
        playerController.player = player
        present(playerController, animated: true) {
            
            player.play()
            player.rate = 0.1
        }
 
        let vpVC = VideoPlayerViewController()
        vpVC.filePath = path
        self.navigationController?.pushViewController(vpVC, animated: true)
        */
        
        var mainView: UIStoryboard!
        mainView = UIStoryboard(name: "Main", bundle: nil)
        let viewcontroller : VideoPlayerViewController = mainView.instantiateViewController(withIdentifier: "videoPlayer") as! VideoPlayerViewController
        
        viewcontroller.filePath = path
        
        self.present(viewcontroller, animated: true, completion: nil)
    }
}

