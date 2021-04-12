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

    // MARK: Lifecycle
    
    public init(session: URLSession = URLSession(configuration: .default)) {
        
        // Dependency injection with defaults.
        self.session = session
    }

    // MARK: Commands
    
    public func cancelAllTasks() {
        
        session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            
            for task in dataTasks { task.cancel() }
            for task in uploadTasks { task.cancel() }
            for task in downloadTasks { task.cancel() }
        }
    }
    
    // MARK: Errors

    public enum RequestError : Error {
        
        case badURLError
        case noDataError
        case decodingError
        case clientError(Error)     // Error from URLSession
        case serverError(Int)       // Error from HTTP server
    }
    
    // MARK: REST methods

    public func sendRequest<T : Decodable>(_ request: URLRequest, decoder: JSONDecoder = .init(), completion: ((Result<T, RequestError>) -> Void)? = nil) {
        
        // Start the session
        session.dataTask(with: request, completionHandler: { data, resp, error in

            // Check client side error condition
            if let error = error { completion?(.failure(.clientError(error))); return }
            // Check server side status code
            if let status = (resp as? HTTPURLResponse)?.statusCode, status != 200 { completion?(.failure(.serverError(status))); return }
            // Check for nil data
            guard let data = data else { completion?(.failure(.noDataError)); return }
            
            // Check that data decoded alright.
            if let decodedData = try? decoder.decode(T.self, from: data) { completion?(.success(decodedData)) } else { completion?(.failure(.decodingError)) }
            
        }).resume()
    }

    public func sendRequest<T : Decodable>(fromURL url: URL?,
                                           data: Data? = nil,
                                           headers: [String : String?]? = nil,
                                           method: String? = nil,
                                           decoder: JSONDecoder = .init(),
                                           completion: ((Result<T, RequestError>) -> Void)? = nil)
    {
        
        guard let url = url else { completion?(.failure(.badURLError)); return }

        // Set up the URLRequest with the specified parameters.
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = data
        
        // Put in the headers
        headers?.forEach { key, value in request.setValue(value, forHTTPHeaderField: key) }
        
        sendRequest(request, decoder: decoder, completion: completion)
    }
    
    // MARK: Convenience methods

    public func sendGETRequest<T : Decodable>(fromURL url: URL?, headers: [String : String?]? = nil, completion: ((Result<T, RequestError>) -> Void)? = nil) {
        
        sendRequest(fromURL: url, data: nil, headers: headers, method: nil, completion: completion)
    }
    
    public func sendPOSTRequest<T : Decodable>(fromURL url: URL?, data: Data, headers: [String : String?]? = nil, method: String = "POST", completion:((Result<T, RequestError>) -> Void)? = nil) {
        
        sendRequest(fromURL: url, data: data, headers: headers, method: method, completion: completion)
    }
    
    public func sendPOSTRequest<T : Decodable, U : Encodable>(fromURL url: URL?,
                                                              withParams params: U,
                                                              headers: [String : String?]? = nil,
                                                              withMethod method: String = "POST",
                                                              encoder: JSONEncoder = .init(), completion:((Result<T, RequestError>) -> Void)? = nil)
    {

        // Encode to JSON
        guard let jsonData = try? encoder.encode(params) else { completion?(.failure(.decodingError)); return }
        
        // Add JSON Headers
        var jsonHeaders = headers ?? [:]
        
        jsonHeaders["Content-Type"] = "application/json; charset=utf-8"  // the request is JSON
        jsonHeaders["Accept"] = "application/json; charset=utf-8"        // the expected response is also JSON

        self.sendPOSTRequest(fromURL: url, data: jsonData, headers: jsonHeaders, method: method, completion: completion)
    }
}
