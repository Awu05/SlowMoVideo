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
class UploadVideoViewController: UICollectionViewController {
    
    
    //var imagePicker = UIImagePickerController()
    
    var imagesDirectoryPath:String!
    var image = UIImage ()
    var mySharedData = DataAccessObject.sharedManager
    
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photo = mySharedData.photos[(indexPath as IndexPath).row]
        
        if FileManager.default.fileExists(atPath: photo.imgURL) {
            let url = URL(string: photo.imgURL)
            //let data = NSData(contentsOf: url!)
            let img = UIImage(contentsOfFile: (url?.path)!)
            let newImage = UIImage(cgImage: (img?.cgImage)!, scale: 1.0, orientation: UIImageOrientation.right)
            self.image = newImage
        }
        
        print("Image tapped!")
        
        self.performSegue(withIdentifier: "showDetail", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destination as! DetailViewController
            detailVC.img = self.image
        }
    }
    
    func reloadImages() {
        // Get the document directory url
        let imagesDirectoryUrl =  NSURL(string: imagesDirectoryPath)
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: imagesDirectoryUrl as! URL, includingPropertiesForKeys: nil, options: [])
            print(directoryContents)
            
            for pic: URL in directoryContents {
                //let mp3Files = directoryContents.filter{ $0.pathExtension == "jpg" }
                
                print("File Path: \(pic)\n")
                
                let mp3FileNames = pic.deletingPathExtension().lastPathComponent
                
                print("File Name: \(mp3FileNames)")
                
                let newPhoto = Photo(url: pic.path, uuid: mp3FileNames)
                
                self.mySharedData.photos.append(newPhoto)
            }
            
            print("Number of photos in slowmo directory is: \(mySharedData.photos.count)")
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    /*
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        // Save image to Document directory
        var imagePath = NSDate().description
        imagePath = imagePath.replacingOccurrences(of: " ", with: "")
        imagePath = imagesDirectoryPath.appending("/\(imagePath).png")
        let data = UIImagePNGRepresentation(image)
        let success = FileManager.default.createFile(atPath: imagePath, contents: data, attributes: nil)
        dismiss(animated: true) { () -> Void in
            print("It worked! You have chosen the image: \(imagePath)")
            self.refreshTable()
        }
    }
    
    func refreshTable(){
        do{
            images.removeAll()
            titles = try FileManager.default.contentsOfDirectory(atPath: imagesDirectoryPath)
            for image in titles{
                let data = FileManager.default.contents(atPath: imagesDirectoryPath.appending("/\(image)"))
                let image = UIImage(data: data!)
                images.append(image!)
            }
            self.collectionView.reloadData()
        }catch{
            print("Error")
        }
    }
    
    */
    /*
    func startMediaBrowserFromViewController(viewController: UIViewController, usingDelegate delegate: UINavigationControllerDelegate & UIImagePickerControllerDelegate) -> Bool {
        // 1
        
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(".jpeg")
            let image    = UIImage(contentsOfFile: imageURL.path)
            // Do whatever you want with the image
            
            
            
        }
        
        
        return true
    }
 
    
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // 1
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        // 2
        dismiss(animated: true) {
            // 3
            if mediaType == kUTTypeMovie {
                let url = NSURL.fileURL(withPath: mediaType as String)
                let player = AVPlayer(url: url)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                
                //playerViewController.view.frame = CGRectMake(20, 50, 300, 300)
                self.view.addSubview(playerViewController.view)
                self.addChildViewController(playerViewController)
                
                player.play()
            }
        }
    }
    */
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
            let img = UIImage(contentsOfFile: (url?.path)!)
            let newImage = UIImage(cgImage: (img?.cgImage)!, scale: 1.0, orientation: UIImageOrientation.right)
            cell.imageView.image = newImage
        }
        
        return cell
    }
}

