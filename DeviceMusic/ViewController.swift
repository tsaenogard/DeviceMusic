//
//  ViewController.swift
//  DeviceMusic
//
//  Created by XCODE on 2017/5/15.
//  Copyright © 2017年 Gjun. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var imageView: UIImageView!
    var button: UIButton!
    var peakLabel: UILabel!
    var peakProgress: UIProgressView!
    var averageLabel: UILabel!
    var averageProgress: UIProgressView!
    var currentLabel: UILabel!
    var currentSlider: UISlider!
    var playingLabel: UILabel!
    
    var player: AVAudioPlayer!
    var path: String!
    let songs: [(name: String, file: String)] = [
        ("Niphargus Fantasy", "Fantasy"),
        ("Niphargus Flame", "Flame"),
        ("Niphargus Nebula", "Nebula"),
        ("Niphargus Express", "Express"),
        ("Niphargus Aero", "Aero")
    ]
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - function
    private func initUI() {
        self.imageView = UIImageView(image: UIImage(named: "background"))
        self.imageView.contentMode = .scaleAspectFill
        self.view.addSubview(self.imageView)
        
        self.button = UIButton()
        self.button.setTitle("選擇歌曲", for: .normal)
        self.button.setTitleColor(UIColor.darkGray, for: .normal)
        self.button.layer.borderWidth = 1.0
        self.button.layer.borderColor = UIColor.darkGray.cgColor
        self.button.layer.cornerRadius = 8.0
        self.button.addTarget(self, action: #selector(self.onButtonAction), for: .touchUpInside)
        self.view.addSubview(self.button)
        
        self.peakLabel = UILabel()
        self.peakLabel.text = "峰值"
        self.peakLabel.textColor = UIColor.darkGray
        self.view.addSubview(self.peakLabel)
        self.peakProgress = UIProgressView()
        self.peakProgress.progress = 0.0
        self.view.addSubview(self.peakProgress)
        
        self.averageLabel = UILabel()
        self.averageLabel.text = "平均值"
        self.averageLabel.textColor = UIColor.darkGray
        self.view.addSubview(self.averageLabel)
        self.averageProgress = UIProgressView()
        self.averageProgress.progress = 0.0
        self.view.addSubview(self.averageProgress)
        
        self.currentLabel = UILabel()
        self.currentLabel.text = "時間"
        self.currentLabel.textColor = UIColor.darkGray
        self.view.addSubview(self.currentLabel)
        self.currentSlider = UISlider()
        self.currentSlider.maximumValue = 1.0
        self.currentSlider.minimumValue = 0.0
        self.currentSlider.value = 0.0
        self.currentSlider.isEnabled = false
        self.currentSlider.addTarget(self, action: #selector(self.sliderAction(_:)), for: .valueChanged)
        self.view.addSubview(self.currentSlider)
        
        self.playingLabel = UILabel()
        self.playingLabel.textColor = UIColor.darkGray
        self.playingLabel.textAlignment = .center
        self.playingLabel.text = "未播放歌曲"
        self.view.addSubview(self.playingLabel)
    }
    
    private func setUI() {
        let frameW = UIScreen.main.bounds.width
        let gap: CGFloat = 10
        
        self.imageView.frame = self.view.frame
        
        let buttonW: CGFloat = 90
        let buttonH: CGFloat = 30
        let buttonX = frameW - buttonW - gap
        let buttonY: CGFloat = 20
        self.button.frame = CGRect(x: buttonX, y: buttonY, width: buttonW, height: buttonH)
        
        let labelX = frameW / 4
        let labelW: CGFloat = 60
        let labelH: CGFloat = 21
        let dataX = labelX + labelW + gap
        let dataW = frameW / 2 - gap - labelW
        let progressH: CGFloat = 2
        let sliderH: CGFloat = 30
        
        let peakLabelY = buttonY + buttonH + gap * 4
        let peakProgressY = peakLabelY + labelH / 2 + progressH / 2
        self.peakLabel.frame = CGRect(x: labelX, y: peakLabelY, width: labelW, height: labelH)
        self.peakProgress.frame = CGRect(x: dataX, y: peakProgressY, width: dataW, height: progressH)
        
        let averageLabelY = peakLabelY + labelH + progressH
        let averageProgressY = averageLabelY + labelH / 2 + progressH / 2
        self.averageLabel.frame = CGRect(x: labelX, y: averageLabelY, width: labelW, height: labelH)
        self.averageProgress.frame = CGRect(x: dataX, y: averageProgressY, width: dataW, height: progressH)
        
        let currentSliderY = averageLabelY + labelH + gap * 4
        let currentLabelY = currentSliderY + (sliderH - labelH) / 2
        self.currentLabel.frame = CGRect(x: labelX, y: currentLabelY, width: labelW, height: labelH)
        self.currentSlider.frame = CGRect(x: dataX, y: currentSliderY, width: dataW, height: sliderH)
        
        let playingW = frameW / 2
        let playingY = currentSliderY + sliderH + gap * 2
        self.playingLabel.frame = CGRect(x: labelX, y: playingY, width: playingW, height: labelH)
    }
    
    private func prepareForPlayer() {
        let url = URL(fileURLWithPath: self.path)
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            self.player.delegate = self
            self.player.prepareToPlay()
            self.player.isMeteringEnabled = true // 啟用音頻測試，可即時獲得音頻或分貝等訊息。
        } catch {
            print("播放器建構失敗")
        }
    }
    
    private func play() {
        self.currentSlider.isEnabled = true
        self.player.play()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.onTimerTick), userInfo: nil, repeats: true)
    }
    
    fileprivate func stop() {
        self.currentSlider.isEnabled = false
        self.currentSlider.value = 0.0
        self.peakProgress.progress = 0.0
        self.averageProgress.progress = 0.0
        self.timer.invalidate()
        self.timer = nil
    }
    
    private func printTime() {
        func formatTime(time: Int) -> String {
            let minute = time / 60
            let second = time % 60
            return String(format: "%0.2d:%0.2d", minute, second)
        }
        let current = formatTime(time: Int(self.player.currentTime))
        let duration = formatTime(time: Int(self.player.duration))
        print(current + " of " + duration)
    }
    
    //MARK: - selector
    func onButtonAction() {
        let alert = UIAlertController(title: "選擇歌曲", message: nil, preferredStyle: .actionSheet)
        
        for model in self.songs {
            guard let path = Bundle.main.path(forResource: model.file, ofType: "mp3") else { continue }
            let action = UIAlertAction(title: model.name, style: .default, handler: { (alert) in
                self.path = path
                self.playingLabel.text = model.name
                // 如果播放中，先停止
                if self.player != nil && self.timer != nil {
                    self.stop()
                }
                // 建構player
                self.prepareForPlayer()
                // 開始播放
                if self.player != nil {
                    self.play()
                }
            })
            alert.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func sliderAction(_ sender: UISlider) {
        self.player.currentTime = Double(sender.value) * Double(self.player.duration)
    }
    
    func onTimerTick() {
        self.player.updateMeters()
        
        let progressMax: Float = 3
        let average = -0.1 * self.player.averagePower(forChannel: 1)
        self.averageProgress.progress = (progressMax - average) / progressMax
        let peak = -0.3 * self.player.peakPower(forChannel: 1)
        self.peakProgress.progress = (progressMax - peak) / progressMax
        
        self.currentSlider.value = Float(self.player.currentTime / self.player.duration)
        self.printTime()
    }

}

extension ViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.stop()
    }
    
}




