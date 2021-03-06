//
//  HeroCircleView.swift
//  OverwatchCounters
//
//  Created by Markim Shaw on 7/10/17.
//  Copyright © 2017 Markim Shaw. All rights reserved.
//

import UIKit

@IBDesignable
class HeroCircleView: UIView {
  
  
  @IBInspectable var color: UIColor = UIColor.white {
    willSet {
      self.backgroundColor = newValue
    }
  }
  
  @IBInspectable var layerOpacity: Float = 1.0 {
    willSet {
      if let circle = circleLayer {
        circle.backgroundColor = UIColor.green.cgColor
      }
    }
  }
  
  @IBInspectable var imageViewColor: UIColor = UIColor.green {
    willSet {
      if let image = imageView {
        image.backgroundColor = newValue
      }
    }
  }
  var circleLayer: CAShapeLayer!
  var circleLayerPadding: CGFloat = 2.0
  var viewForImageView: UIView!
  var imageView: UIImageView!
  var heroLabel: UILabel!
  var heroLabelBackgroundView: UIView!
  
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
  }
  
  /// This function will display visible changes to the IBInspectable properties in the storyboard
  override func layoutSubviews() {
    super.layoutSubviews()
    //self.viewForImageView.frame = bounds
    //self.imageView.frame = bounds
    if viewForImageView == nil || imageView == nil {
      createImageView()
      createHeroLabel()
    }

  }
  
  func createHeroLabel() {
    self.heroLabel = UILabel()
    self.heroLabel.translatesAutoresizingMaskIntoConstraints = false
    
    //black transparent view
    self.heroLabelBackgroundView = UIView()
    self.heroLabelBackgroundView.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(self.heroLabelBackgroundView)

    self.heroLabelBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    self.heroLabelBackgroundView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
    self.heroLabelBackgroundView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    self.heroLabelBackgroundView.heightAnchor.constraint(equalToConstant: self.bounds.height * 0.30).isActive = true
    self.heroLabelBackgroundView.backgroundColor = .black
    self.heroLabelBackgroundView.alpha = 0.0
    //view.
    
    //view.addSubview(heroLabel)
    self.insertSubview(heroLabel, aboveSubview: self.heroLabelBackgroundView)
    self.heroLabel.textAlignment = .center
    self.heroLabel.adjustsFontSizeToFitWidth = true
    
    heroLabel.bottomAnchor.constraint(equalTo:  self.bottomAnchor).isActive = true
    heroLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    //heroLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
    //heroLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    
    heroLabel.font = UIFont(name: "BigNoodleTitling", size: 24.0)
    heroLabel.alpha = 0.0
  }
  
  func animateLabel() {
    UIView.animate(withDuration: 0.4, animations: {
      self.heroLabel.alpha = 1.0
      self.heroLabelBackgroundView.alpha = 0.3
    })
  }
  
  func createImageView() {
    self.clipsToBounds = true
    self.viewForImageView = UIView(frame: bounds)
    self.imageView = UIImageView(frame: bounds)
    self.viewForImageView.addSubview(self.imageView)
    self.viewForImageView.clipsToBounds = true
    self.imageView.clipsToBounds = true
    self.addSubview(self.viewForImageView)
  }
  
  /// Create a square frame from any rectangular bound
  ///
  /// - Returns: The CGRect of the square frame
  fileprivate func createSquareFromRect() -> CGRect {
    let rect = bounds
    let xPos = rect.width / 2
    let yPos = rect.height / 2
    let squareSide = min(rect.width - (2.0 * circleLayerPadding), rect.height - (2.0 * circleLayerPadding))
    let squareFrame = CGRect(x: xPos - squareSide / 2, y: yPos - squareSide / 2, width: squareSide, height: squareSide)
    
    return squareFrame
  }
  
  fileprivate func createCircleMask() {
    circleLayer = CAShapeLayer()
    circleLayer.path = UIBezierPath(ovalIn: createSquareFromRect()).cgPath
    circleLayer.opacity = layerOpacity
    circleLayer.fillColor = UIColor.black.cgColor
    circleLayer.strokeColor = UIColor.black.cgColor
    circleLayer.lineWidth = 0.0
    //self.viewForImageView.layer.mask = circleLayer
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.backgroundColor = .clear
  }

}
