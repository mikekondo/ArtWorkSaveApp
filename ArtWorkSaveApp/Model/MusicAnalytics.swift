//
//  MusicAnalytics.swift
//  ArtWorkSaveApp
//
//  Created by 近藤米功 on 2022/01/01.
//

import Foundation
import Alamofire
import SwiftyJSON
import PKHUD

protocol itaCatchMusicDataDelegate{
    func itaCatchMusicData(passedMusicDataArray:[MusicModel])
}

class MusicAnalytics{
    //音楽モデル
    var musicModelArray = [MusicModel]()
    
    //プロトコルの実態化
    var delegate:itaCatchMusicDataDelegate?
    
    //iTunesAPIの実行
    func itaExe(itaUrl:String){
        
        //エンコード
        let encodeUrl:String = itaUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        //インディケータの表示
        HUD.show(.progress)
        
        //Almofireによる通信
        AF.request(encodeUrl, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            
            switch response.result{
            case.success:
                do{
                    self.musicModelArray = []
                    //SwiftyJSONでJSON解析
                    let json:JSON = try JSON(data:response.data!)
                    let resultCount = json["results"].count
                    for i in 0..<resultCount{
                        if let artistName = json["results"][i]["artistName"].string,let collectionName = json["results"][i]["collectionName"].string,let trackName = json["results"][i]["trackName"].string,let previewUrl = json["results"][i]["previewUrl"].string,var artworkUrl = json["results"][i]["artworkUrl100"].string{
                            //アーティスト写真を大きくする処理("100x100bb"のままだと画質が落ちるため)
                            if let range = artworkUrl.range(of:"100x100bb"){
                                artworkUrl.replaceSubrange(range, with: "2000x2000bb")
                            }
                            let musicModel = MusicModel(artistName_: artistName, collectionName_: collectionName, trackName_: trackName, previewUrl_: previewUrl, artworkUrl_: artworkUrl)
                            self.musicModelArray.append(musicModel)
                        }
                    }//for文ここまで
                    HUD.hide()
                    //プロトコルを用いてコントローラーへmusicModelArrayを渡す
                    self.delegate?.itaCatchMusicData(passedMusicDataArray: self.musicModelArray)
                }//doここまで
                catch{
                    return
                }
            case .failure(_):
                print("通信失敗")
                return
            }//switchここまで
        }//AF通信ここまで
        
    }//itaExeここまで
}
