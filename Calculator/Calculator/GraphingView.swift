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
    var axesColor: UIColor = .blue {
        willSet { drawer.color = newValue }
        didSet{ setNeedsDisplay() }
    }

    @IBInspectable
    var graphColor: UIColor = .black { didSet{ setNeedsDisplay() } }

    @IBInspectable
    var lineWidth: CGFloat = 2.0 { didSet{ setNeedsDisplay() } }

    @IBInspectable
    var minimumPointsPerHashmark: CGFloat = 10 { didSet{ setNeedsDisplay() } }

    private lazy var origin: CGPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)

    private var plotOrigin: CGPoint {
        get {
            return origin
        }
        set {
            origin = newValue
            setNeedsDisplay()
        }

    }

    var graphingFunction: ((Double) -> Double)? { didSet { setNeedsDisplay() } }

    override func draw(_ rect: CGRect) {
        drawer.drawAxes(in: bounds, origin: plotOrigin, pointsPerUnit: scale)
        graphPath()?.stroke()
    }

    private func graphPath() -> UIBezierPath? {
        if graphingFunction != nil {
            graphColor.set()
            var xGraph, yGraph :CGFloat
            var x, y: Double
            let path = UIBezierPath()
            path.lineWidth = lineWidth

            var isFirstPoint = true
            for i in 0...Int(bounds.size.width){
                xGraph = CGFloat(i)
                x = Double ((xGraph - plotOrigin.x) / scale)

                y = graphingFunction!(x)

                if y.isNormal || y.isZero {
                    yGraph = plotOrigin.y - CGFloat(y) * scale

                    if !isFirstPoint {
                        path.addLine(to: CGPoint(x: xGraph, y: yGraph))
                    } else {
                        path.move(to: CGPoint(x: xGraph, y: yGraph))
                        isFirstPoint = false
                    }
                }
                //print("(\(xGraph),\(yGraph))")
            }
            //print("origin(\(plotOrigin.x),\(plotOrigin.y))")
            //print("scale: \(scale)")
            return path
        }
        return nil
    }

    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default:
            break
        }
    }

    func moveOrigin(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        if tapRecognizer.state == .ended {
            plotOrigin = tapRecognizer.location(in: self)
        }
    }

    func moveGraph(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .changed, .ended:
            let translation = panRecognizer.translation(in: self)
            plotOrigin =  CGPoint(x: plotOrigin.x + translation.x, y: plotOrigin.y + translation.y)
            panRecognizer.setTranslation(CGPoint(), in: self)
        default:
            break
        }
    }
}
