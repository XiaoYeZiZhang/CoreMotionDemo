//
//  GraphSegment.swift
//  Demo
//
//  Created by zhangye on 2020/5/7.
//  Copyright © 2020 zju. All rights reserved.
//

import UIKit
import simd

class GraphSegment: UIView {

    private(set) var dataPoints = [double3]()
    
    static let capacity = 32
    
    private let startPoint: double3
    
    private let valueRanges: [ClosedRange<Double>]
    
    static let lineColors: [UIColor] = [.red, .green, .blue]
    
    var isFull: Bool {
        return dataPoints.count >= GraphSegment.capacity
    }
    
    
    init(startPoint: double3, valueRanges: [ClosedRange<Double>]) {
        self.startPoint = startPoint
        self.valueRanges = valueRanges
        
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func add(_ values: double3) {
        if dataPoints.count < GraphSegment.capacity {
            dataPoints.append(values)
            setNeedsDisplay()
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        if let context = UIGraphicsGetCurrentContext() {
            if let backgroundColor = backgroundColor?.cgColor {
                context.setFillColor(backgroundColor)
                context.fill(rect)
            }
            
            context.drawGraphLines(int: bounds.size)
            
            context.setShouldAntialias(false)
            context.translateBy(x: 0, y: bounds.height/2.0)
            
            for lineIndex in 0..<3 {
                context.setStrokeColor(GraphSegment.lineColors[lineIndex].cgColor)
                
                let value = startPoint[lineIndex]
                let point = CGPoint(x: bounds.size.width, y: scaledValue(for: lineIndex, value: value))
                context.move(to: point)
                
                for(pointIndex, dataPoint) in dataPoints.enumerated() {
                    let value = dataPoint[lineIndex]
                    
                    let point = CGPoint(x: bounds.size.width-CGFloat(pointIndex+1), y: scaledValue(for: lineIndex, value: value))
                    
                    context.addLine(to: point)
                }
                context.strokePath()
            }
            
            
        }
    }
    
    private func scaledValue(for lineIndex: Int, value: Double) ->CGFloat {
        let valueRange = valueRanges[lineIndex]
        let scale = Double(bounds.size.height) / (valueRange.upperBound - valueRange.lowerBound)
        return CGFloat(floor(value * -scale))
    }
    

}

extension CGContext {
    func drawGraphLines(int size: CGSize) {
        self.saveGState()
        setShouldAntialias(false)
        
        translateBy(x: 0, y: size.height/2.0)
        
        let gridLineSpacing = size.height / 8.0
        
        for index in -3 ... 3 {
            if index != 0 {
                let position = floor(gridLineSpacing * CGFloat(index))
                move(to: CGPoint(x: 0, y: position))
                addLine(to: CGPoint(x: size.width, y: position))
            }
        }
        
        setStrokeColor(UIColor.darkGray.cgColor)
        strokePath()
        
        
        move(to: CGPoint(x: 0, y: 0))
        addLine(to: CGPoint(x: size.width, y: 0))
        
        setStrokeColor(UIColor.lightGray.cgColor)
        strokePath()
        
        self.restoreGState()
    }
}
