//
//  POI+Extension.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/18/25.
//

import Foundation
import UIKit

extension POI {
    var assetImageName: String {
        switch name {
        case "남대문": return "Namdaemun"
        case "명동성당": return "cathedral"
        case "청계천": return "Cheonggyecheon"
        case "광장시장": return "Gwangjang_Market"
        case "경복궁": return "gyeongbokgung"
        case "창덕궁": return "changdeokgung"
        case "북촌한옥마을": return "bukchon"
        case "서울시청": return "seoul_cityhall"
        case "덕수궁": return "deoksugung"
        case "서울숲": return "seoul_forest"
        case "한강", "망원한강공원", "뚝섬한강공원", "한강 잠원지구", "한강대교 야경": return "hankang"
        case "봉은사": return "bongeunsa"
        case "코엑스몰": return "coex"
        case "DDP": return "ddp"
        case "동대문시장": return "dongdaemun_market"
        case "N서울타워", "남산타워": return "namsan_tower"
        case "롯데월드몰", "롯데월드": return "lotte_world"
        case "롯데타워": return "lotte_tower"
        default:
            return categoryAssetName
        }
    }

    private var categoryAssetName: String {
        switch category {
        case "카페", "카페투어": return "cafe"
        case "맛집": return "restaurant"
        case "역사유적", "궁궐", "사찰", "역사", "고궁", "한옥마을", "전통시장", "한옥": return "palace"
        case "전시관", "미술관", "박물관", "뮤지엄·미술관": return "museum"
        case "시장": return "market"
        case "공원", "도심공원", "한강공원": return "park"
        case "거리", "테마거리": return "street"
        case "전망", "전망대": return "tower"
        case "복합문화공간": return "culture"
        case "쇼핑몰", "옷가게", "핫플레이스", "플리마켓", "디자이너숍": return "shopping"
        case "건축": return "architecture"
        case "성당": return "cathedral"
        case "야경", "야경 명소", "루프탑바": return "nightview"
        case "브런치 스팟", "스트리트푸드": return "restaurant"
        case "공연·페스티벌", "인디·라이브", "스트리트아트": return "culture"
        case "산책로·둘레길", "자전거투어": return "park"
        default: return "placeholder"
        }
    }
}
