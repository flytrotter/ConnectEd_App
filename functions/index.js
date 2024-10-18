/* eslint-disable quotes */
/* eslint-disable indent */
/* eslint-disable object-curly-spacing */
/* eslint-disable max-len */
/* eslint-disable require-jsdoc */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const {DateTime} = require("luxon");
// const { google } = require("googleapis");
// const cloudScheduler = google.cloudscheduler("v1");


admin.initializeApp();

// Configure the email transport using Nodemailer
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: %EMAIL_GOES_HERE%,
    pass: %GENERATED_APP_PASSWORD_GOES_HERE%,
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
      const meetLink = data.meet_info;

      try {
        // eslint-disable-next-line no-unused-vars
        const startDateTime2 = formatDateForCalendar(data.date, data.start_time);
        // eslint-disable-next-line no-unused-vars
        const endDateTime2 = formatDateForCalendar(data.date, data.end_time);

        const humanReadableDate = DateTime.fromISO(data.date, {zone: "America/New_York"})
        .toFormat("MMMM d, yyyy"); // Properly formats the date to be human-readable

    // Parsing and adjusting start time
    const startTime = DateTime.fromISO(data.date, {zone: "America/New_York"}) // Keep the date in the right time zone
        .set({
            hour: parseInt(data.start_time.split(':')[0]),
            minute: parseInt(data.start_time.split(':')[1]),
        }) // Set the correct hours and minutes from the input time
        .toFormat("h:mm a"); // Formats to 12-hour time (AM/PM)

    // Parsing and adjusting end time
    const endTime = DateTime.fromISO(data.date, {zone: "America/New_York"}) // Keep the date in the right time zone
        .set({
            hour: parseInt(data.end_time.split(':')[0]),
            minute: parseInt(data.end_time.split(':')[1]),
        }) // Set the correct hours and minutes from the input time
        .toFormat("h:mm a"); // Formats to 12-hour time (AM/PM)


        const calendarLink = `https://www.google.com/calendar/render?action=TEMPLATE&text=Meeting%20with%20${data.teacherName}&dates=${startDateTime2}/${endDateTime2}&details=Meeting%20with%20${data.teacherName}%20to%20discuss%20${data.outline}&location=&trp=false`;

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
                        ${humanReadableDate} from ${startTime}
                         to ${endTime}
                      </p>
                      <p style="font-size: 16px; line-height: 1.6;">
                        <strong>Outline:</strong> ${data.outline}
                      </p>
                      <p style="font-size: 16px; line-height: 1.6;">
                        <strong>Meet Link:</strong> ${meetLink}
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

        // Schedule reminder emails
        // scheduleReminderEmails(data, teacherEmail, industryEmail);
      } catch (error) {
        console.error("Error sending scheduled meeting email:", error);
      }
    });

    // async function scheduleDynamicReminder(meetingId, reminderTime, data) {
    //   const auth = new google.auth.GoogleAuth({
    //     scopes: ['https://www.googleapis.com/auth/cloud-platform'],
    //   });

    //   const authClient = await auth.getClient();
    //   google.options({ auth: authClient });

    //   const projectId = await google.auth.getProjectId();

    //   // Create a unique job ID based on meeting ID and reminder time
    //   const jobName = `projects/${projectId}/locations/us-central1/jobs/reminder-${meetingId}-${reminderTime}`;

    //   // Set the reminder time (subtract reminderTime from meeting start time)
    //   const targetTime = new Date(data.meetingDateTime);
    //   targetTime.setMinutes(targetTime.getMinutes() - reminderTime);

    //   const jobConfig = {
    //     parent: `projects/${projectId}/locations/us-central1`,
    //     job: {
    //       name: jobName,
    //       scheduleTime: targetTime.toISOString(),
    //       httpTarget: {
    //         httpMethod: "POST",
    //         uri: `https://us-central1-${projectId}.cloudfunctions.net/sendReminderEmailTask`, // Cloud Function to send email
    //         body: Buffer.from(
    //           JSON.stringify({
    //             teacherEmail: data.teacherEmail,
    //             industryEmail: data.industryEmail,
    //             label: `${reminderTime} minutes before meeting`,
    //             data: data,
    //           }),
    //         ).toString("base64"),
    //         headers: {
    //           "Content-Type": "application/json",
    //         },
    //       },
    //     },
    //   };

    //   try {
    //     const response = await cloudScheduler.projects.locations.jobs.create({
    //       parent: `projects/${projectId}/locations/us-central1`,
    //       resource: jobConfig,
    //     });
    //     console.log(`Successfully scheduled job ${jobName}: `, response.data);
    //   } catch (error) {
    //     console.error(`Failed to schedule reminder: ${error.message}`);
    //   }
    // }

