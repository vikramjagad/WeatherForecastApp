//
//  CoreDataManager.swift
//  WeatherForecastApp
//
//  Created by Vikram Jagad on 07/06/24.
//

import UIKit
import CoreData

enum DecoderConfigurationError: Error {
    case missingManagedObjectContext
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}

/// CoreDataManager class is used for data operations on CoreData.
final class CoreDataManager: NSObject {
    // MARK: - Properties
    // MARK: Private
    private let logTag = "CoreDataManager"
    // MARK: Public
    static let shared = CoreDataManager()
    /// Persistent container: CoreData stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WeatherForecastApp")
        container.loadPersistentStores(completionHandler: { [unowned self] (storeDescription, error) in
            if let error = error as NSError? {
                LogManager.shared.log(.fatal, tag: logTag, message: "Unresolved error %@, \(error.userInfo)",
                                      args: error.localizedDescription)
            } else {
                LogManager.shared.log(.debug, tag: logTag, message: "Message: type: %@, configuration: %@",
                                      args: storeDescription.type, storeDescription.configuration ?? "No Description")
            }
        })
        return container
    }()

    // MARK: - Initializer
    private override init() {}

    // MARK: - Methods
    // MARK: Public
    /// CoreData Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                LogManager.shared.log(.fatal, tag: logTag, message: "Unresolved error: %@", args: nserror.description)
            }
        }
    }
}
