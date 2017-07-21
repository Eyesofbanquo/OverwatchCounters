//
//  HeroDetailViewController.swift
//  OverwatchCounters
//
//  Created by Markim Shaw on 7/5/17.
//  Copyright © 2017 Markim Shaw. All rights reserved.
//

import UIKit
import Hero
import ChameleonFramework
import CoreData
import Kingfisher


func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
  return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
}

protocol StatusAnimator {
  var currentColor: UIColor! { get set }
  
  
}

extension StatusAnimator {
  var preferredStatusBarStyle: UIStatusBarStyle {
    if case UIColor.flatWhite = ContrastColorOf(currentColor, returnFlat: true) {
      return .lightContent
    } else {
      return .default
    }
  }
}

extension UINavigationController {
  override open var preferredStatusBarStyle: UIStatusBarStyle {
    return self.topViewController!.preferredStatusBarStyle
  }
}

class HeroDetailViewController: UIViewController, StatusAnimator {
  
  @IBOutlet weak var topContainerView: UIView!
  @IBOutlet weak var bottomContainerView: UIView!
  var strengthStackView: UIStackView!
  var strengthView: UIView!
  var weaknessStackView: UIStackView!
  var weaknessView: UIView!

  weak var hero: HeroMO?
  var heroImageView: UIImageView!
  var imageScale: CGFloat = 0.5
  var managedObjectContext: NSManagedObjectContext!
  var detailInformation: [String: [HeroMO]] = [:]
  var currentColor: UIColor! = .white
  
  weak var sharedImageCache: NSCache<NSString, NSData>?
  var sortedHeroes: [HeroMO]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.hidesNavigationBarHairline = true
    //self.navigationController?.heroNavigationAnimationType = .zoomOut
    ///self.view.heroID = self.hero!.name
    
    self.strengthStackView = bottomContainerView.subviews[0].subviews[0].subviews[1] as! UIStackView
    self.strengthView = bottomContainerView.subviews[0].subviews[0].subviews[0]
    self.strengthView.alpha = 0.0
    
    self.weaknessStackView = bottomContainerView.subviews[0].subviews[1].subviews[1] as! UIStackView
    self.weaknessView = bottomContainerView.subviews[0].subviews[1].subviews[0]
    self.weaknessView.alpha = 0.0
    
    
    Measure.run {
      initialization()
    }
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    

    self.strengthStackView.layoutIfNeeded()
    self.weaknessStackView.layoutIfNeeded()
    self.setCircleVisibility()
    
    for v in topContainerView.subviews {
      if v is UIImageView {
        heroImageView = v as! UIImageView
        Measure.run(description: "Loading images") {
          setHeroFeaturedImage()
        }
      }
    }
    
