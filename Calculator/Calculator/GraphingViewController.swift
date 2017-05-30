//
//  GraphingViewController.swift
//  Calculator
//
//  Created by Gleb on 03.04.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class GraphingViewController: UIViewController {

    @IBOutlet weak var graphingView: GraphingView! {
        didSet {
            let handler = #selector(graphingView.changeScale(byReactingTo:))
            let pinchRecognizer = UIPinchGestureRecognizer(target: graphingView, action: handler)
            graphingView.addGestureRecognizer(pinchRecognizer)

            let doubleTapRecognizer = UITapGestureRecognizer(target: graphingView, action: #selector(graphingView.moveOrigin(byReactingTo:)))
            doubleTapRecognizer.numberOfTapsRequired = 2
            graphingView.addGestureRecognizer(doubleTapRecognizer)

            let panRecognizer = UIPanGestureRecognizer(target: graphingView, action: #selector(graphingView.moveGraph(byReactingTo:)))
            graphingView.addGestureRecognizer(panRecognizer)

            graphingView.graphingFunction = graphingFunction
        }
    }

    var graphingFunction: ((Double) -> Double)?
}
