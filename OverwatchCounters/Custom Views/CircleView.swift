//
//  CircleView.swift
//  OverwatchCounters
//
//  Created by Markim Shaw on 6/21/17.
//  Copyright © 2017 Markim Shaw. All rights reserved.
//

import UIKit

@IBDesignable
class CircleView: UIView {
  
  @IBInspectable var color: UIColor = UIColor.clear {
    willSet {
      self.backgroundColor = newValue
    }
  }
  
  @IBInspectable var circleColor: UIColor = UIColor.white
  
  
  var shapeLayer: CAShapeLayer!
  
  
  // Only override draw() if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
  override func draw(_ rect: CGRect) {
    // Drawing code
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    setupCircle()
  }
  
  func setupCircle(){
    shapeLayer = CAShapeLayer()
    shapeLayer.path = UIBezierPath(ovalIn: self.bounds).cgPath
    shapeLayer.fillColor = circleColor.cgColor
    self.layer.addSublayer(shapeLayer)
    self.backgroundColor = UIColor.clear

  }
  
}
