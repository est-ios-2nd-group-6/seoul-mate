//
//  SettingViewController.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/16/25.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var settingTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "설정"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.tintColor = .label
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTagSetting",
           let vc = segue.destination as? OnboadingTagSelectViewController {
            vc.viewModel = OnboardingTagModel(isFromSetting: true)
        }
    }

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
extension SettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = SettingSection(rawValue: section)!
        return section.actions.count
    }

    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        return SettingSection(rawValue: section)?.title
    }

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

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let section = SettingSection(rawValue: indexPath.section)!
        let action = section.actions[indexPath.row]

        switch action {
        case .interestSetting: break
        case .locationPermission:
            let settingsURL = URL(string: UIApplication.openSettingsURLString)!
            guard UIApplication.shared.canOpenURL(settingsURL) else { return }
            UIApplication.shared.open(settingsURL)
        }
    }
}
