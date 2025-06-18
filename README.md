# Seoul Mate

## 낯선 서울을 친구처럼, 서울 메이트

서울 메이트는 즐거운 서울 여행을 위한 동반자입니다. 사용자의 취향에 맞는 여행 코스를 추천받고, 직접 원하는 장소를 추가하여 간편하게 여행 일정을 계획하고 관리할 수 있습니다.

-----

## ✨ 주요 기능

### **홈**

  - **맞춤 코스 추천**: 한국관광공사(TourAPI)에서 제공하는 정보를 바탕으로, 서울 지역의 인기 여행 코스와 사용자의 현재 위치를 기반으로 한 주변 추천 코스를 제공합니다.

### **검색**

  - **장소 검색**: 관광지, 맛집 등 원하는 장소를 키워드로 검색하고, 상세 정보를 확인할 수 있습니다.
  - **최근 검색 기록**: 최근 검색한 내용을 확인하고 관리할 수 있습니다.

### **내 여행**

- **새로운 여행 만들기**: 캘린더에서 원하는 날짜를 선택하여 간편하게 새로운 여행 계획을 생성할 수 있습니다.
- **여행 목록 확인**: 생성된 여행 계획들을 월별로 나누어 목록으로 한눈에 확인하고 관리할 수 있습니다.

### **지도 및 여행 계획 상세**

  - **장소 추가**: 지도에서 직접 새로운 장소를 검색하고 기존 일정에 추가할 수 있습니다.
  - **일정 장소 확인**: 선택한 여행의 일자별 장소들을 지도 위에서 마커로 확인할 수 있습니다.
  - **경로 탐색**: 각 장소들을 잇는 이동 경로(대중교통, 도보, 자동차)를 지도에 표시하고, 예상 소요 시간을 안내합니다.

### **설정**

  - **관심사 재설정**: 언제든지 관심사를 다시 선택하여 새로운 코스를 추천받을 수 있습니다.
  - **권한 관리**: 위치 정보 접근 권한을 앱 내에서 간편하게 재설정할 수 있습니다.

-----

## ⚙️ 구현 기술 및 라이브러리

  - **UI & Layout**: `UIKit`
  - **Data Persistence**: `CoreData`
  - **Concurrency**: `async/await`를 활용한 비동기 처리
  - **APIs**:
      - **Google Places API & Google Routes API**: 장소 검색, 상세 정보 및 경로 탐색
      - **TMap API**: 도보 및 자동차 경로 탐색
      - **TourAPI (한국관광공사)**: 추천 여행 코스 및 관광 정보 조회
  - **Maps**: `NMapsMap` (네이버 지도 SDK)
  - **Location**: `CoreLocation`

---

## 💿 프로젝트 세팅

### **1. API 키 설정**

이 프로젝트는 `Google`, `TourAPI`, `TMap` API를 사용합니다. 원활한 실행을 위해서는 각 서비스에서 발급받은 API 키를 프로젝트에 설정해야 합니다.

1.  Xcode에서 `SeoulMate/SeoulMate/Resource` 그룹으로 이동합니다.
2.  `Secrets.xcconfig` 파일을 새로 생성하고 아래와 같이 API 키를 추가합니다. (만약 파일이 이미 있다면 키 값만 추가합니다.)

    ```
    GOOGLE_API_KEY = "여기에 Google API 키를 입력하세요"
    TOUR_API_KEY = "여기에 공공데이터 Open Api 서비스 키를 입력하세요"
    TMAP_API_KEY = "여기에 TMap Api 키를 입력하세요"
    NaverMap_API_KEY = "여기에 Naver Map SDK 키를 입력하세요"
    ```

3.  프로젝트 설정의 `Info` 탭으로 이동하여 `Configurations`에서 `Debug`와 `Release` 모두 `Secrets`를 선택하여 방금 생성한 `xcconfig` 파일을 사용하도록 설정합니다.
4.  `Info.plist` 파일에 다음과 같이 Key를 추가하고, Value에는 `$(YOUR_KEY_NAME)` 형식으로 xcconfig 파일의 변수명을 연결합니다.

    * `GOOGLE_API_KEY`: `$(GOOGLE_API_KEY)`
    * `TOUR_API_KEY`: `$(TOUR_API_KEY)`
    * `TMAP_API_KEY`: `$(TMAP_API_KEY)`
    * `NaverMap_API_KEY`: `${NaverMap_API_KEY}`

### **2. 빌드 및 실행**

API 키 설정이 완료되면, `Command + R`을 눌러 프로젝트를 빌드하고 시뮬레이터 또는 디바이스에서 실행할 수 있습니다.

---

## 📁 폴더 구조

```
.
└── 📂 SeoulMate
    ├── 📂 SeoulMate
    │   ├── 📂 Resource
    │   │   ├── Assets.xcassets    # 이미지, 컬러 등 리소스
    │   │   └── Storyboards        # Storyboard 파일
    │   │
    │   ├── 📂 Source
    │   │   ├── 📂 Components      # In-App 알림 등 재사용 가능한 UI 컴포넌트
    │   │   ├── 📂 Extensions      # Foundation, UIKit 클래스 확장
    │   │   ├── 📂 Models          # 데이터 모델 (API DTO, CoreData 모델 등)
    │   │   ├── 📂 Modules         # 각 화면(탭)별 모듈
    │   │   └── 📂 Services        # API 통신, 이미지 캐싱 등 서비스 관리
    │   │
    │   └── 📂 Support
    │       ├── Info.plist
    │       └── Secret.xcconfig    # Api Key 관리 설정 파일
    │   
    └── 📂 SeoulMate.xcodeproj
```

---

## 🧑‍💻 개발자

| Name | GitHub Profile |
| :--- | :--- |
| 김현식 | `https://github.com/hyuns12` |
| 성주현 | `https://github.com/juhyeon-seong` |
| 윤혜주 | `https://github.com/hyejuyun` |
| 하재준 | `https://github.com/hajunha` |
