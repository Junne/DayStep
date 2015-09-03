//
//  ViewController.swift
//  DayStep
//
//  Created by Junne on 9/3/15.
//  Copyright (c) 2015 Junne. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addMyStep()
        self.addLittleCicle()

        
        
    }
    
    func addMyStep() {
        
        let myStep = UIImageView()
        myStep.image = UIImage(named: "Step")
        myStep.frame = CGRectMake(50, 50, 64, 64)
        myStep.alpha = 0
        self.view.addSubview(myStep)
        
        UIView.animateWithDuration(6, delay: 0, usingSpringWithDamping: 4, initialSpringVelocity: 2, options: nil, animations: { () -> Void in
            myStep.alpha = 1
            myStep.frame = CGRectMake(self.view.bounds.width - 70, self.view.bounds.height - 70, 34, 34)
        }, completion: nil)
        
    }
    
    func addLittleCicle() {
        
        let ovalStartAngle = CGFloat(90.01 * M_PI / 180)
        let ovalEndAngle = CGFloat(90 * M_PI / 180)
        let ovalRect = CGRectMake(self.view.bounds.width - 75, self.view.bounds.height - 75, 45, 45)
        
        let ovalPath = UIBezierPath()
        ovalPath.addArcWithCenter(CGPointMake(CGRectGetMidX(ovalRect), CGRectGetMidY(ovalRect)), radius: CGRectGetWidth(ovalRect) / 2, startAngle: ovalStartAngle, endAngle: ovalEndAngle, clockwise: true)
        
        let progressLine = CAShapeLayer()
        progressLine.path = ovalPath.CGPath
        progressLine.fillColor = UIColor.clearColor().CGColor
        progressLine.strokeColor = UIColor.blackColor().CGColor
        progressLine.lineWidth = 1.0
        progressLine.lineCap = kCALineCapRound
        
        self.view.layer.addSublayer(progressLine)
        
        let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        animateStrokeEnd.duration = 4.0
        animateStrokeEnd.fromValue = 0.0
        animateStrokeEnd.toValue = 1.0
        
        progressLine.addAnimation(animateStrokeEnd, forKey: "animate stroke end animation")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

