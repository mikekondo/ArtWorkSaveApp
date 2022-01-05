//
//  MusicDataViewController.swift
//  ArtWorkSaveApp
//
//  Created by 近藤米功 on 2022/01/01.
//

import UIKit
import SDWebImage
import Photos
import AVFoundation
import PKHUD

class MusicDataViewController: UIViewController {
    var passedMusicModel = MusicModel()
    var artworkURL:URL!
    @IBOutlet weak var artWorkImageView: UIImageView!
    @IBOutlet weak var artWorkBackGroundImageView: UIImageView!
    
    @IBOutlet weak var artistNameLabel: UILabel!
    
    @IBOutlet weak var collectionNameLabel: UILabel!
    
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var playAndStop: UIButton!
    
    var player:AVAudioPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        artWorkBackGroundImageView.sd_setImage(with: URL(string: passedMusicModel.artworkUrl_!), completed: nil)
        artWorkImageView.sd_setImage(with: URL(string: passedMusicModel.artworkUrl_!), completed: nil)
        
        artistNameLabel.text = passedMusicModel.artistName_
        collectionNameLabel.text = passedMusicModel.collectionName_
        trackNameLabel.text = passedMusicModel.trackName_
        artworkURL = URL(string: passedMusicModel.artworkUrl_!)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        saveImage()
    }
    func saveImage(){
        let alertController = UIAlertController(title: "保存", message: "この画像を保存しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
            PHPhotoLibrary.shared().performChanges {
                //PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(string: self.passedMusicModel.artworkUrl_!)!)
                PHAssetChangeRequest.creationRequestForAsset(from: self.artWorkImageView.image!)
            } completionHandler: { (result, error) in
                if error != nil{
                    print(error.debugDescription)
                    //アラートだしたい！
                }
                if result{
                    print("動画を保存しました")
                    //アラートだしたい！
                    
                }
                
            }
        }
        let cancelAction = UIAlertAction(title: "CANCEL", style: .default) { (cancel) in
            alertController.dismiss(animated: true, completion: nil)
        }
        //OKとCANCELを表示追加し、アラートを表示
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func playAndStopButton(_ sender: UIButton) {
        if(sender.titleLabel!.text == "試聴"){
            print("tap再生ボタン")
            sender.setTitle("停止", for: .normal)
            let previewUrl = URL(string: passedMusicModel.previewUrl_!)
            downloadMusicURL(musicPlayUrl: previewUrl!)
        }
        else if(sender.titleLabel!.text == "停止"){
            print("tap停止ボタン")
            if player?.isPlaying == true{
                player!.stop()
            }
            sender.setTitle("試聴", for: .normal)
            
        }
    }
    func downloadMusicURL(musicPlayUrl:URL){
        print("downloadMusic")
        var downloadTask:URLSessionDownloadTask
        HUD.show(.progress)
        print("インディケータ発動")
        downloadTask = URLSession.shared.downloadTask(with: musicPlayUrl, completionHandler: { (musicPlayUrl, response, error) in
            print("インディケータ閉じる")
            HUD.hide()
            print("downloadMusic2")
            self.play(url:musicPlayUrl!)
        })
        downloadTask.resume()
    }
    func play(url:URL){
        print("play")
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.volume = 1.0
            player?.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
}

