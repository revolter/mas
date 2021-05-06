//
//  StoreSearch.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation

/// Protocol for searching the MAS catalog.
protocol StoreSearch {
    func lookup(app appId: Int, _ completion: @escaping (SearchResult?, Error?) -> Void)
    func search(for appName: String, _ completion: @escaping ([SearchResult]?, Error?) -> Void)
}

// MARK: - Common methods
extension StoreSearch {
    /// Looks up app details.
    ///
    /// - Parameter appId: MAS ID of app
    /// - Returns: Search result record of app or nil if no apps match the ID.
    /// - Throws: Error if there is a problem with the network request.
    func lookup(app appId: Int) throws -> SearchResult? {
        var result: SearchResult?
        var error: Error?

        let group = DispatchGroup()
        group.enter()
        lookup(app: appId) {
            result = $0
            error = $1
            group.leave()
        }

        group.wait()

        if let error = error {
            throw error
        }

        return result
    }

    /// Searches for an app.
    ///
    /// - Parameter appName: MAS ID of app
    /// - Returns: Search results. Empty if there were no matches.
    /// - Throws: Error if there is a problem with the network request.
    func search(for appName: String) throws -> [SearchResult] {
        var results: [SearchResult]?
        var error: Error?

        let group = DispatchGroup()
        group.enter()
        search(for: appName) {
            results = $0
            error = $1
            group.leave()
        }

        group.wait()

        if let error = error {
            throw error
        }

        return results!
    }

    /// Builds the search URL for an app.
    ///
    /// - Parameter appName: MAS app identifier.
    /// - Returns: URL for the search service or nil if appName can't be encoded.
    func searchURL(for appName: String) -> URL? {
        guard let urlString = searchURLString(forApp: appName) else { return nil }
        return URL(string: urlString)
    }

    /// Builds the search URL for an app.
    ///
    /// - Parameter appName: Name of app to find.
    /// - Returns: String URL for the search service or nil if appName can't be encoded.
    func searchURLString(forApp appName: String) -> String? {
        if let urlEncodedAppName = appName.urlEncodedString {
            return "https://itunes.apple.com/search?media=software&entity=macSoftware&term=\(urlEncodedAppName)"
        }
        return nil
    }

    /// Builds the lookup URL for an app.
    ///
    /// - Parameter appId: MAS app identifier.
    /// - Returns: URL for the lookup service or nil if appId can't be encoded.
    func lookupURL(forApp appId: Int) -> URL? {
        guard let urlString = lookupURLString(forApp: appId) else { return nil }
        return URL(string: urlString)
    }

    /// Builds the lookup URL for an app.
    ///
    /// - Parameter appId: MAS app identifier.
    /// - Returns: String URL for the lookup service.
    func lookupURLString(forApp appId: Int) -> String? {
        "https://itunes.apple.com/lookup?id=\(appId)"
    }
}