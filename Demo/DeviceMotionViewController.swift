//
//  DeviceMotionViewController.swift
//  Demo
//
//  Created by zhangye on 2020/5/7.
//  Copyright © 2020 zju. All rights reserved.
//

import UIKit
import CoreMotion
import simd
class DeviceMotionViewController: UIViewController {

    @IBOutlet var graphSelector: UISegmentedControl!
    @IBOutlet var graphContainer: UIView!
    
    
    private var graphViews: [GraphView] = []
    
    var motionManager: CMMotionManager? = CMMotionManager.shared
    
    private var selectedDeviceMotion: DeviceMotion {
        return DeviceMotion(rawValue: graphSelector.selectedSegmentIndex)!
    }
    
    @IBAction func intervalSliderChanged(_ sender: UISlider) {
        startUpdate()
    }
    
    @IBAction func graphSelectorChanged(_ sender: UISegmentedControl) {
        showGraph(selectedDeviceMotion)
    }
    
    @IBOutlet weak var updateIntervalSlider: UISlider!
    
    @IBOutlet var valueLabels: [UILabel]!
    
    
    func showGraph(_ motionType: DeviceMotion) {
        let selectedGraphIndex = motionType.rawValue
        for(index, graph) in graphViews.enumerated() {
            graph.isHidden = index != selectedGraphIndex
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        graphViews = DeviceMotion.allType.map {
            type in
            return GraphView(frame: graphContainer.bounds)
        }
        
        for graphView in graphViews {
            graphContainer.addSubview(graphView)
            graphView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        // Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startUpdate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopUpdate()
    }
    
    private func graphView(for motionType: DeviceMotion)->GraphView {
        let value = motionType.rawValue
        return graphViews[value]
    }
    
    func startUpdate() {
        if let motionManager = motionManager, motionManager.isDeviceMotionAvailable {
            showGraph(selectedDeviceMotion)
            
            motionManager.deviceMotionUpdateInterval = TimeInterval(updateIntervalSlider.value)
            motionManager.showsDeviceMovementDisplay = true
            
            motionManager.startDeviceMotionUpdates(to: .main) { (deviceMotion, error) in
                if let deviceMotion = deviceMotion {
                    let attitude = double3([deviceMotion.attitude.roll, deviceMotion.attitude.pitch, deviceMotion.attitude.yaw])
                    
                    let rotationRate = double3([deviceMotion.rotationRate.x, deviceMotion.rotationRate.y, deviceMotion.rotationRate.z])
                    
                    let gravity = double3([deviceMotion.gravity.x, deviceMotion.gravity.y, deviceMotion.gravity.z])
                    
                    let userAcceleration = double3([deviceMotion.userAcceleration.x, deviceMotion.userAcceleration.y, deviceMotion.userAcceleration.z])
                    
                    self.graphView(for: .attitude).add(attitude)
                    self.graphView(for: .rotationRate).add(rotationRate)
                    self.graphView(for: .gravity).add(gravity)
                    self.graphView(for: .userAcceleration).add(userAcceleration)
                    
                    switch self.selectedDeviceMotion {
                    case .attitude:
                        self.setValueLabels(rollPitchYaw: attitude)
                    case .rotationRate:
                        self.setValueLabels(xyz: rotationRate)
                    case .gravity:
                        self.setValueLabels(xyz: gravity)
                    case .userAcceleration:
                        self.setValueLabels(xyz: userAcceleration)
                    }

                }
            }
        }
    }
    
    func stopUpdate() {
        if let motionManager = motionManager, motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    private var sortedLabels: [UILabel] {
        return valueLabels.sorted { $0.center.y < $1.center.y }
    }
    
    func setValueLabels(rollPitchYaw: double3) {
        let sortedLabels = self.sortedLabels
        sortedLabels[0].text = String(format: "Roll: %+6.4f", rollPitchYaw[0])
        sortedLabels[1].text = String(format: "Pitch: %+6.4f", rollPitchYaw[1])
        sortedLabels[2].text = String(format: "Yaw: %+6.4f", rollPitchYaw[2])
    }
    
    func setValueLabels(xyz: double3) {
        let sortedLabels = self.sortedLabels
        sortedLabels[0].text = String(format: "x: %+6.4f", xyz[0])
        sortedLabels[1].text = String(format: "y: %+6.4f", xyz[1])
        sortedLabels[2].text = String(format: "z: %+6.4f", xyz[2])
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


enum DeviceMotion: Int {
    case attitude, rotationRate, gravity, userAcceleration
    
    static var allType: [DeviceMotion] = [.attitude, .rotationRate, .gravity, .userAcceleration]
    
}