    Measure.run(description: "Setting up circle images") {
      self.setCircleImages()
    }
  }
  
  fileprivate func initialization() {
    guard let heroName = self.hero?.name,
          let heroColors = self.hero?.colors as? [UIColor]
    else { return }
    
    self.title = heroName
    self.topContainerView.backgroundColor = heroColors[0]
    self.topContainerView.clipsToBounds = true
    self.bottomContainerView.backgroundColor = heroColors[1]
    
    if let navbar = self.navigationController?.navigationBar {
      navbar.barTintColor = heroColors[0]
      navbar.titleTextAttributes = [NSForegroundColorAttributeName: ContrastColorOf(heroColors[0], returnFlat: true)]
      navbar.tintColor = ContrastColorOf(heroColors[0], returnFlat: true)
      self.currentColor = heroColors[0]
      self.navigationController?.setNeedsStatusBarAppearanceUpdate()
    }

    
    detailInformation["strengths"] = []
    detailInformation["weaknesses"] = []
    
    self.strengthView.backgroundColor = heroColors[1]
    (self.strengthView.subviews[0] as! UILabel).textColor = ContrastColorOf(self.strengthView.backgroundColor!, returnFlat: true)
    
    self.weaknessView.backgroundColor = heroColors[1]
    (self.weaknessView.subviews[0] as! UILabel).textColor = ContrastColorOf(self.weaknessView.backgroundColor!, returnFlat: true)
    
    UIView.animate(withDuration: 0.4, animations: {
      self.strengthView.alpha = 1.0
      self.weaknessView.alpha = 1.0
    })
    
    self.loadStrengthsWeaknesses()
  }
  
  /// Sets the image for the top view container
  fileprivate func setHeroFeaturedImage() {
    guard let hero = self.hero, let heroName = hero.name else { return }
    
    let fetchRequest = NSFetchRequest<HeroMO>(entityName: "Hero")
    let predicate = NSPredicate(format: "name == %@", heroName)
    fetchRequest.predicate = predicate
    
    if  let hero = self.hero, let heroName = hero.name, let url = URL(string: hero.image!){
      
      let resource = ImageResource(downloadURL: url, cacheKey: heroName)
      
      self.heroImageView.kf.setImage(with: resource, placeholder: nil, options: nil, progressBlock: nil, completionHandler: {
        image, error, cache, url in
        guard let image = image else { return }
        
        self.heroImageView.frame.size = CGSize(width: image.size.width, height: image.size.height) * self.imageScale
        self.heroImageView.center = self.topContainerView.center
        
        self.heroImageView.frame = self.heroImageView.frame.offsetBy(dx: 0.0, dy: self.heroImageView.frame.height / 4)
      })
      
      
    }
  }
  
  /// Load the weaknesses and strengths HeroMO objects from core data using the [String] in the HeroMO object
  func loadStrengthsWeaknesses() {

    let h = self.hero!
    
    if h.strengths == nil {
      self.detailInformation["strengths"] = []
    } else {
      let strengths = h.strengths as! [String]
      
      for s in strengths {
        let hero = self.sortedHeroes.filter({
          return $0.name == s
        })
        if let hero = hero.first {
          detailInformation["strengths"]?.append(hero)
        }
      }
    }
    
    if h.weaknesses == nil {
      self.detailInformation["weaknesses"] = []

    } else {
      let weaknesses = h.weaknesses as! [String]
      
      for w in weaknesses {
        let hero = self.sortedHeroes.filter {
          return $0.name == w
        }
        if let hero = hero.first {
          detailInformation["weaknesses"]?.append(hero)
        }
      }
    }
  }
  
  /// Overlay over the stackview that only displays if the strengths/weaknesses array is nil
  ///
  /// - Parameters:
  ///   - text: the text to display
  ///   - view: the stackview
  fileprivate func noItemsOverlay(with text: String, and color: UIColor, over view: UIView){
    /// Text label that will display 'there are no strengths/weaknesses'
    let label = UILabel()
    label.text = text
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .center
    label.adjustsFontSizeToFitWidth = true
    label.font = UIFont(name: "BigNoodleTitling", size: 12.0)
    label.textColor = ContrastColorOf(color, returnFlat: true)
    
    //add label to subview and use autolayout to place it
    view.addSubview(label)
    
    label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    
    
    
    view.layoutIfNeeded()
  }
  
  /// Set which circles in the stack view are visible
  fileprivate func setCircleVisibility() {
    let hero = self.hero!
    var strArray: [String]
    var weakArray: [String]
    
    //If the array doesn't exist then place a UIView in place of the stackview saying there aren't any items in this array
    if hero.strengths == nil {
      
      strArray = []
      
      let frameWithinStackView = self.strengthStackView.frame
      let convertedFrame = self.view.convert(frameWithinStackView, from: self.strengthStackView.superview!)
      let view = UIView(frame: convertedFrame)

      if let colors = hero.colors as? [UIColor] {
        view.backgroundColor = colors[2]
        noItemsOverlay(with: "Not strong against any heroes.", and: colors[2], over: view)
      }
      
      self.view.addSubview(view)
    } else {
      strArray = hero.strengths as! [String]
    }
    
    if hero.weaknesses == nil {
      weakArray = []
      let frameWithinStackView = self.weaknessStackView.frame
      let convertedFrame = self.view.convert(frameWithinStackView, from: self.weaknessStackView.superview!)
      let view = UIView(frame: convertedFrame)
      
      if let colors = hero.colors as? [UIColor] {
        view.backgroundColor = colors[2]
        noItemsOverlay(with: "Not weak against any heroes.", and: colors[2], over: view)
      }
      
      
      self.view.addSubview(view)
    } else {
      weakArray = hero.weaknesses as! [String]
    }
    
    if strArray.count < 3 {
      let endIndex = strArray.count
      _ = self.strengthStackView.arrangedSubviews[endIndex...2].map {
        $0.alpha = 0.0
      }
    }
    
    if weakArray.count < 3 {
      let endIndex = weakArray.count
      _ = self.weaknessStackView.arrangedSubviews[endIndex...2].map {
        $0.alpha = 0.0
      }
    }
  }
  
  fileprivate func setCircleImages() {
    
    guard let strengthArray = self.detailInformation["strengths"], let weaknessArray = self.detailInformation["weaknesses"] else { return } 
    
    if strengthArray.count > 0 {
      loadCircleImages(from: strengthArray, for: self.strengthStackView)
    }
    if weaknessArray.count > 0 {
      loadCircleImages(from: weaknessArray, for: self.weaknessStackView)
    }
  }
  
  func loadCircleImages(from array: [HeroMO], for stackView: UIStackView) {
    for (index, hero) in array.enumerated() {
      guard let name = hero.name,
            let position = hero.circlePosition,
            let colors = hero.colors as? [UIColor],
            let url = URL(string: array[index].image!)
      else { return }
      
      guard let circle = stackView.arrangedSubviews[index] as? HeroCircleView
      else { return }

      circle.heroLabel.text = name
      circle.heroLabel.textColor = colors[2]
      circle.backgroundColor = colors[0]
      
      //let heroURL = URL(string: array[index].image!)
      let resource = ImageResource(downloadURL: url, cacheKey: name)
      circle.imageView.kf.setImage(with: resource, placeholder: nil, options: nil, progressBlock: nil, completionHandler: {
        image, error, cache, url in
        guard let image = image else { return }
        circle.imageView.frame = CGRect(x: position.x, y: position.y, width: position.width, height: position.height)
        circle.animateLabel()
      })
    }
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    if case UIColor.flatWhite = ContrastColorOf(currentColor, returnFlat: true) {
      return .lightContent
    } else {
      return .default
    }
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}
