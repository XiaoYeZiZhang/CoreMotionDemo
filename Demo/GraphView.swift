//
//  GraphView.swift
//  Demo
//
//  Created by zhangye on 2020/5/7.
//  Copyright © 2020 zju. All rights reserved.
//

import UIKit
import simd

class GraphView: UIView {

    private var segments = [GraphSegment]()
    
    private var currentSegment: GraphSegment? {
        return segments.last
    }
    
    var valueRanges = [-4.0...4.0, -4.0...4.0, -4.0...4.0]

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .black
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        if let context = UIGraphicsGetCurrentContext() {
            if let backgroundColor = backgroundColor?.cgColor {
                context.setFillColor(backgroundColor)
                context.fill(bounds)
            }
            
            context.drawGraphLines(int: bounds.size)
        }
    }
    
    func add(_ values: double3) {
        
        for segment in segments {
            segment.center.x += 1
        }
        
        if segments.isEmpty {
            addSegment()
        }else if let segment = currentSegment, segment.isFull {
            addSegment()
            purgeSegments()
        }
        
        currentSegment?.add(values)
    }
    
    
    private func addSegment() {
        let segmentWidth = CGFloat(GraphSegment.capacity)
        let startPoint: double3
        if let currentSegment = currentSegment {
            startPoint = currentSegment.dataPoints.last!
        }else {
            startPoint = [0,0,0]
        }
        
        let segment = GraphSegment(startPoint: startPoint, valueRanges: valueRanges)
        segments.append(segment)
        
        segment.frame = CGRect(x: -segmentWidth, y: 0, width: segmentWidth, height: bounds.size.height)
        segment.backgroundColor = backgroundColor
        addSubview(segment)
    }
    
    private func purgeSegments() {
        segments = segments.filter {
            segment in
            if segment.frame.origin.x >= bounds.size.width {
                segment.removeFromSuperview()
                return false
            }else {
                return true
            }
        }
    }
    

}
