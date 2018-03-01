'use strict';
const client_secret = 'sk_test_x9nLe8uLGzarVgMEUSuylguX'
const express = require('express');
var stripe = require('stripe')(client_secret);
var bodyParser = require('body-parser')
var request = require('request');
const path = require('path')
var app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: true
}));

const PORT = process.env.PORT || 5000

// The methods below are required by the Stripe iOS SDK
// See [STPEphemeralKeyProvider](https://github.com/stripe/stripe-ios/blob/master/Stripe/PublicHeaders/STPEphemeralKeyProvider.h)


app.post("/api/create_customer", (req, res) => {
    console.log("at /api/create_customer post")

    stripe.customers.create({
        email: req.body.email,
        description: req.body.description,
      }, function(err, customer) {
        console.log("Success! Created customer", customer.id)
        res.status(200).send({"customerId": customer.id})
      }).catch((err) => {
        console.log(err, req.body);
        res.status(500).end()
    });
});

/**
 * POST /api/ephemeral_keys
 *
 * Generate an ephemeral key for the logged in customer.
 */

app.post("/api/ephemeral_keys", (req, res) => {
    console.log("at /api/ephemeral_keys post")
    var customerId = req.body.customer_id;
    var api_version = req.body.api_version;

    console.log("customerId:", customerId)
    console.log("api_version:", api_version)

    stripe.ephemeralKeys.create(
        {customer : customerId},
        {stripe_version : api_version}
        ).then((key) => {
            console.log("Success!")
            res.status(200).send(key)
    }).catch((err) => {
        console.log(err, req.body);
        res.status(500).end()
    });
});

/**
 * POST /api/redeem_auth_code
 *
 * Return the curator's onboarded stripe id given 
 * the auth_code returned during onboarding
 */

app.post("/api/redeem_auth_code", (req, res) => {
    console.log("at /api/redeem_auth_code post")
    var auth_code = req.body.auth_code;

    var post_options = {
        host: 'https://connect.stripe.com',
        port: '80',
        path: '/oauth/token',
        url: 'URL:PORT/PATH',
        method: 'POST'
    };

    // Set up the request
    var post_req = request.post("https://connect.stripe.com/oauth/token",
        { json: { client_secret: client_secret,
                  grant_type: "authorization_code",
                  code: auth_code } },
        function(error, post_res, body) {

        // console.log("error", error)
        // console.log("body", body)

        let stripeUserId = body["stripe_user_id"]
        console.log("stripeUserId:", stripeUserId)

        // Return the resulting curator_id to the original caller
        res.status(200).send({"curator_id": stripeUserId});
    });

});

/**
 * POST /api/book
 *
 * Pay for the reservation
 */
app.post('/api/book', async (req, res, next) => {
    console.log("at /api/book post")
    // Important: For this demo, we're trusting the `amount` and `currency`
    // coming from the client request.
    // A real application should absolutely have the `amount` and `currency`
    // securely computed on the backend to make sure the user can't change
    // the payment amount from their web browser or client-side environment.
    const { source, amount, amountForCurator, currency, customerId, curatorId } = req.body;
  
    try {
      // For the purpose of this demo, let's assume we are automatically
      // matching with the first fully onboarded pilot rather than using their location.
    //   const pilot = await Pilot.getFirstOnboarded();
    //   // Find the latest passenger (see note above).
    //   const passenger = await Passenger.getLatest();
    //   // Create a new ride.
    //   const ride = new Ride({
    //     pilot: pilot.id,
    //     passenger: passenger.id,
    //     amount: amount,
    //     currency: currency
    //   });
    //   // Save the ride.
    //   await ride.save();
  
      // Create a charge and set its destination to the pilot's account.
      const charge = await stripe.charges.create({
        source: source,
        amount: amount,
        currency: currency,
        customer: customerId,
        description: "Tellomee",
        statement_descriptor: "Tellomee",
        destination: {
          // Send the amount for the pilot after collecting 20% platform fees.
          // Typically, the `amountForPilot` method simply computes `ride.amount * 0.8`.
          amount: amountForCurator,
          // The destination of this charge is the curator's Stripe account.
          account: curatorId
        }
      });
      // Add the Stripe charge reference to the ride and save it.
    //   ride.stripeChargeId = charge.id;
    //   ride.save();
  
      // Return the ride info.
      res.send({
        // pilot_name: pilot.displayName(),
        // pilot_vehicle: pilot.rocket.model,
        // pilot_license: pilot.rocket.license,
      });
    } catch (err) {
      res.sendStatus(500);
      next(`Error adding token to customer: ${err.message}`);
    }
  });

app.listen(PORT, () => console.log(`Listening on ${ PORT }`))
