/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendMeetingNotification = functions.firestore
    .document("meeting_requests/{docId}")
    .onCreate((snap, context) => {
      const data = snap.data();
      const receiverId = data.receiverId;

      // Retrieve the device token for the receiver
      return admin.firestore().collection("users").doc(receiverId).get()
          .then((userDoc) => {
            const token = userDoc.data().fcmToken;

            const payload = {
              notification: {
                title: "New Meeting Request",
                body: `You have a new meeting request from ${data.senderName}`,
              },
              data: {
                click_action: "FLUTTER_NOTIFICATION_CLICK",
                id: "1",
                status: "done",
              },
            };

            return admin.messaging().sendToDevice(token, payload);
          });
    });
