/* eslint-disable require-jsdoc */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// Configure the email transport using Nodemailer
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "connected.app.contact@gmail.com", // Replace with your email
    pass: "lbuw mhjo atjr annx", // Replace with your app password
  },
});

// Function to send an email when a new meeting request is created
exports.sendMeetingNotification = functions.firestore
    .document("meeting_requests/{docId}")
    .onCreate(async (snap, context) => {
      const data = snap.data();
      const receiverId = data.receiverId;

      console.log("Fetching user data for receiverId:", receiverId);

      try {
        const userDoc = await admin.firestore().collection(
            "users").doc(receiverId).get();

        if (!userDoc.exists) {
          console.log("No user found with the given receiverId:", receiverId);
          return;
        }

        const email = userDoc.data().email;

        console.log("Found user with email:", email);

        const mailOptions = {
          from: "\"ConnectEd\" connected.app.contact@gmail.com",
          to: email,
          subject: "New Meeting Request from Teacher",
          html: `
        <div style="background-color: #f9f7cf; padding: 20px;
         font-family: Arial, sans-serif; color: #333;">
          <div style="text-align: center; margin-bottom: 20px;">
            <img src="https://your-logo-url.com/logo.png" alt="ConnectEd Logo" style="width: 100px; height: auto;" />
          </div>
          <div style="background-color: #fff; 
          padding: 20px; border-radius: 8px; 
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
              <a href="yourapp://app/openRequest?requestId=${context.params.docId}" style="background-color: #f39c12; color: #fff; padding: 10px 20px; text-decoration: none; border-radius: 5px; font-size: 16px;">View Request</a>
            </div>
          </div>
          <div style="text-align: center; 
          margin-top: 20px; font-size: 12px; color: #999;">
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

// Function to send an email when a meeting is scheduled
exports.sendScheduledMeetingNotification = functions.firestore
    .document("scheduled_meetings/{docId}")
    .onCreate(async (snap, context) => {
      const data = snap.data();
      const teacherEmail = data.teacherEmail;
      const industryEmail = data.industryEmail;

      try {
        const startDateTime = formatDateForCalendar(data.date, data.start_time);
        const endDateTime = formatDateForCalendar(data.date, data.end_time);

        const calendarLink = `https://www.google.com/calendar/render?action=TEMPLATE&text=Meeting%20with%20${data.teacherName}&dates=${startDateTime}/${endDateTime}&details=Meeting%20with%20${data.teacherName}%20to%20discuss%20${data.outline}&location=&trp=false`;

        const mailOptions = {
          from: "\"ConnectEd\" <connected.app.contact@gmail.com>",
          to: `${teacherEmail}, ${industryEmail}`,
          subject: "Scheduled Meeting Confirmation",
          html: `
                  <div style="background-color: #f9f7cf; padding: 20px; 
                  font-family: Arial, sans-serif; color: #333;">
                    <div style="text-align: center; margin-bottom: 20px;">
                      <img src="https://your-logo-url.com/logo.png" alt="ConnectEd Logo" style="width: 100px; height: auto;" />
                    </div>
                    <div style="background-color: #fff; padding: 20px; 
                    border-radius: 8px;
                     box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);">
                      <h2 style="color: #2c3e50;
                      ">Meeting Scheduled with ${data.industryName}</h2>
                      <p style="font-size: 16px; line-height: 1.6;">
                        <strong>Date and Time:</strong> 
                        ${data.date} from ${data.start_time}
                         to ${data.end_time}
                      </p>
                      <p style="font-size: 16px; line-height: 1.6;">
                        <strong>Outline:</strong> ${data.outline}
                      </p>
                      <div style="text-align: center; margin: 20px 0;">
                        <a href="${calendarLink}" 
                        style="background-color: #f39c12; 
                        color: #fff; padding: 10px 20px; text-decoration: none; 
                        border-radius: 5px; font-size: 16px;
                        ">Add to Google Calendar</a>
                      </div>
                    </div>
                    <div style="text-align: center; margin-top: 20px;
                     font-size: 12px; color: #999;">
                      <p>© 2024 ConnectEd. All rights reserved.</p>
                      <p>If you did not request this email, please ignore it.
                      </p>
                    </div>
                  </div>
                `,
        };

        await transporter.sendMail(mailOptions);
        console.log("Scheduled meeting email sent successfully");
      } catch (error) {
        console.error("Error sending scheduled meeting email:", error);
      }
    });


function formatDateForCalendar(date, time) {
  try {
    // Parse the date string into a Date object
    const dateObject = new Date(date);

    // Extract hours and minutes from the time string
    const [hour, minute] = time.split(":");

    // Set the hours and minutes on the Date object
    dateObject.setUTCHours(hour, minute);

    // Check if the date is valid
    if (isNaN(dateObject.getTime())) {
      throw new Error("Invalid date or time value");
    }

    // Return the formatted string for Google Calendar
    return dateObject.toISOString().replace(/-|:|\.\d+/g, "");
  } catch (error) {
    console.error("Error formatting date for Google Calendar:", error);
    throw error;
  }
}
