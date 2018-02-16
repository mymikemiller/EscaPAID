'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

/**
 * Triggers when a user gets a new message (thread post) and sends a notification.
 *
 * New posts add a flag to `/threadPosts/{threadId}/{postId}`.
 * Users save their device notification tokens to `/users/{userUid}/notificationTokens/{notificationToken}`.
 */
exports.sendThreadPostNotification = functions.database.ref('/threadPosts/{threadId}/{postId}').onWrite((event) => {
  const threadId = event.params.threadId;
  const postId = event.params.postId;
  console.log('*** NEW threadPost at threadId ' + threadId + ' (postId: ' + postId + ")");

  var tokensSentTo = []
  var tokensSnapshot = {}
  var recipientId = ""
  var senderName = ""
  var senderUid = ""

  // Get the recepient's Uid (/threadPosts/{threadId}/{postId}/toId)
  admin.database().ref(`/threadPosts/${threadId}/${postId}`).once('value').then(function(snapshot) {
    var senderId = snapshot.val().fromId
    recipientId = snapshot.val().toId

    // Get the sender's name
    return admin.database().ref(`/users/${senderId}`).once('value');
  }).then(function(snapshot) {
    senderName = snapshot.val().displayName
    senderUid = snapshot.val().uid

    // Get the recipient's list of device notification tokens
    return admin.database().ref(`/users/${recipientId}/notificationTokens`).once('value');
  }).then(function(snapshot) {
      tokensSnapshot = snapshot
    // Check if there are any device tokens.
    if (!tokensSnapshot.hasChildren()) {
        return console.log('There are no notification tokens to send to.');
    }

    console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');

    console.log("Sender name: " + senderName)
    console.log("Sender uid: " + senderUid)

    // Notification details.
    const payload = {
        notification: {
          title: 'You have a new message!',
          body: `${senderName} sent you a message`,
          //icon: "https://www.blossom.co/wp-content/uploads/2015/02/10-prod-mgmt-lessons-tod-sacerdoti.jpg"
        },
        data: {
            uid: senderUid
        }
      };
  
      // Listing all tokens.
      tokensSentTo = Object.keys(tokensSnapshot.val());
  
      // Send notifications to all tokens.
      return admin.messaging().sendToDevice(tokensSentTo, payload);
  }).then((response) => {
    // For each message check if there was an error.
    const tokensToRemove = [];
    response.results.forEach((result, index) => {
      const error = result.error;
      if (error) {

        console.error('Failure sending notification to', tokensSentTo[index], error);
        // Cleanup the tokens who are not registered anymore.
        if (error.code === 'messaging/invalid-registration-token' || error.code === 'messaging/registration-token-not-registered') {
            
            console.log("Removing token", tokensSentTo[index])
            tokensToRemove.push(tokensSnapshot.ref.child(tokensSentTo[index]).remove());
          
        }
      }
    });
    return Promise.all(tokensToRemove);
  });;
});