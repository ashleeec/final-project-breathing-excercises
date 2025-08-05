//
//  StatsViewController.swift
//  whexhale
//
//  Created by ashley cheng on 4/8/2025.
//

import UIKit

class StatsViewController: UIViewController {
    @IBOutlet weak var sessionsLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var longestLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadStats()
    }

    private func loadStats() {
        let durations = UserDefaults.standard.array(forKey: "exhales") as? [Double] ?? []
        let count = durations.count
        let avg = durations.reduce(0, +) / Double(max(count,1))
        let maxDur = durations.max() ?? 0

        sessionsLabel.text = "Sessions: \(count)"
        averageLabel.text = String(format: "Avg Exhale: %.1fs", avg)
        longestLabel.text = String(format: "Longest: %.1fs", maxDur)
    }
}