// function scheduleReminderEmails(data, teacherEmail, industryEmail) {
//   console.log("Scheduling reminder emails...");
//   const meetingDateTime = DateTime.fromISO(data.date, {zone: "America/New_York"})
//   .set({
//     hour: parseInt(data.start_time.split(':')[0]),
//     minute: parseInt(data.start_time.split(':')[1]),
//   });
//   console.log("Meeting DateTime (EST):", meetingDateTime.toString());

//   const reminders = [
//     {label: "1 week", time: 7 * 24 * 60 * 60 * 1000},
//     {label: "1 day", time: 24 * 60 * 60 * 1000},
//     {label: "2 hours", time: 2 * 60 * 60 * 1000},
//     {label: "15 minutes", time: 15 * 60 * 1000},
//     {label: "Start", time: 0},
//   ];

//   reminders.forEach((reminder) => {
//     scheduleDynamicReminder(data.meetingId, reminder.time, {
//       teacherEmail,
//       industryEmail,
//       meetingDate: meetingDateTime, // Combine date and time for scheduling
//       start_time: data.start_time,
//       end_time: data.end_time,
//       outline: data.outline,
//       teacherName: data.teacherName,
//     });
//   });
// }

// exports.sendReminderEmailTask = functions.https.onRequest(async (req, res) => {
//   const { teacherEmail, industryEmail, label, data } = req.body;

//   const mailOptions = {
//     from: '"ConnectEd" <connected.app.contact@gmail.com>',
//     to: `${teacherEmail}, ${industryEmail}`,
//     subject: `🔔 Reminder: Meeting with ${data.teacherName} in ${label} 🔔`,
//     html: `
//       <div style="background-color: #f9f7cf; padding: 20px; font-family: Arial, sans-serif; color: #333;">
//         <div style="text-align: center; margin-bottom: 20px;">
//           <img src="https://your-logo-url.com/logo.png" alt="ConnectEd Logo" style="width: 100px; height: auto;" />
//         </div>
//         <div style="background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);">
//           <h2 style="color: #2c3e50;">🔔 Reminder: Meeting with ${data.teacherName}</h2>
//           <p style="font-size: 16px; line-height: 1.6;"><strong>Date and Time:</strong> ${data.date} from ${data.start_time} to ${data.end_time}</p>
//           <p style="font-size: 16px; line-height: 1.6;"><strong>Outline:</strong> ${data.outline}</p>
//           <p style="font-size: 16px; line-height: 1.6;"><strong>Meet Link:</strong> ${data.meet_info}</p>
//         </div>
//       </div>
//     `,
//   };

//   transporter.sendMail(mailOptions, (error, info) => {
//     if (error) {
//       return res.status(500).send(`Error sending reminder email: ${error.message}`);
//     }
//     console.log(`Reminder email sent: ${info.response}`);
//     res.status(200).send(`Reminder email sent: ${info.response}`);
//   });
// });


  // const now = DateTime.now().setZone("America/New_York");
  // console.log("Current DateTime (EST):", now.toString());

//   reminders.forEach((reminder) => {
//     const reminderTime = meetingDateTime.minus({milliseconds: reminder.time});
//     console.log(`Reminder for ${reminder.label} at (EST):`, reminderTime.toString());

//     if (reminderTime > now) {
//       const delay = reminderTime.diff(now).as("milliseconds");
//       console.log(`Scheduling reminder for ${reminder.label} in ${delay} ms`);

//       setTimeout(() => {
//         sendReminderEmail(reminder.label, teacherEmail, industryEmail, data);
//       }, delay);
//     } else {
//       console.log(`Skipping reminder for ${reminder.label} - Time has already passed.`);
//     }
//   });
// }

// function sendReminderEmail(label, teacherEmail, industryEmail, data) {
//   console.log(`Sending reminder email for ${label}...`);

//   const meetLink = data.meet_info;
//   const humanReadableDate = DateTime.fromISO(data.date, {zone: "America/New_York"})
//         .toFormat("MMMM d, yyyy"); // Properly formats the date to be human-readable

//     // Parsing and adjusting start time
//     const startTime = DateTime.fromISO(data.date, {zone: "America/New_York"}) // Keep the date in the right time zone
//         .set({
//             hour: parseInt(data.start_time.split(':')[0]),
//             minute: parseInt(data.start_time.split(':')[1]),
//         }) // Set the correct hours and minutes from the input time
//         .toFormat("h:mm a"); // Formats to 12-hour time (AM/PM)

