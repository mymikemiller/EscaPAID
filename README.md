# EscaPAID

EscaPAID is the base marketplace app that can be customized by adding targets. Currently there are two targets:
* Art With Me: a marketplace for artists to share their art with paying customers
* Tellomee: a marketplace for premium experiences

Development notes:

* Separate apps
  * iOS
    * The iOS project uses targets to toggle between apps
      * Currently Tellomee and Art With Me
  * Server
    * The server folder can be deployed to different heroku apps, one remote for each, each with different environment variables set up.
      * Currently the remotes tellomee and artwithme point to the apps tellomee-x and artwithme-x
    * To add a new app:
      * heroku git:remote --remote new-remote-name -a heroku-app-name

* Environment Variables
  * This app uses environment variables to separate the different targets and configure things such as the private key for Stripe and the URL to the firebase database.
  * The following environment variables must be set:
    * DATABASE_URL: The url to the firebase database where the reservations are stored. It is of the form https://artwithme-x.firebaseio.com/
    * STRIPE_SECRET_KEY and STRIPE_TEST_SECRET_KEY: The secret key (client secret) from the stripe dashboard.
    * FIREBASE_PRIVATE_KEY: The value for private_key in the firebase-adminsdk.json file donwloaded from the Service Account section of the Firebase console.
    * FIREBASE_CLIENT_EMAIL: The value for client_email in the firebase-adminsdk.json file donwloaded from the Service Account section of the Firebase console.

* Testing on local machine
  * On your local machine, you can use "npm start -- --target=tellomee" (for example) which will append TELLOMEE_ to each environment variable used. This way you can set up multiple sets of environment variables and easily toggle between them.
    
* Setting environment variables for the firebase service account private key and email
  * Download the service account file from the appropriate firebase admin sdk console, for example:
    * https://console.firebase.google.com/project/tellomee-x/settings/serviceaccounts/adminsdk
  * Open the file and copy the values for private_key and client_email into environment variables locally 
    * export {{TARGET}}_FIREBASE_PRIVATE_KEY="{key string from file here}"
    * export {{TARGET}}_FIREBASE_CLIENT_EMAIL="{email string from file here}"

* To deploy just the server folder to Heroku ({{target}} is the heroku remote for the app target, for example, "tellomee" or "artwithme", and is also the git remote to the heroku app's delpoy git):
  * cd to root folder
  * git subtree push --prefix server {{target}} master
  * To set the environment variables on heroku (e.g. for the tellomee app):
    * heroku config:set DATABASE_URL="${{TARGET}}_DATABASE_URL" -a {{app name (e.g. tellomee-x)}}
    
