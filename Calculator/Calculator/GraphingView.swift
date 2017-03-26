//
//  GraphingView.swift
//  Calculator
//
//  Created by Gleb on 26.03.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

@IBDesignable
class GraphingView: UIView {

    private var drawer = AxesDrawer()

    @IBInspectable
    var scale: CGFloat = 100 { didSet{ setNeedsDisplay() } }

    @IBInspectable
    var axesColor: UIColor = .blue { didSet{ setNeedsDisplay() } }

    @IBInspectable
    var graphColor: UIColor = .black { didSet{ setNeedsDisplay() } }

    @IBInspectable
    var lineWidth: CGFloat = 2.0 { didSet{ setNeedsDisplay() } }

    @IBInspectable
    var minimumPointsPerHashmark: CGFloat = 10 { didSet{ setNeedsDisplay() } }
    
    private var plotOrigin: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }

    override func draw(_ rect: CGRect) {
        drawer.drawAxes(in: bounds, origin: plotOrigin, pointsPerUnit: scale)
        graphPath().stroke()
    }

    private func graphPath() -> UIBezierPath {
        graphColor.set()
        var xGraph, yGraph :CGFloat
        var x, y: Double
        let scale: CGFloat = 1.0

        let path = UIBezierPath()
        path.lineWidth = lineWidth

        for i in 0...Int(bounds.size.width){
            xGraph = CGFloat(i)
            x = Double ((xGraph - plotOrigin.x) / scale)
            y = x
            yGraph = plotOrigin.y - CGFloat(y) * scale

            if i > 0 {
                path.addLine(to: CGPoint(x: xGraph, y: yGraph))
            } else {
                path.move(to: CGPoint(x: xGraph, y: yGraph))
            }
            print("(\(xGraph),\(yGraph))")
        }
        return path
    }


}
