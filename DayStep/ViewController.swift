//
//  ViewController.swift
//  DayStep
//
//  Created by Junne on 9/3/15.
//  Copyright (c) 2015 Junne. All rights reserved.
//

import UIKit
import LiquidFloatingActionButton
import HealthKit
import pop


class ViewController: UIViewController {
    
    var cells: [LiquidFloatingCell] = []
    var floatingActionButton: LiquidFloatingActionButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addMyStep()
        self.addLittleCicle()
        self.addChooseButtons()
        self.authorizeHealthKit()
        
    }

    // MARK: UI and Animation
    
//    func addStepCount() {
//        
//        let one = 0
//        let onezerozero = 100
//        let numberLabel:UILabel = UILabel(frame: CGRectMake(150, 200, 100, 100))
//        numberLabel.text = "hello world"
//        numberLabel.font = UIFont.boldSystemFontOfSize(30)
//        self.view.addSubview(numberLabel)
//        
//        let animationPeriod:Float = 10;
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), { () -> Void in
//            
////            for i in 1...100 {
////                usleep(animationPeriod/100 * 1000000)
////                dispatch_async(dispatch_get_main_queue(), { () -> Void in
////                    numberLabel.text = NSString(i)
////                })
////            }
//        })
////        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
////            for (int i = 1; i < 101; i ++) {
////                usleep(animationPeriod/100 * 1000000); // sleep in microseconds
////                dispatch_async(dispatch_get_main_queue(), ^{
////                    yourLabel.text = [NSString stringWithFormat:@"%d", i];
////                    });
////            }
////            });
//        
//    }
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
        
        UIView.animateWithDuration(0.5, delay: 6, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: nil, animations: { () -> Void in
            myStep.frame.size = CGSizeMake(54, 54)
        }, completion: nil)
        
        UIView.animateWithDuration(0.5, delay: 6.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: nil, animations: { () -> Void in
            myStep.frame.size = CGSizeMake(34, 34)
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
        progressLine.lineWidth = 0.5
        progressLine.lineCap = kCALineCapRound
        
        self.view.layer.addSublayer(progressLine)
        
        let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        animateStrokeEnd.duration = 4.0
        animateStrokeEnd.fromValue = 0.0
        animateStrokeEnd.toValue = 1.0
        
        progressLine.addAnimation(animateStrokeEnd, forKey: "animate stroke end animation")
        
    }
    
    func addChooseButtons() {
        
        let createButton: (CGRect, LiquidFloatingActionButtonAnimateStyle) -> LiquidFloatingActionButton = { (frame, style) in
            let floatingActionButton = LiquidFloatingActionButton(frame: frame)
            floatingActionButton.animateStyle = style
            floatingActionButton.dataSource = self
            floatingActionButton.delegate = self
            return floatingActionButton
        }
        
        let cellFactory: (String) -> LiquidFloatingCell = { (iconName) in
            return LiquidFloatingCell(icon: UIImage(named: iconName)!)
        }
        cells.append(cellFactory("ic_cloud"))
        cells.append(cellFactory("ic_system"))
        cells.append(cellFactory("ic_place"))
        
        let floatingFrame = CGRect(x: self.view.frame.width - 75, y: self.view.frame.height - 75, width: 45, height: 45)
        let bottomRightButton = createButton(floatingFrame, .Up)
        self.view.addSubview(bottomRightButton)
        bottomRightButton.alpha = 0
        bottomRightButton.color = UIColor(red: 250, green: 0, blue: 250, alpha: 1)
        
        UIView.animateWithDuration(7.2, delay: 7, options: nil, animations: { () -> Void in
            bottomRightButton.alpha = 1
        }, completion: nil)
        
        
    }
    
    //MARK: read step count
    
    let healthManager:HealthManager = HealthManager()
    
    func authorizeHealthKit() {
        
        healthManager.authorizeHealthKit { (authorized, error) -> Void in
            if authorized {
                println("HealthKit authorization received.")
                self.updateTodayStepCountsInfo()
                self.update7DaysStepCounts()
            } else {
                println("HealthKit authorization denied!")
                if error != nil {
                    println("\(error)")
                }
            }
        }
    }
    
    func update7DaysStepCounts() {
        healthManager.read7DaysStepCounts { (datas, error) -> Void in
            println(datas)
        }
    }
    
    func updateTodayStepCountsInfo() {
        
        let querySampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        healthManager.readTodayStepCount(querySampleType, completion: { (todayStepCounts, error) -> Void in
            if error != nil {
                println("Error read today step counts")
                return;
            }
            println("Get today step counts = \(todayStepCounts)")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if todayStepCounts > 0 {
                    self.addNumberLabel(todayStepCounts)
                }
            })
        })
    }
    
    func addNumberLabel(stepCounts:Int) {
        
        let numberLabel:UILabel
        numberLabel = UILabel(frame: CGRectMake(self.view.bounds.size.width/2 - 100, 200, 200, 100))
        numberLabel.font = UIFont(name: "Avenir-Book", size: 70)
        numberLabel.textColor = UIColor(red: 0.46, green: 0.76, blue: 0.78, alpha: 1)
        numberLabel.textAlignment = .Center
        let propop:POPAnimatableProperty = POPAnimatableProperty.propertyWithName("numberIncrease") { property in
            
            property.writeBlock = { obj, values in
                let label:UILabel = obj as! UILabel
                numberLabel.text = String(Int(values[0]))
            }
            } as! POPAnimatableProperty
        
        let aBasicAnimation:POPBasicAnimation = POPBasicAnimation.linearAnimation()
        aBasicAnimation.property  = propop
        aBasicAnimation.fromValue = 0
        aBasicAnimation.toValue   = stepCounts
        if stepCounts > 5000 {
            aBasicAnimation.duration  = 15
        } else {
            aBasicAnimation.duration = 8
        }
        aBasicAnimation.beginTime = CACurrentMediaTime()
        numberLabel.pop_addAnimation(aBasicAnimation, forKey: "numberIncrease")
        self.view.addSubview(numberLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension ViewController:LiquidFloatingActionButtonDataSource,LiquidFloatingActionButtonDelegate {
    
    func numberOfCells(liquidFloatingActionButton: LiquidFloatingActionButton) -> Int {
        return self.cells.count
    }
    
    func cellForIndex(index: Int) -> LiquidFloatingCell {
        return self.cells[index]
    }
    
    func liquidFloatingActionButton(liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int) {
    }
    
}

