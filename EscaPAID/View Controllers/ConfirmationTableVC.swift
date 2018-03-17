//
//  ConfirmationTableVC
//  EscaPAID
//
//  Created by Michael Miller on 2/2/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit
import Stripe

class ConfirmationTableVC: UITableViewController {
    
    var reservation: Reservation?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var providerButton: UIButton!
    @IBOutlet weak var numGuestsLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    
    let dateFormatter = DateFormatter()
    
    private let customerContext: STPCustomerContext
    private let paymentContext: STPPaymentContext
    
    required init?(coder aDecoder: NSCoder) {
        customerContext = STPCustomerContext(keyProvider: MainAPIClient.shared)
        paymentContext = STPPaymentContext(customerContext: customerContext)
        
        super.init(coder: aDecoder)
        
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = reservation?.experience.title
        
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateLabel.text = dateFormatter.string(from: (reservation?.date)!)
        
        timeLabel.text = reservation?.experience.startTime
        providerButton.setTitle(reservation?.experience.curator.displayName, for: UIControlState.normal)
        numGuestsLabel.text = String((reservation?.numGuests)!)
        
        // set the price for the Stripe charge
        price = reservation!.totalCharge
        
        totalLabel.text = formatAsCurrency(pennies: price)
        
        
        refreshPayButton()
    }
    
    private func formatAsCurrency(pennies: Int) -> String{
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = NumberFormatter.Style.currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale.current
        return currencyFormatter.string(from: NSNumber(value: Double(pennies) / 100.0))!
    }
    
    private func refreshPayButton() {
        if reservation?.stripeChargeId == nil {
            // The reservation hasn't been paid for yet
            payButton.setTitle("Pay", for: .normal)
        } else {
            // Already paid
            payButton.setTitle("Paid", for: .disabled)
            payButton.isEnabled = false
        }
    }
    
    // in pennies
    private var price = 0 {
        didSet {
            // Forward value to payment context
            paymentContext.paymentAmount = price
        }
    }
    
    func goToMessageThread() {
        
        let data = ["user" : (self.reservation?.experience.curator)!]
        
        // Send a broadcast notification to let the inbox know which thread to show
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ThreadsNavigationController.SHOW_THREAD_POST), object: data)
    }
    
    @IBAction func messageButton_click(_ sender: Any) {
        goToMessageThread()
    }
    
    @IBAction func payButton_click(_ sender: Any) {
        
        
        // Don't allow reserving own experience
        if (FirebaseManager.user?.uid == self.reservation?.experience.curator.uid) {
            let alertVC = UIAlertController(title: "Error", message: "You can't reserve your own experience.", preferredStyle: .alert)
            let alertActionOkay = UIAlertAction(title: "Okay", style: .default)
            alertVC.addAction(alertActionOkay)
            self.present(alertVC, animated: true, completion: nil)
            
            return
        }
        
        // Reserve the experience.
        ReservationProcessor.reserve(reservation!, completion: {
            
            // Perform payment request
            self.paymentContext.requestPayment()
        })
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ConfirmationTableVC : STPPaymentContextDelegate {

    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        if let customerKeyError = error as? MainAPIClient.CustomerKeyError {
            switch customerKeyError {
            case .missingBaseURL:
                // Fail silently until base url string is set
                print("[ERROR]: Please assign a value to `MainAPIClient.shared.baseURLString` before continuing. See `AppDelegate.swift`.")
            case .invalidResponse:
                // Use customer key specific error message
                print("[ERROR]: Missing or malformed response when attempting to `MainAPIClient.shared.createCustomerKey`. Please check internet connection and backend response formatting.");
                
                present(UIAlertController(message: "Could not retrieve customer information", retryHandler: { (action) in
                    // Retry payment context loading
                    paymentContext.retryLoading()
                }), animated: true)
            }
        }
        else {
            // Use generic error message
            print("[ERROR]: Unrecognized error while loading payment context: \(error)");
            
            present(UIAlertController(message: "Could not retrieve payment information", retryHandler: { (action) in
                // Retry payment context loading
                paymentContext.retryLoading()
            }), animated: true)
        }
    }

    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        // Reload related components
        print("paymentContextDidChange")
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        
        // Create charge using payment result
        let source = paymentResult.source.stripeID
        
        MainAPIClient.shared.bookReservation(source: source, reservation: reservation!) { [weak self] (error, stripeChargeId) in
            guard let strongSelf = self else {
                // View controller was deallocated
                return
            }
            
            guard error == nil else {
                // Error while requesting ride
                completion(error)
                return
            }
            
            // Set the stripe charge id on the reservation
            strongSelf.reservation?.stripeChargeId = stripeChargeId
            
            // Disable the pay button
            strongSelf.refreshPayButton()
            
            // Go to the message thread so the user can follow up
            strongSelf.goToMessageThread()
            
            completion(nil)
        }
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        switch status {
        case .success:
            // Animate active ride
            //animateActiveRide()
            print("success!")
        case .error:
            // Present error to user
            if let reservationError = error as? MainAPIClient.ReservationError {
                switch reservationError {
                case .missingBaseURL:
                    // Fail silently until base url string is set
                    print("[ERROR]: Please assign a value to `MainAPIClient.shared.baseURLString` before continuing. See `AppDelegate.swift`.")
                case .invalidResponse:
                    // Missing response from backend
                    print("[ERROR]: Missing or malformed response when attempting to `MainAPIClient.shared.bookReservation`. Please check internet connection and backend response formatting.");
                    present(UIAlertController(message: "Could not book reservation."), animated: true)
                }
            }
            else {
                // Use generic error message
                print("[ERROR]: Unrecognized error while finishing payment: \(String(describing: error))");
                present(UIAlertController(message: "Could not book reservation"), animated: true)
            }
            
            // Reset ride request state
//            rideRequestState = .none
        case .userCancellation:
            // Reset ride request state
//            rideRequestState = .none
            print("user cancelled")
        }
    }
}