//     // Parsing and adjusting end time
//     const endTime = DateTime.fromISO(data.date, {zone: "America/New_York"}) // Keep the date in the right time zone
//         .set({
//             hour: parseInt(data.end_time.split(':')[0]),
//             minute: parseInt(data.end_time.split(':')[1]),
//         }) // Set the correct hours and minutes from the input time
//         .toFormat("h:mm a"); // Formats to 12-hour time (AM/PM)

//   const mailOptions = {
//     from: "\"ConnectEd\" <connected.app.contact@gmail.com>",
//     to: `${teacherEmail}, ${industryEmail}`,
//     subject: `🔔 Reminder: Meeting with ${data.teacherName} in ${label} 🔔 `,
//     html: `
//             <div style="background-color: #f9f7cf; padding: 20px;
//             font-family: Arial, sans-serif; color: #333;">
//               <div style="text-align: center; margin-bottom: 20px;">
//                 <img src="https://your-logo-url.com/logo.png" alt="ConnectEd Logo" style="width: 100px; height: auto;" />
//               </div>
//               <div style="background-color: #fff; padding: 20px;
//                border-radius: 8px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);">
//                 <h2 style="color: #2c3e50;
//                 ">🔔 Reminder: Meeting with ${data.teacherName}</h2>
//                 <p style="font-size: 16px;
//                 line-height: 1.6;"><strong>Date and Time:</strong>
//                 ${humanReadableDate} from ${startTime} to ${endTime}</p>
//                 <p style="font-size: 16px; line-height: 1.6;
//                 "><strong>Outline:</strong> ${data.outline}</p>
//                 <p style="font-size: 16px; line-height: 1.6;
//                 "><strong>Meet Link:</strong> ${meetLink}</p>
//                 <div style="text-align: center;
//                 margin-top: 20px; font-size: 12px; color: #999;">
//                   <p>© 2024 ConnectEd. All rights reserved.</p>
//                   <p>If you did not request this email, please ignore it.</p>
//                 </div>
//               </div>
//             </div>
//           `,
//   };

//   transporter.sendMail(mailOptions, (error, info) => {
//     if (error) {
//       return console.error("Error sending reminder email:", error);
//     }
//     console.log(`Reminder email for ${label} sent: ${info.response}`);
//   });
// }

function formatDateForCalendar(date, time) {
  try {
    const dateObject = DateTime.fromISO(date, {zone: "America/New_York"});
    const [hour, minute] = time.split(":");
    const finalDateTime = dateObject.set({hour: parseInt(hour),
      minute: parseInt(minute)});

    if (!finalDateTime.isValid) {
      throw new Error("Invalid date or time value");
    }

    return finalDateTime.toUTC().toISO().replace(/-|:|\.\d+/g, "");
  } catch (error) {
    console.error("Error formatting date for Google Calendar:", error);
    throw error;
  }
}

// exports.updateVolunteerHours = functions.firestore
//     .document("scheduled_meetings/{meetingId}")
//     .onCreate(async (change, context) => {
//       const newValue = change.after.data();
//       const prevValue = change.before.data();

//       // Parse the meeting start and end times from the Firestore document
//       const meetingDate = new Date(newValue.date);
//       const startTimeParts = newValue.start_time.split(":");
//       const endTimeParts = newValue.end_time.split(":");

//       const startTime = new Date(meetingDate);
//       startTime.setHours(parseInt(startTimeParts[0], 10), parseInt(startTimeParts[1], 10));

//       const endTime = new Date(meetingDate);
//       endTime.setHours(parseInt(endTimeParts[0], 10), parseInt(endTimeParts[1], 10));

//       // Check if the meeting has ended
//       const now = new Date();
//       if (now >= endTime && prevValue.date === newValue.date) {
//         const industryUserId = newValue.industryId;

//         // Calculate the duration of the meeting in hours
//         const duration = (endTime - startTime) / (1000 * 60 * 60); // hours

//         // Update the user's volunteer hours
//         await admin.firestore().collection("users").doc(industryUserId).update({
//           volunteer_hours: admin.firestore.FieldValue.increment(duration),
//         });

//         console.log(`Updated volunteer hours for user ${industryUserId} by ${duration} hours.`);
//       } else {
//         console.log("Meeting has not ended yet, no update to volunteer hours.");
//       }
//     });
