//
//  RESTSession.swift
//  NetComms
//
//  Created by Richard Henry on 17/02/2020.
//  Copyright © 2020 Dogstar Industries Ltd. All rights reserved.
//

import Foundation

public class RESTSession {

    private let session: URLSession
    private let errorDomain: String

    // MARK: Lifecycle
    
    public init(session: URLSession = URLSession(configuration: .default), errorDomain: String = "mobi.dogstar.NETComms.RESTSession") {
        
        // Dependency injection with defaults.
        self.session = session
        self.errorDomain = errorDomain
    }
    
    deinit { cancelAllTasks() }
    
    // MARK: Commands
    
    public func cancelAllTasks() {
        
        session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            
            for task in dataTasks { task.cancel() }
            for task in uploadTasks { task.cancel() }
            for task in downloadTasks { task.cancel() }
        }
    }
    
    // MARK: Requests

    public func makeRequest<T : Decodable>(fromURL url: URL?, withData data: Data?, headers: [String : String?]? = nil, withMethod method: String?, completion:((T?, Error?) -> Void)? = nil) {
        
        // Make sure we can construct a valid URL
        guard let url = url else { completion?(nil, NSError(domain: self.errorDomain, code: 404, userInfo: nil)); return }
        
        // Create the request
        var request = URLRequest(url: url)
        
        // Make it a POST request with the specified parameters
        request.httpMethod = method
        request.httpBody = data
        
        // Put in the headers
        for (key, value) in headers ?? [:] { request.setValue(value, forHTTPHeaderField: key) }
        
        // Start the session
        session.dataTask(with: request, completionHandler: { data, response, error in
            
            // Check error condition
            if let error = error { completion?(nil, error) }
                
            else {
                // Check for nil data (204 No Content)
                guard let data = data else { completion?(nil, NSError(domain: self.errorDomain, code: 204, userInfo: nil)); return }

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(.spaceXDate)
                
                // And that data decoded alright
                if let decodedData = try? decoder.decode(T.self, from: data) { completion?(decodedData, nil) }
                    
                else {
                    // Report unexpected error response (400 Bad Request default)
                    completion?(nil, NSError(domain: self.errorDomain, code: (response as? HTTPURLResponse)?.statusCode ?? 400, userInfo: ["data" : String(data: data, encoding: .utf8) ?? "No data", "resp" : String(describing: response)]))
                }
            }
        }).resume()
    }

    // MARK: Convenience methods
    
    public func makeGETRequest<T : Decodable>(fromURL url: URL?, headers: [String : String?]? = nil, completion: ((T?, Error?) -> Void)? = nil) {
        
        makeRequest(fromURL: url, withData: nil, headers: headers, withMethod: nil, completion: completion)
    }
    
    public func makePOSTRequest<T : Decodable>(fromURL url: URL?, withData data: Data, headers: [String : String?]? = nil, withMethod method: String = "POST", completion:((T?, Error?) -> Void)? = nil) {
        
        makeRequest(fromURL: url, withData: data, headers: headers, withMethod: method, completion: completion)
    }
    
    public func makePOSTRequest<T : Decodable, U : Encodable>(fromURL url: URL?, withParams params: U, headers: [String : String?]? = nil, withMethod method: String = "POST", completion:((T?, Error?) -> Void)? = nil) {

        // Encode to JSON
        guard let jsonData = try? JSONEncoder().encode(params) else { completion?(nil, NSError(domain: self.errorDomain, code: 204, userInfo: nil)); return }
        
        // Add JSON Headers
        var jsonHeaders = headers ?? [:]
        
        jsonHeaders["Content-Type"] = "application/json; charset=utf-8"  // the request is JSON
        jsonHeaders["Accept"] = "application/json; charset=utf-8"        // the expected response is also JSON

        self.makePOSTRequest(fromURL: url, withData: jsonData, headers: jsonHeaders, withMethod: method, completion: completion)
    }
}

private extension DateFormatter {
    
    static let spaceXDate: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return formatter
    }()
}
