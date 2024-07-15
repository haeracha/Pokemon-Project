//
//  Contact+CoreDataProperties.swift
//  Pokemon
//
//  Created by t2023-m0019 on 7/16/24.
//
//

import Foundation
import CoreData


extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var name: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var profileImage: Data?

}

extension Contact : Identifiable {

}
