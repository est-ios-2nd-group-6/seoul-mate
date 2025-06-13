//
//  OnboardingTagModel.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/13/25.
//

import Foundation

final class OnboardingTagModel {
    private(set) var tags: [Tag] = []

    func loadTags() async {
        await CoreDataManager.shared.firstFetchTagsAsync()
        tags = await CoreDataManager.shared.fetchTagsAsync()
    }

    func selectedTagNames() async -> Set<String> {
        let selectedTags = await CoreDataManager.shared.fetchSelectedTagsAsync()
        return Set(selectedTags.compactMap { $0.name })
    }

    func hasSelectedTags() async -> Bool {
        let selected = await CoreDataManager.shared.fetchSelectedTagsAsync()
        return !selected.isEmpty
    }

    func toggleSelection(for title: String) async -> Bool {
        guard let tag = tags.first(where: { $0.name == title }) else { return false }
        await CoreDataManager.shared.tagSelectToggleAsync(tag: tag)
        return tag.selected
    }
}
