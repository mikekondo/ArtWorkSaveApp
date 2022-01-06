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
import MiniPlayer
import SPAlert

class MusicDataViewController: UIViewController,MiniPlayerDelegate,UINavigationControllerDelegate {
    
    var passedMusicModel = MusicModel()
    var artworkURL:URL!
    @IBOutlet weak var artWorkImageView: UIImageView!
    @IBOutlet weak var artWorkBackGroundImageView: UIImageView!
    
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var miniPlayer: MiniPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate=self
        
        //miniPlayerの設定
        miniPlayer.delegate = self
        
        
        miniPlayer.tintColor = UIColor.white
        miniPlayer.backgroundColor = UIColor.init(red: 192/255.0, green: 192/255.0, blue: 192/255.0, alpha: 1)
        
        miniPlayer.timeLabelVisible = true
        
        miniPlayer.timerColor = UIColor.white
        
        miniPlayer.activeTimerColor = UIColor.white
        
        miniPlayer.activeTrackColor = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)
        
        miniPlayer.durationTimeInSec = 0
        
        let urlPath = passedMusicModel.previewUrl_!
        
        let song = AVPlayerItem(asset: AVAsset(url: URL(string: urlPath)!), automaticallyLoadedAssetKeys: ["playable"])
        self.miniPlayer.soundTrack = song
        
        self.title = "\(passedMusicModel.collectionName_!)"
        self.navigationController?.navigationBar.titleTextAttributes = [
           // 文字の色
               .foregroundColor: UIColor.white
           ]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        artWorkBackGroundImageView.sd_setImage(with: URL(string: passedMusicModel.artworkUrl_!), completed: nil)
        artWorkImageView.sd_setImage(with: URL(string: passedMusicModel.artworkUrl_!), completed: nil)
        
        artistNameLabel.text = passedMusicModel.artistName_
        trackNameLabel.text = passedMusicModel.trackName_
        artworkURL = URL(string: passedMusicModel.artworkUrl_!)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        saveImage()
    }
    func saveImage(){
        let alertController = UIAlertController(title: "保存", message: "このジャケット写真を保存しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
            
            SPAlert.present(title: "ライブラリに追加しました", preset: .done)
            PHPhotoLibrary.shared().performChanges {
                //PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(string: self.passedMusicModel.artworkUrl_!)!)
                PHAssetChangeRequest.creationRequestForAsset(from: self.artWorkImageView.image!)
            } completionHandler: { (result, error) in
                if error != nil{
                    print(error.debugDescription)
                    //アラートだしたい！
                }
                else {
                    print("画像を保存しました")
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
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        miniPlayer.stop()
    }
    
    func didPlay(player: MiniPlayer) {
        print("Playing...")
    }
    
    func didStop(player: MiniPlayer) {
        print("Stopped")
    }
    
    func didPause(player: MiniPlayer) {
        print("Pause")
    }
    
}

