//
//  OnboardingViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/5/25.
//

import UIKit

class OnboardingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        Task {
            await TourApiManager.shared.fetchRcmCourseList(by: .area)

            DispatchQueue.main.async { [weak self] in
                self?.performSegue(withIdentifier: "tempSegue", sender: nil)
            }
        }
    }


}

