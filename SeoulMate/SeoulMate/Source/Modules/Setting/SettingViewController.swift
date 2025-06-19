//
//  SettingViewController.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/16/25.
//

import UIKit

/// `SettingViewController`는 서울메이트 앱의 설정 화면을 관리합니다.
/// 테이블 뷰에 설정 옵션을 표시하고, 상세 설정 화면으로 네비게이션을 처리합니다.
class SettingViewController: UIViewController {
    // MARK: - 아울렛

    /// 설정 항목을 표시하는 테이블 뷰
    @IBOutlet weak var settingTableView: UITableView!

    // MARK: - 라이프사이클

      /// 뷰가 메모리에 로드된 직후에 호출됩니다.
      /// 네비게이션 바의 타이틀과 prefersLargeTitles 설정을 초기화합니다.
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "설정"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }

    /// 뷰가 화면에 나타나기 직전에 호출됩니다.
    /// 네비게이션 바가 항상 보이도록 설정하고, 기본 tintColor를 적용합니다.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.tintColor = .label
    }

    // MARK: - 네비게이션 준비

    /// 세그웨이가 실행되기 전에 호출됩니다.
    /// 관심사 설정 화면으로 이동할 때 ViewModel을 전달합니다.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTagSetting",
           let vc = segue.destination as? OnboadingTagSelectViewController {
            vc.viewModel = OnboardingTagModel(isFromSetting: true)
        }
    }

    /// 세그웨이를 수행할지 여부를 결정합니다.
    /// 관심사 설정 액션에 대해서만 세그웨이를 허용합니다.
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
            guard identifier == "showTagSetting",
                  let cell = sender as? UITableViewCell,
                  let indexPath = settingTableView.indexPath(for: cell)
            else {
                return true
            }

            let action = SettingSection(rawValue: indexPath.section)!.actions[indexPath.row]
            return action == .interestSetting
        }

}
// MARK: - UITableViewDataSource
extension SettingViewController: UITableViewDataSource {
    /// 섹션의 개수를 반환합니다.
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingSection.allCases.count
    }

    /// 주어진 섹션의 행 개수를 반환합니다.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = SettingSection(rawValue: section)!
        return section.actions.count
    }

    /// 섹션 헤더에 표시할 제목을 반환합니다.
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        return SettingSection(rawValue: section)?.title
    }

    /// 주어진 indexPath에 대한 셀을 구성하고 반환합니다.
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = SettingSection(rawValue: indexPath.section)
        let action = section?.actions[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ActionCell", for: indexPath
        ) as! SettingTableViewCell
        cell.itemLabel.text = action?.displayText
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    /// 셀 선택 이벤트를 처리합니다.
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let section = SettingSection(rawValue: indexPath.section)!
        let action = section.actions[indexPath.row]

        switch action {
        case .interestSetting:
            // segue로 처리
            break
        case .locationPermission:
            // 위치 권한 설정 화면으로 이동
            let settingsURL = URL(string: UIApplication.openSettingsURLString)!
            guard UIApplication.shared.canOpenURL(settingsURL) else { return }
            UIApplication.shared.open(settingsURL)
        }
    }
}
