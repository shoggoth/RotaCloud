//
//  NetCommsTests.swift
//  NetCommsTests
//
//  Created by Richard Henry on 17/02/2020.
//  Copyright © 2020 Dogstar Industries Ltd. All rights reserved.
//

import XCTest

@testable import NetComms

class RESTTests : XCTestCase {
    
    struct User : Codable {
        
        let id: Int
        let name: String
        let email: String
        let password: String
    }

    let baseUrl  = URL(string: "https://www.dogstar.mobi/api/t/");

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testReadUsers() {
        
        struct Result : Decodable {
            
            let message: String
            let data: [User]
        }
        
        let expectation = self.expectation(description: "testReadUsers")
        
        RESTSession().makeGETRequest(fromURL: URL(string: "users", relativeTo: baseUrl)) { (result: Result?, error: Error?) in
            
            XCTAssert(error == nil, "Error : \(String(describing: error?.localizedDescription))")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testReadUserByID() {
        
        struct Result : Decodable {
            
            let message: String
            let data: User
        }
        
        let expectation = self.expectation(description: "testReadUserByID")
        
        RESTSession().makeGETRequest(fromURL: URL(string: "user/1", relativeTo: baseUrl)) { (result: Result?, error: Error?) in
            
            XCTAssert(error == nil, "Error : \(String(describing: error?.localizedDescription))")

            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testAddUser() {
        
        XCTAssert(addUser() != nil, "testAddUser : addUser returned nil ID")
    }
    
    func testDeleteUser() {
        
        struct Result : Decodable {
            
            let message: String
            let changes: Int
        }
        
        guard let newID = addUser() else { XCTFail("testDeleteUser : addUser returned nil ID."); return }
        
        let expectation = self.expectation(description: "testDeleteUser")

        RESTSession().makeRequest(fromURL: URL(string: "user/\(newID)", relativeTo: baseUrl), withData: nil, withMethod: "DELETE") { (result: Result?, error: Error?) in
            
            XCTAssert(error == nil, "Error : \(String(describing: error?.localizedDescription))")
            XCTAssert((result?.changes ?? 0) > 0, "testDeleteUser : No changes.")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testChangeUser() {
        
        struct Result : Decodable {
            
            let message: String
            let data: User
            let changes: Int
        }
        
        guard let newID = addUser() else { XCTFail("testChangeUser : addUser returned nil ID."); return }
        
        let params = ["name" : self.randomName(), "email" : "testChangeUser\(randomString(length: 7))@dogstar.tests", "password" : "thisisasecretpassshhh"].formEncodedData

        let expectation = self.expectation(description: "testChangeUser")
        
        RESTSession().makeRequest(fromURL: URL(string: "user/\(newID)", relativeTo: baseUrl), withData: params, headers: ["Content-Type" : "application/x-www-form-urlencoded"], withMethod: "PATCH") { (result: Result?, error: Error?) in
            
            print("RESULT = \(String(describing: result))"); print("ERROR  = \(String(describing: error))")
            XCTAssert(error == nil, "Error : \(String(describing: error?.localizedDescription))")
            XCTAssert((result?.changes ?? 0) > 0, "testChangeUser : No changes.")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    private func addUser() -> Int? {
        
        struct Result : Decodable {
            
            let message: String
            let data: User
        }
        
        var newID: Int? = nil
        let params = ["name" : randomName(), "email" : "testAddUser\(randomString(length: 7))@dogstar.tests", "password" : "thisisasecretpassshhh"].formEncodedData!
        
        let expectation = self.expectation(description: "testAddUser")
        
        RESTSession().makePOSTRequest(fromURL: URL(string: "user", relativeTo: baseUrl), withData: params, headers: ["Content-Type" : "application/x-www-form-urlencoded"], withMethod: "POST") { (result: Result?, error: Error?) in
            
            XCTAssert(error == nil, "Error : \(String(describing: error?.localizedDescription))")
            
            newID = result?.data.id
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
        return newID
    }
    
    private func randomString(length: Int) -> String {

        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {

            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }

    private func randomName() -> String {

        let title = ["Mr.", "Mrs.", "Miss", "Dr.", "Reverend", "Sir"]

        let firstNameSyllableOne = ["Rich", "Ant", "St", "Jas", "Mart", "Bor", "Alfr", "Alb", "Barr", "Cam", "Ham", "T", "Br"]
        let firstNameSyllableTwo = ["ard", "ony", "er", "on", "in", "an", "is", "ed", "ert", "y", "ie", "eron", "ish", "ington"]

        //let surnamePrefix = ["Mc.", "O'", "Le"]
        let surNameSyllableOne = ["Bim", "Bum", "Chur", "Cum", "Fer", "Pup", "Ro", "Tram"]
        let surNameSyllableTwo = ["kin", "son", "ley", "lish", "ple", "mont"]
        //let surnamePostfix = ["Esq.", "Jr.'", "Le"]

        return ("\(title.randomElement()!) \(firstNameSyllableOne.randomElement()!)\(firstNameSyllableTwo.randomElement()!) \(surNameSyllableOne.randomElement()!)\(surNameSyllableTwo.randomElement()!)")
    }
}

private extension Dictionary where Key == String, Value == String {
    
    var formEncodedData: Data? {
        
        let percentEscapeString: (String) -> String = { string in
            
            let characterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._* ")
            
            return string.addingPercentEncoding(withAllowedCharacters: characterSet)!.replacingOccurrences(of: " ", with: "+", options: [], range: nil)
        }
        
        return self.map { "\(percentEscapeString($0.0))=\(percentEscapeString($0.1))" }.joined(separator: "&").data(using: .utf8)
    }
}
