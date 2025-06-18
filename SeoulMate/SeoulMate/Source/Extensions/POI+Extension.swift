//
//  POI+Extension.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/18/25.
//

import Foundation
import UIKit

// POI 모델 확장을 통해 장소 이름 또는 카테고리에 대응하는 앱 자산 이미지 이름을 제공합니다.
///
/// - `assetImageName`: POI의 `name`을 기준으로 매핑된 이미지 파일 이름을 반환하며,
///   해당 이름이 없는 경우 `categoryAssetName`으로 대체합니다.
/// - `categoryAssetName`: POI의 `category`를 기준으로 매핑된 이미지 파일 이름을 반환합니다.
extension POI {
    /// NSManagedObject가 영구 저장소에 처음 삽입(insert)될 때 호출됩니다.
    ///
    /// 이 시점에 고유 식별자(UUID)를 `id` 속성에 자동으로 할당하여
    /// 모든 POI 인스턴스가 반드시 유효한 `id`를 갖도록 보장합니다.
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID()
    }

    /// POI의 `name`에 대응하는 이미지 자산 이름을 반환합니다.
    /// 지정된 이름이 일치하지 않으면 `categoryAssetName`을 대신 사용합니다.
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

    /// POI의 `category`에 대응하는 이미지 자산 이름을 반환합니다.
    /// 주로 `assetImageName`에서 매핑되지 않은 경우 사용됩니다.
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
