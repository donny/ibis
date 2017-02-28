/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import KituraNet
import SwiftyJSON
import Foundation

public enum Method: String {
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

public class RestRequest {
    
    private let method: Method
    private let url: String
    private let acceptType: String?
    private let contentType: String?
    private let queryParameters: [URLQueryItem]?
    private let headerParameters: [String: String]?
    private let messageBody: Data?
    private let username: String?
    private let password: String?
    private let domain = "com.ibm.swift.rest-kit"
    
    public func response(callback: @escaping ClientRequest.Callback) {
        
        // construct url with query parameters
        var urlComponents = URLComponents(string: self.url)!
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            urlComponents.queryItems = queryParameters
        }
        
        // construct headers
        var headers = [String: String]()
        
        // set the request's accept type
        if let acceptType = acceptType {
            headers["Accept"] = acceptType
        }
        
        // set the request's content type
        if let contentType = contentType {
            headers["Content-Type"] = contentType
        }
        
        // set the request's header parameters
        if let headerParameters = headerParameters {
            for (key, value) in headerParameters {
                headers[key] = value
            }
        }
        
        // verify required url components
        guard let scheme = urlComponents.scheme else {
            print("Cannot execute request. Please add a scheme to the url (e.g. \"http://\").")
            return
        }
        guard let hostname = urlComponents.percentEncodedHost else {
            print("Cannot execute request. Please add a hostname to the url (e.g. \"www.ibm.com\").")
            return
        }
        let path = urlComponents.percentEncodedPath
     
        
        // construct client request options
        var options: [ClientRequest.Options] = []
        options.append(.method(method.rawValue))
        options.append(.headers(headers))
        options.append(.schema(scheme + "://"))
        options.append(.hostname(hostname))
        if let query = urlComponents.percentEncodedQuery {
            options.append(.path(path + "?" + query))
        } else {
            options.append(.path(path))
        }
        if let username = username {
            options.append(.username(username))
        }
        if let password = password {
            options.append(.password(password))
        }
        
        // construct and execute HTTP request
        let req = HTTP.request(options, callback: callback)
        
        if let messageBody = messageBody {
            req.write(from: messageBody)
        }
        
        req.end()
    }
    
    public func responseJSON(callback: @escaping (Result<JSON>) -> Void) {
        
        self.response { r in
            guard let response = r, response.statusCode == HTTPStatusCode.OK else {
                let failureReason = "Response status code was unacceptable: \(r!.statusCode.rawValue)."
                let error = RestError.badResponse(failureReason)
                callback(.failure(error))
                return
            }
            
            do {
                var body = Data()
                try response.readAllData(into: &body)
                let json = JSON(data: body as Data)
                callback(.success(json))
            } catch {
                let failureReason = "Could not parse response data."
                let error = RestError.badData(failureReason)
                callback(.failure(error))
                return
            }
        }
    }
    
    public init(
        method: Method,
        url: String,
        acceptType: String? = nil,
        contentType: String? = nil,
        queryParameters: [URLQueryItem]? = nil,
        headerParameters: [String: String]? = nil,
        messageBody: Data? = nil,
        username: String? = nil,
        password: String? = nil)
    {
        self.method = method
        self.url = url
        self.acceptType = acceptType
        self.contentType = contentType
        self.queryParameters = queryParameters
        self.headerParameters = headerParameters
        self.messageBody = messageBody
        self.username = username
        self.password = password
    }
}
