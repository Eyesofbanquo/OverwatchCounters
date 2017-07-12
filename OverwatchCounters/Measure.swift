//
//  Measure.swift
//  OverwatchCounters
//
//  Created by Markim Shaw on 7/11/17.
//  Copyright © 2017 Markim Shaw. All rights reserved.
//

import Foundation
import QuartzCore

final class Measure {
  public static func run(block: () -> ()) {
    let start = CACurrentMediaTime()
    block()
    let end = CACurrentMediaTime()
    let duration = end - start
    print(duration)
  }
  
  public static func run(description: String, block: () -> () ){
    let start = CACurrentMediaTime()
    block()
    let end = CACurrentMediaTime()
    let duration = end - start
    print("\(description) running time: \(duration)")
  }
}
