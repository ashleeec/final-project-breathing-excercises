//
//  StatsViewController.swift
//  whexhale
//
//  Created by ashley cheng on 4/8/2025.
//

import UIKit
import ImageIO   // for decoding GIF frames

class BreathingViewController: UIViewController {
    // MARK: - Outlets (connect these in IB)
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var whaleImageView: UIImageView!
    @IBOutlet weak var waterImageView: UIImageView!
    
    // MARK: - Properties
    private var startTime: Date?
    private var isExhaling = false

    // MARK: Frames
    private var waterFrames: [UIImage] = []
    private var holdFrame: UIImage? {
        return waterFrames.indices.contains(3) ? waterFrames[3] : nil
    }
    private var riseFrames: [UIImage] {
        return Array(waterFrames.prefix(3))
    }

    private var fallFrames: [UIImage] {
        guard waterFrames.count > 4 else { return [] }
        return Array(waterFrames.suffix(from: 4))
    }

    private let impact = UIImpactFeedbackGenerator(style: .soft)

    override func viewDidLoad() {
        super.viewDidLoad()
        loadWaterFrames()
        configureViews()
        setupGestures()
    }

    // MARK: Load GIF Data → frames
    private func loadWaterFrames() {
        guard let dataAsset = NSDataAsset(name: "water"),
              let src = CGImageSourceCreateWithData(dataAsset.data as CFData, nil)
        else { return }

        let count = CGImageSourceGetCount(src)
        for i in 0..<count {
            if let cg = CGImageSourceCreateImageAtIndex(src, i, nil) {
                waterFrames.append(UIImage(cgImage: cg))
            }
        }
    }

    // MARK: Initial UI
    private func configureViews() {
        whaleImageView.image = UIImage(named: "whale")
        whaleImageView.contentMode = .scaleAspectFit

        waterImageView.image = nil
        waterImageView.contentMode = .scaleAspectFit

        feedbackLabel.text = "Press and hold to breathe"
    }

    // MARK: Gesture Setup
    private func setupGestures() {
        // 1) Long press on whale → inhale/exhale
        let longPress = UILongPressGestureRecognizer(target: self,
                                                     action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.1
        whaleImageView.isUserInteractionEnabled = true
        whaleImageView.addGestureRecognizer(longPress)

        // 2) Tap anywhere → end exhale (fall)
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
    }

    // MARK: Long-press Handler
    @objc private func handleLongPress(_ g: UILongPressGestureRecognizer) {
        switch g.state {
        case .began:
            inhale()
        case .ended, .cancelled:
            startExhale()
        default: break
        }
    }

    // MARK: Tap Handler (end exhale)
    @objc private func handleTap(_ g: UITapGestureRecognizer) {
        guard isExhaling else { return }
        finishExhale()
    }

    // MARK: Inhale
    private func inhale() {
        startTime = Date()
        impact.impactOccurred()
        isExhaling = false

        UIView.animate(withDuration: 0.3) {
            self.whaleImageView.transform = CGAffineTransform(scaleX: 1.1,
                                                              y: 1.1)
        }
    }

    // MARK: Start Exhale (rise → hold)
    private func startExhale() {
        guard let start = startTime else { return }
        isExhaling = true
        let duration = Date().timeIntervalSince(start)
        impact.impactOccurred()

        // reset whale
        UIView.animate(withDuration: 0.3) {
            self.whaleImageView.transform = .identity
        }

        // 1) play rise frames
        waterImageView.animationImages = riseFrames
        waterImageView.animationDuration = Double(riseFrames.count) * 0.1  // slow down
        waterImageView.animationRepeatCount = 1
        waterImageView.startAnimating()

        // 2) when rise done, show hold frame
        DispatchQueue.main.asyncAfter(deadline: .now() + waterImageView.animationDuration) {
            self.waterImageView.stopAnimating()
            self.waterImageView.image = self.holdFrame
        }

        // feedback
        feedbackLabel.text = String(format: "Exhaling… (%.1fs)", duration)
    }

    // MARK: Finish Exhale (fall frames)
    private func finishExhale() {
        isExhaling = false

        // play fall
        waterImageView.animationImages = fallFrames
        waterImageView.animationDuration = Double(fallFrames.count) * 0.1
        waterImageView.animationRepeatCount = 1
        waterImageView.startAnimating()

        // clear afterwards
        DispatchQueue.main.asyncAfter(deadline: .now() + waterImageView.animationDuration) {
            self.waterImageView.stopAnimating()
            self.waterImageView.image = nil
        }
    }
}
