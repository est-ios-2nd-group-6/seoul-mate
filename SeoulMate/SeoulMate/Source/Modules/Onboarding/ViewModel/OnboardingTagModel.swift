//
//  OnboardingTagModel.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/13/25.
//

import Foundation

/// `OnboardingTagModel`은 온보딩 또는 설정 화면에서 관심사 태그 데이터를 관리하는 ViewModel입니다.
/// CoreDataManager를 통해 태그를 로드하고, 선택 상태를 토글하는 기능을 제공합니다.
final class OnboardingTagModel {
    // MARK: - 속성

    /// 화면에 표시할 태그 배열
    private(set) var tags: [Tag] = []

    /// 설정 화면에서 호출되었는지 여부
    var isFromSetting: Bool

    // MARK: - 초기화

    /// `OnboardingTagModel` 생성자
    /// - Parameter isFromSetting: 설정 화면에서 사용되는 경우 `true`
    init(isFromSetting: Bool = false) {
        self.isFromSetting = isFromSetting
    }

    // MARK: - 태그 로드

    /// CoreData에서 태그를 최초 페치하고, `tags` 프로퍼티에 저장합니다.
    func loadTags() async {
        // 처음 페치하여 CoreData가 초기화되도록 함
        await CoreDataManager.shared.firstFetchTagsAsync()

        // 실제 태그 데이터를 가져와 tags에 할당
        tags = await CoreDataManager.shared.fetchTagsAsync()
    }

    // MARK: - 선택된 태그 조회

    /// 선택된 태그의 이름을 Set으로 반환합니다.
    /// - Returns: 선택된 태그 이름의 집합
    func selectedTagNames() async -> Set<String> {
        let selectedTags = await CoreDataManager.shared.fetchSelectedTagsAsync()
        return Set(selectedTags.compactMap { $0.name })
    }

    /// 선택된 태그가 하나라도 있는지 여부를 반환합니다.
    /// - Returns: 하나 이상의 태그가 선택된 경우 `true`
    func hasSelectedTags() async -> Bool {
        let selected = await CoreDataManager.shared.fetchSelectedTagsAsync()
        return !selected.isEmpty
    }

    // MARK: - 태그 선택 토글

    /// 주어진 태그 이름에 해당하는 태그의 선택 상태를 토글합니다.
    /// - Parameter title: 토글할 태그의 이름
    /// - Returns: 토글 후 해당 태그의 선택 상태 (선택됨: `true`)
    func toggleSelection(for title: String) async -> Bool {
        // title과 일치하는 태그 검색
        guard let tag = tags.first(where: { $0.name == title }) else { return false }

        // CoreData에서 선택 토글 작업 수행
        await CoreDataManager.shared.tagSelectToggleAsync(tag: tag)
        
        // 변경된 선택 상태 반환
        return tag.selected
    }
}
