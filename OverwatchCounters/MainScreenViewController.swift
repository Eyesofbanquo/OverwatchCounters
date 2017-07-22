//
//  MainScreenViewController.swift
//  OverwatchCounters
//
//  Created by Markim Shaw on 7/3/17.
//  Copyright © 2017 Markim Shaw. All rights reserved.
//

import UIKit
import Hero
import ChameleonFramework
import CoreData
import Kingfisher

class MainScreenViewController: UIViewController, StatusAnimator {
  
  @IBOutlet weak var tableView: UITableView!
  var fetchController: NSFetchedResultsController<HeroMO>!
  var imageCache: NSCache<NSString, UIImage>!
  var previousIndexPath: IndexPath!
  
  var heroes: [HeroMO]?
  var sortedHeroes: [HeroMO]!
  var loadingNextView: Bool = false
  var currentColor: UIColor! = .white
  
  let refreshControl: UIRefreshControl = UIRefreshControl()
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.refreshControl = refreshControl
    self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
    
    self.setStatusBarStyle(UIStatusBarStyleContrast)
    
    self.navigationController?.hidesNavigationBarHairline = true
    self.navigationController?.isHeroEnabled = true
    self.navigationController?.heroNavigationAnimationType = .fade
    
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.separatorStyle = .none
    
    self.sortedHeroes = self.heroes!.sorted(by: {
      return $0.0.name! < $0.1.name!
    })
    self.currentColor = .white
    
  }
  
  func refresh(_ sender: AnyObject) {
    
    
    self.refreshControl.endRefreshing()
  }
  
  fileprivate func initializeFetchController() {
    let fetchRequest = NSFetchRequest<HeroMO>(entityName: "Hero")
    let ascending = NSSortDescriptor(key: "name", ascending: true)
    fetchRequest.sortDescriptors = [ascending]
    
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    self.fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    self.fetchController.delegate = self
    do {
      
      try self.fetchController.performFetch()
    } catch {
      
    }
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let heroCell = sender as? HeroTableViewCell, let indexPath = self.tableView.indexPath(for: heroCell) {
      let heroObject = sortedHeroes[indexPath.row]
      let destination = segue.destination as! HeroDetailViewController
      destination.hero = heroObject
      destination.isHeroEnabled = true
      destination.sortedHeroes = self.sortedHeroes
    }
  }
  
  @IBAction func unwindSegue(segue: UIStoryboardSegue) {
    self.loadingNextView = false
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    if case UIColor.flatWhite = ContrastColorOf(currentColor, returnFlat: true) {
      return .lightContent
    } else {
      return .default
    }
  }
  
}

extension MainScreenViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 90.0
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath) as! HeroTableViewCell
    let hero = self.sortedHeroes[indexPath.row]
    //cell.heroID = hero.name
   // cell.heroModifiers = [.fade, .useNormalSnapshot]
    let colors = hero.colors as! [UIColor]
    tableView.deselectRow(at: indexPath, animated: false)
    self.loadingNextView = true
    
  }
}

extension MainScreenViewController: NSFetchedResultsControllerDelegate {
  
}

extension MainScreenViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let heroCell = tableView.dequeueReusableCell(withIdentifier: "hero_cell", for: indexPath) as! HeroTableViewCell
    
    let hero = sortedHeroes[indexPath.row]
    
    let colors = hero.colors as! [UIColor]
    
    heroCell.prepareForReuse()
    heroCell.name.text = hero.name ?? "no name"
    heroCell.backgroundColor = colors[0]
    
    guard let imageString = hero.image,
          let url = URL(string: imageString),
          let heroName = hero.name
      else { return UITableViewCell() }
    
    let resource = ImageResource(downloadURL: url, cacheKey: heroName)
    //heroCell.heroImage.kf.indicatorType = .activity
    heroCell.heroImage.kf.setImage(with: resource)
    
    guard let x = hero.rowPosition?.x, let y = hero.rowPosition?.y, let width = hero.rowPosition?.width, let height = hero.rowPosition?.height else { return  UITableViewCell() }
    heroCell.heroImage.frame = CGRect(x: x, y: y, width: width, height: height)
    heroCell.name.textColor = .white
    
    heroCell.selectionStyle = .none

    return heroCell
  }
  
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath) as! HeroTableViewCell
    cell.heroImage.kf.cancelDownloadTask()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.heroes!.count
  }

}

extension MainScreenViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if self.loadingNextView {
      return
    }
    guard let indexPath = self.tableView.indexPathForRow(at: scrollView.contentOffset)
      else { return }
    if self.previousIndexPath == nil {
      self.previousIndexPath = indexPath
      let cell = self.sortedHeroes[indexPath.row]
      let colors = cell.colors as! [UIColor]
      self.navigationController?.navigationBar.barTintColor = colors[2]
      currentColor = colors[2]
      self.view.backgroundColor = currentColor
      self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: ContrastColorOf(colors[2], returnFlat: true)]
      self.navigationController?.setNeedsStatusBarAppearanceUpdate()

    }
    
    if self.previousIndexPath.item == indexPath.item {
      return
    } else {
      self.previousIndexPath = indexPath
      let cell = self.sortedHeroes[indexPath.row]
      let colors = cell.colors as! [UIColor]
      currentColor = colors[2]
      self.view.backgroundColor = currentColor
      self.navigationController?.navigationBar.barTintColor = colors[2]
      self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: ContrastColorOf(colors[2], returnFlat: true)]
      self.navigationController?.setNeedsStatusBarAppearanceUpdate()
    }
  }
}
