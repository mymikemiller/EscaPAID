'use strict';
var argv = require('minimist')(process.argv.slice(2));

const PORT = process.env.PORT || 5000
// The service account file path should not be set on heroku. The file should only exist locally. See below.
const SERVICE_ACCOUNT_FILE_PATH = argv["firebase-adminsdk-path"] || "";
const client_secret = 'sk_test_x9nLe8uLGzarVgMEUSuylguX'
const express = require('express');
var stripe = require('stripe')(client_secret);
var admin = require('firebase-admin');
var bodyParser = require('body-parser')
var request = require('request');
const path = require('path');
var fs = require('fs');
var app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: true
}));

/* Generate the service account key at https://console.firebase.google.com/project/tellomee-x/settings/serviceaccounts/adminsdk
    We would like to do the following, for example:
    var serviceAccount = require('./tellomee-x-firebase-adminsdk.json');
    But we can't require the service account key file when we have to deploy the git repo on Heroku, 
    so instead (if the file doesn't exist, which it shouldn't on the server (it's in .gitignore)), 
    we use environment variables and create the serviceAccount object using the values
    from the service account file from firebase.
*/
let serviceAccountFilePath = SERVICE_ACCOUNT_FILE_PATH
var serviceAccount
if (fs.existsSync(serviceAccountFilePath)) {
    serviceAccount = require("./" + serviceAccountFilePath);
} else {
    if (!process.env.FIREBASE_PRIVATE_KEY ||
        !process.env.FIREBASE_CLIENT_EMAIL) {
            console.error("There is no service account file at path: " + serviceAccountFilePath + ". This is expected on the server. In that case, then, you must define FIREBASE_PRIVATE_KEY and FIREBASE_CLIENT_EMAIL with values from the file.")
            process.exit(1)
    }

    serviceAccount = {
        // The \n's in the private key string cause a failure to parse the private key when initializing, so we fix it up here according to:
        // https://stackoverflow.com/questions/41287108/deploying-firebase-app-with-service-account-to-heroku-environment-variables-wit
        "private_key": process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
        "client_email": process.env.FIREBASE_CLIENT_EMAIL,
    }
}


// This firebase stuff might need to move into /book
// Initialize firebase for booking reservations
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://tellomee-x.firebaseio.com"
});
// Get a database reference to our posts
var db = admin.database();
var reservationsDatabaseRef = db.ref("reservations");


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
            console.log("Ephemeral key created")
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

    const { source, reservationId } = req.body;
  
    let currency = "USD"

    try {
        console.log("reservationId:", reservationId)

        reservationsDatabaseRef.child(reservationId).once("value", function(snapshot) {

            let reservation = snapshot.val();

            // Don't double charge a reservation
            if (reservation.hasOwnProperty("stripeChargeId")) {
                let message = "Cannot process charge. Stripe charge" + reservation.stripeChargeId + " already exists for reservation " + reservation.id
                res.status(400).send({error: message});
                return
            }

            // Round the amount up to the nearest penny (it shouldn't have more than two decimal places anyway, just in case it does)
            // Remember Stripe expects numbers in pennies, and we were given the amount in dollars
            let amount = reservation.totalCharge;
            console.log("amount", amount);
            let fee = reservation.fee;
            let amountForCurator = amount - fee
            console.log("amountForCurator", amountForCurator);


            let customerStripeId = reservation.userStripeId
            let curatorStripeId = reservation.curatorStripeId
            
            createCharge({
                source: source, 
                amount: amount, 
                currency: currency, 
                customer: customerStripeId, 
                description: "Tellomee", 
                statement_description: "Tellomee", 
                amountForCurator: amountForCurator, 
                account: curatorStripeId},
            function(chargeId) {
                 console.log("Created charge. ChargeId:", chargeId)

                // Add the Stripe charge reference to the reservation and save it.
                reservationsDatabaseRef.child(reservationId).update({ stripeChargeId: chargeId })
                  
                // Return the new stripe charge id
                res.send({stripeChargeId: chargeId});
            });
                                                
        }, function (errorObject) {
            console.log("Cannot find reservation " + reservationId + ": " + errorObject.code);
        });
    } catch (err) {
      res.sendStatus(500);
      next(`Error adding token to customer: ${err.message}`);
    }

});

async function createCharge(chargeParams, callback) {

    
    // Create a charge and set its destination to the pilot's account.
    const charge = await stripe.charges.create({
        source: chargeParams.source,
        amount: chargeParams.amount,
        currency: chargeParams.currency,
        customer: chargeParams.customer,
        description: chargeParams.description,
        statement_descriptor: chargeParams.statement_description,
        destination: {
            amount: chargeParams.amountForCurator,
            account: chargeParams.account
        }
    });

    callback(charge.id)

    return charge

}

app.listen(PORT, () => console.log(`Listening on ${ PORT }`))
