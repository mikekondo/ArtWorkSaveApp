//
//  ViewController.swift
//  ArtWorkSaveApp
//
//  Created by 近藤米功 on 2022/01/01.
//

import UIKit
import SDWebImage
import Pastel
class SearchViewController: UIViewController,UISearchBarDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate,itaCatchMusicDataDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    //楽曲情報の配列
    var musicModelArray = [MusicModel]()
    
    //collectionView関連の設定
    //collection間の間隔
    let sectionInsets = UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
    //列の数
    let itemsPerRow = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackgroundColor()
        //画面遷移から戻ってきた時にViewのトップに移動する
        collectionView.setContentOffset(CGPoint.zero, animated: true)
        self.navigationController?.isNavigationBarHidden = true
        
        //searchBarのバックグラウンドを透過させる
        searchBar.backgroundImage = UIImage()

        //searchBarのバックグラウンドカラーを透過させる
        searchBar.backgroundColor = UIColor.clear

        //searchBarの中のTextFieldの背景色を白にする
        searchBar.searchTextField.backgroundColor = UIColor.white
        
        //Todo:if文でUserDefalutsの値があればsearchBar.searchTextFieldにその値をいれてmusicAnaticsを回す
        if UserDefaults.standard.object(forKey: "searchWord") != nil{
            let searchWord = UserDefaults.standard.object(forKey: "searchWord") as! String
            //キーボードを閉じる
            self.view.endEditing(true)

            //iTunesAPIの実行
            let musicAnalytics = MusicAnalytics()
            musicAnalytics.delegate = self
            let urlString = "https://itunes.apple.com/search?term=\(searchWord)&country=jp"
            //こっちだとなぜか検索結果が思わしくない
            //let urlString = "https://itunes.apple.com/search?term=\(String(describing:searchBar.searchTextField.text!))&entity=song&contry=jp"
            musicAnalytics.itaExe(itaUrl: urlString)
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
        //iTunesAPIの実行
        let musicAnalytics = MusicAnalytics()
        musicAnalytics.delegate = self
        let urlString = "https://itunes.apple.com/search?term=\(searchBar.searchTextField.text!)&country=jp"
        //こっちだとなぜか検索結果が思わしくない
        //let urlString = "https://itunes.apple.com/search?term=\(String(describing:searchBar.searchTextField.text!))&entity=song&contry=jp"
        musicAnalytics.itaExe(itaUrl: urlString)
        
        //Todo:searchBar.searchTextField.text!をアプリ内保存する
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
    func itaCatchMusicData(passedMusicDataArray: [MusicModel]) {
        //データを空にする
        musicModelArray = []
        musicModelArray = passedMusicDataArray
        collectionView.reloadData()
    }
    func setBackgroundColor(){
        let pastelView = PastelView(frame: view.bounds)
        
        // Custom Direction
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        
        // Custom Duration
        pastelView.animationDuration = 2.0
        
        // Custom Color
//        pastelView.setColors([UIColor(red: 100/255, green: 39/255, blue: 100/255, alpha: 1.0),
//                              UIColor(red: 80/255, green: 31/255, blue: 50/255, alpha: 1.0),
//                              UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
//                              UIColor(red: 58/255, green: 200/255, blue: 217/255, alpha: 1.0),
//                              UIColor(red: 58/255, green: 80/255, blue: 25/255, alpha: 1.0)])
        pastelView.setColors([UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),
                              UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
                              UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
                              UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0)])
        pastelView.startAnimation()
        print(pastelView)
        view.insertSubview(pastelView, at: 0)
    }
}

