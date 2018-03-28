'use strict';
var argv = require('minimist')(process.argv.slice(2));

const PORT = process.env.PORT || 6000

// This should never be set on the server. The target argument specifies which environment variables to use on the local machine. See README.md.
const target = argv["target"]
if (target) {
    console.log("Running with target: " + target + ". This should only be done on localhost.")
} else {
    console.log("Running without a target. This is expected on the server and the default environment variables will be used. If you're running on localhost and meant to specify a target, use, e.g. npm start -- --target=renaissance.")
}

const STRIPE_SECRET_KEY = getConfig(target, "STRIPE_SECRET_KEY")
const DATABASE_URL = getConfig(target, "DATABASE_URL")
const FIREBASE_PRIVATE_KEY = getConfig(target, "FIREBASE_PRIVATE_KEY")
const FIREBASE_CLIENT_EMAIL = getConfig(target, "FIREBASE_CLIENT_EMAIL")
const AASA_FILE_PATH = getConfig(target, "AASA_FILE_PATH")

// Returns the specified argument, or if none is found, specified environment variable
function getConfig(target, varName) {
    if (target) {
        varName = target.toUpperCase() + "_" + varName
    }
    var variable = process.env[varName]
    if (!variable) {
        console.error("The following environment variable must be specified: " + varName + ". Make sure you specify the correct target parameter if running the script on a local machine.")
        process.exit(1)
    }
    return variable
}

const express = require('express');
var stripe = require('stripe')(STRIPE_SECRET_KEY);
var admin = require('firebase-admin');
var bodyParser = require('body-parser');
var request = require('request');
const path = require('path');
var fs = require('fs');
var app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: true
}));

// Serve public files
app.use(express.static('public'))

/* Generate the firebase service account key at https://console.firebase.google.com/project/tellomee-x/settings/serviceaccounts/adminsdk
    We would like to do the following, for example:
    var serviceAccount = require('./tellomee-x-firebase-adminsdk.json');
    But we can't require the service account key file when we have to deploy the git repo on Heroku, 
    so instead, we use environment variables and create the serviceAccount object using the values
    from the service account file from firebase.
*/
var serviceAccount = {
    // The \n's in the private key string cause a failure to parse the private key when initializing, so we fix it up here according to:
    // https://stackoverflow.com/questions/41287108/deploying-firebase-app-with-service-account-to-heroku-environment-variables-wit
    "private_key": FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
    "client_email": FIREBASE_CLIENT_EMAIL,
}

// This firebase stuff might need to move into /book
// Initialize firebase for booking reservations
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: DATABASE_URL
});
// Get a database reference to our posts
var db = admin.database();
var reservationsDatabaseRef = db.ref("reservations");

app.get("/apple-app-site-association", (req, res) => {
    // Serve a different file based on environment variable
    console.log("at get /apple-app-site-association")
    res.redirect(AASA_FILE_PATH)
})

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
        { json: { client_secret: STRIPE_SECRET_KEY,
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
            function(err, chargeId) {
                if (err) {
                    console.log("Error creating charge:", err)
                    return res.status(500).send(err)
                }

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
    stripe.charges.create({
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
    }).then(function(charge) {
        callback(null, charge.id)
    }, function(err) {
        callback(err, null)
        return
    });
}

app.listen(PORT, () => console.log(`Listening on ${ PORT }`))
