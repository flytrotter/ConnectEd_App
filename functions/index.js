const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// Configure the email transport using Nodemailer
const transporter = nodemailer.createTransport({
  service: "gmail", // Ensure the service name is correct.
  auth: {
    user: "connected.app.contact@gmail.com", // Replace with your email
    pass: "lbuw mhjo atjr annx", // Replace with your app password
  },
});

exports.sendMeetingNotification = functions.firestore
    .document("meeting_requests/{docId}")
    .onCreate(async (snap, context) => {
      const data = snap.data();
      const receiverId = data.receiverId;

      console.log("Fetching user data for receiverId:", receiverId);

      try {
      // Retrieve the email for the receiver
        const userDoc = await admin.firestore().collection(
            "users").doc(receiverId).get();

        if (!userDoc.exists) {
          console.log("No user found with the given receiverId:", receiverId);
          return;
        }

        const email = userDoc.data().email;

        console.log("Found user with email:", email);

        // Send email notification
        const mailOptions = {
          from: "\"ConnectEd\" connected.app.contact@gmail.com",
          to: email,
          subject: "New Meeting Request from Teacher",
          html: `
  <div style="background-color: #f9f7cf; 
  padding: 20px; 
  font-family: Arial, 
  sans-serif; 
  color: #333;">
    <div style="text-align: center; margin-bottom: 20px;">
      <img src="https://your-logo-url.com/logo.png" 
      alt="ConnectEd Logo" 
      style="width: 100px; 
      height: auto;" />
    </div>
    <div style="background-color: #fff; 
    padding: 20px; 
    border-radius: 8px; 
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);">
      <h2 style="color: #2c3e50;
      ">New Meeting Request from ${data.senderName}</h2>
      <p style="font-size: 16px; line-height: 1.6;">
        <strong>Note from teacher:</strong> ${data.note}
      </p>
      <p style="font-size: 16px; line-height: 1.6;">
        Please click the link below to view the request:
      </p>
      <div style="text-align: center; margin: 20px 0;">
        <a href="yourapp://app/openRequest?requestId=${context.params.docId}" 
        style="background-color: #f39c12;
         color: #fff; 
         padding: 10px 20px;
          text-decoration: none;
           border-radius: 5px;
            font-size: 16px;">View Request</a>
      </div>
    </div>
    <div style="text-align: center;
     margin-top: 20px;
      font-size: 12px;
       color: #999;">
      <p>© 2024 ConnectEd. All rights reserved.</p>
      <p>If you did not request this email, please ignore it.</p>
    </div>
  </div>
  `,
        };

        console.log("Sending email to:", email);

        await transporter.sendMail(mailOptions);
        console.log("Email sent successfully to:", email);
      } catch (error) {
        console.error("Error sending email notification:", error);
      }
    });
