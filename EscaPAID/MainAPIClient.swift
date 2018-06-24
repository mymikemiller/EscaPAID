//
//  MainAPIClient.swift
//  EscaPAID
//
//  Created by Michael Miller on 2/25/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import Alamofire
import Stripe

class MainAPIClient: NSObject {
    
    static let shared = MainAPIClient()
    
    //var baseURLString = "http://localhost:6000/api" + (Config.stage == "production" ? "" : "-test")
    var baseURLString = Config.current.serverURL + (Config.stage == "production" ? "" : "-test") // Append -test if we're not on production
    var baseURL: URL {
        return URL(string: baseURLString)!
    }
    
    enum ReservationError: Error {
        case missingBaseURL
        case invalidResponse
        case failure
    }
    
    func bookReservation(source: String, reservation: Reservation, completion: @escaping (ReservationError?, String?) -> Void) {
        print("in bookReservation")
        let url = self.baseURL.appendingPathComponent("book")
        
        let parameters: [String: Any] = [
            "source": source,
            "reservationId": reservation.id!
            ]
                
        Alamofire.request(url, method: .post, parameters: parameters).validate(statusCode: 200..<300).responseJSON { (response) in
            
            switch response.result {
            case .success(let data as [String:Any]):
                
                guard let json = response.result.value as? [String: Any] else {
                    print("Got invalid response from bookReservation")
                    completion(.invalidResponse, nil)
                    return
                }
                
                let stripeChargeId = json["stripeChargeId"] as! String
                
                completion(nil, stripeChargeId)
            
            case .failure(let err):
                print(err.localizedDescription)
                completion(ReservationError.failure, nil)
            default:
                completion(ReservationError.failure, nil)
            }
            
        }
    }
    
    func createCustomer(email:String, description:String, completion: @escaping (String?) -> Void) {
        print("at createCustomer")
        let url = self.baseURL.appendingPathComponent("create_customer")
        let parameters: [String: Any] = [
            "email": email,
            "description": description,
            ]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
            
            guard let json = response.result.value as? [String: Any] else {
                // TODO: Should not error out here. Should just call the completion without ever adding a stripeCustomerId. stripeCustomerId can be added once we try to create a charge.
                fatalError("Failure creating stripe customer. Check that the server is running at " + url.absoluteString)
                completion(nil)
            }
            
            // Send the returned customer id to the completion
            let customerId = json["customerId"] as! String
            completion(customerId)
        }
        
    }
    
    func redeemOnboardingAuthorizationCode(authCode:String, completion: @escaping (String?) -> Void) {
        
        print("at redeemOnboardingAuthorizationCode")
        
        let url = self.baseURL.appendingPathComponent("redeem_auth_code")
        let parameters: [String: Any] = [
            "auth_code": authCode
            ]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse) in

            guard let json = response.result.value as? [String: Any] else {
                // TODO: Should not error out here. Should just call the completion without ever adding a stripeCustomerId. stripeCustomerId can be added once we try to create a charge.
                fatalError("Failure redeeming onboarding authorization code. Check that the server is running at " + url.absoluteString)
                completion(nil)
            }
            
            if (!json.keys.contains("curator_id")) {
                fatalError("Failure redeeming onboarding authorization code from " + url.absoluteString + ". The response did not contain curator_id.")
                completion(nil)
            }

            // Send the returned curator id to the completion
            let curatorId = json["curator_id"] as! String
            completion(curatorId)
        }
        
    }
}
    
// MARK: STPEphemeralKeyProvider
extension MainAPIClient : STPEphemeralKeyProvider {
    
    enum CustomerKeyError: Error {
        case missingBaseURL
        case invalidResponse
    }
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        print("at createCustomerKey")
        let url = self.baseURL.appendingPathComponent("ephemeral_keys")
        Alamofire.request(url, method: .post, parameters: [
            "api_version": apiVersion,
            "customer_id": (FirebaseManager.user?.stripeCustomerId)!
            ])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    completion(json as? [String: AnyObject], nil)
                case .failure(let error):
                    completion(nil, error)
            }
        }
    }
}

