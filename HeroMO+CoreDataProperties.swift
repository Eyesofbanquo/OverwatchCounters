//
//  HeroMO+CoreDataProperties.swift
//  
//
//  Created by Markim Shaw on 7/17/17.
//
//

import Foundation
import CoreData


extension HeroMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HeroMO> {
        return NSFetchRequest<HeroMO>(entityName: "Hero")
    }

    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var strengths: NSArray?
    @NSManaged public var weaknesses: NSArray?
    @NSManaged public var colors: NSArray?
    @NSManaged public var circlePosition: Position?
    @NSManaged public var rowPosition: Position?

}
