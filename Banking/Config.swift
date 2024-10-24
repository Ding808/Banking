//
//  Config.swift
//  Banking
//
//  Created by Yueyang Ding on 2024-10-24.
//


import Foundation

class Config {
    static let shared = Config()

    private var apiKeys: [String: String]?

    private init() {
        loadAPIKeys()
    }

    private func loadAPIKeys() {
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path) {
            apiKeys = (try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil)) as? [String: String]
        }
    }

    func getAPIKey(for key: String) -> String? {
        return apiKeys?[key]
    }
}
