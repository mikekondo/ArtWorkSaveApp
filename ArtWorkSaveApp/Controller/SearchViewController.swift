//
//  ViewController.swift
//  ArtWorkSaveApp
//
//  Created by 近藤米功 on 2022/01/01.
//

import UIKit
import SDWebImage
import Pastel

class SearchViewController: UIViewController,UISearchBarDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate,iTunesAPICatchMusicDataDelegate {
    
    @IBOutlet weak var pastelView: PastelView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    //楽曲情報の配列
    var musicModelArray = [MusicModel]()
    
    //collectionView関連の設定
    //collection間の間隔
    let sectionInsets = UIEdgeInsets(top: 4.0, left: 0, bottom: 4.0, right: 0)
    //列の数
    let itemsPerRow = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        //フォアグラウンド時の処理
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SearchViewController.viewWillEnterForeground(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
    }
    
    //アプリがフォアグラウンド時(ホーム画面からアプリをタップした時でもBackgroundColorをパステルカラーにする
    @objc func viewWillEnterForeground(_ notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            setBackgroundColor()
            print("フォアグラウンド")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBackgroundColor()
        searchBarSetting()
        //画面遷移から戻ってきた時にViewのトップに移動する
        collectionView.setContentOffset(CGPoint.zero, animated: true)
        
        //ナビゲーションバーを隠す
        self.navigationController?.isNavigationBarHidden = true
        
        
        if UserDefaults.standard.object(forKey: "searchWord") != nil{
            //前回検索してたワードの取り出し
            let searchWord = UserDefaults.standard.object(forKey: "searchWord") as! String
            //キーボードを閉じる
            self.view.endEditing(true)

            //前回検索してたワードで楽曲の検索
            searchMusic(searchWord: searchWord)
        }
    }
    
    //タッチすると呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //キーボードを閉じる
        self.view.endEditing(true)
    }
    
    //searchボタン(TextFieldでいうEnter)を押すと呼ばれる
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる
        self.view.endEditing(true)
        //viewをトップに持ってくる
        collectionView.setContentOffset(CGPoint.zero, animated: true)
        //楽曲の検索
        searchMusic(searchWord: searchBar.searchTextField.text!)
        //search.textの保存
        UserDefaults.standard.set(searchBar.searchTextField.text,forKey: "searchWord")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let musicCell = collectionView.dequeueReusableCell(withReuseIdentifier: "musicCell", for: indexPath)
        
        let collectionNameLabel = musicCell.contentView.viewWithTag(1) as! UILabel
        let trackNameLabel = musicCell.contentView.viewWithTag(2) as! UILabel
        let artworkImageView = musicCell.contentView.viewWithTag(3) as! UIImageView

        collectionNameLabel.text = musicModelArray[indexPath.row].collectionName_
        trackNameLabel.text = musicModelArray[indexPath.row].trackName_
        artworkImageView.sd_setImage(with: URL(string: musicModelArray[indexPath.row].artworkUrl_!), completed: nil)
        return musicCell
    }
    
    //collectionの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return musicModelArray.count
    }
    
    //セル(item)の大きさを決めている
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //スペースの幅の総和 = 左幅 * (アイテムの数+１)
        let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
        
        //マス全体の幅 = 全体の幅(View) - paddingSpace
        let availableWidth = view.frame.width - paddingSpace
        
        //セルの幅
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        return CGSize(width: widthPerItem, height: widthPerItem + 25)
    }
    
    //collectionをタップした時に呼ばれる
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let musicDataVC = self.storyboard?.instantiateViewController(withIdentifier: "MusicDataID") as! MusicDataViewController
        musicDataVC.passedMusicModel = musicModelArray[indexPath.row]
        self.navigationController?.pushViewController(musicDataVC, animated: true)
    }
    //iTunesAPI実行後のデリゲートメソッド
    func iTunesAPICatchMusicData(passedMusicDataArray: [MusicModel]) {
        //データを空にする
        musicModelArray = []
        musicModelArray = passedMusicDataArray
        collectionView.reloadData()
    }
    
    private func setBackgroundColor(){
        // Custom Direction
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        // 色変化の間隔[s]
        pastelView.animationDuration = 2.0
        
        //黒→グレーのアニメーション
        pastelView.setColors([UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0),//black
                              UIColor(red: 47/255, green: 79/255, blue: 79/255, alpha: 1.0),//darkslategrey
                              UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1.0)])//grey
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)
    }
    private func searchBarSetting(){
        //searchBarのバックグラウンドを透過させる
        searchBar.backgroundImage = UIImage()

        //searchBarのバックグラウンドカラーを透過させる
        searchBar.backgroundColor = UIColor.clear

        //searchBarの中のTextFieldの背景色を白にする
        searchBar.searchTextField.backgroundColor = UIColor.white
    }
    private func setUp(){
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    private func searchMusic(searchWord: String){
        let musicAnalytics = MusicAnalytics()
        musicAnalytics.delegate = self
        let urlString = "https://itunes.apple.com/search?term=\(searchWord)&country=jp"
        musicAnalytics.iTunesAPIExe(itaUrl: urlString)
    }
}
