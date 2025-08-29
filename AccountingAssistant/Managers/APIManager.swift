//
//  APIManager.swift
//  AccountingAssistant
//
//  Created by mathwallet on 2025/8/26.
//
import Foundation
import Alamofire

enum APIError: LocalizedError, Equatable {
    case server(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .server(let string):
            return string
        case .unknown:
            return "Unknown error"
        }
    }
}

struct APIResp<T: Decodable>: Decodable {
    var success: Bool
    var output: T?
    
    enum CodingKeys: String, CodingKey {
        case success
        case output
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try container.decode(Bool.self, forKey: .success)
        self.output = try container.decodeIfPresent(T.self, forKey: .output)
    }
}

class APIManager {
    static let `defalut` = APIManager(baseURL: URL(string: "https://www.sim.ai")!)
    private let baseURL: URL
    
    private init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    func reqData(url: URL, method: HTTPMethod, parameters: Parameters? = nil, encoding: any ParameterEncoding = JSONEncoding.default, headers: HTTPHeaders? = nil) async throws -> Data {
        let result = await AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).serializingData().result
        debugPrint(">>>>>>>>>>>>>>>>Request")
        debugPrint("\(method.rawValue) \(url)")
        debugPrint("Parameters: ", parameters ?? [:])
        debugPrint("Headers: ", headers ?? [:])
        switch result {
        case .success(let data):
            debugPrint("Response->")
            debugPrint(String(data: data, encoding: .utf8) ?? "")
            return data
        case .failure(let error):
            debugPrint("Error->")
            debugPrint(error)
            throw APIError.server(error.localizedDescription)
        }
    }
    
    private func req<T: Decodable>(url: URL, method: HTTPMethod, parameters: Parameters? = nil, encoding: any ParameterEncoding = JSONEncoding.default, headers: HTTPHeaders? = nil) async throws -> T {
        let data = try await self.reqData(url: url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let resp = try decoder.decode(APIResp<T>.self, from: data)
        if resp.success, resp.output != nil {
            return resp.output!
        } else {
            throw APIError.server("Unknown error")
        }
    }
    
    private func reqNil(url: URL, method: HTTPMethod, parameters: Parameters? = nil, encoding: any ParameterEncoding = JSONEncoding.default, headers: HTTPHeaders? = nil) async throws {
        let data = try await self.reqData(url: url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        let resp = try JSONDecoder().decode(APIResp<String?>.self, from: data)
        if resp.success {
            return
        } else {
            throw APIError.server("Unknown error")
        }
    }
}

extension APIManager {
    func getAccountingsFromText(_ text: String) async throws -> AccountingsResp {
        let parameters: Parameters = [
            "message": text
        ]
        let headers: HTTPHeaders = [
            "X-API-Key": "sim_Sa88tg_oUNpWJwpNJISzhO8-Hf55hydp"
        ]
        return try await self.req(
            url: baseURL.appending(path: "/api/workflows/c0ea9c1a-6f23-4387-ba9c-005bfcb92e67/execute"),
            method: .post,
            parameters: parameters,
            headers: headers
        )
    }
}
