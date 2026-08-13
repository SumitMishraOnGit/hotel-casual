const { onValueCreated } = require("firebase-functions/v2/database");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Triggers when a new notification is written to /notifications/{userId}/{notificationId}.
 * Fetches the recipient's fcmToken from /users/{userId}/fcmToken and sends a push notification.
 */
exports.sendNotificationPush = onValueCreated(
  "/notifications/{userId}/{notificationId}",
  async (event) => {
    const userId = event.params.userId;
    const notifId = event.params.notificationId;
    const notification = event.data.val();

    if (!notification) return;

    // Fetch user's FCM token from RTDB
    const userSnap = await admin.database().ref(`/users/${userId}/fcmToken`).once("value");
    const fcmToken = userSnap.val();

    if (!fcmToken) {
      console.log(`No FCM token found for user: ${userId}`);
      return;
    }

    const payload = {
      token: fcmToken,
      notification: {
        title: notification.title || "Hotel Casual Update",
        body: notification.body || "",
      },
      data: {
        notifId: notifId || "",
        userId: userId || "",
        jobId: notification.jobId || "",
        type: notification.type || "",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "hotel_casual_channel",
          icon: "@drawable/ic_notification",
          sound: "default",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
    };

    try {
      const response = await admin.messaging().send(payload);
      console.log(`Successfully sent push notification to ${userId}:`, response);
    } catch (error) {
      console.error(`Error sending push notification to ${userId}:`, error);

      // If token is invalid or unregistered, clean it up from RTDB
      if (
        error.code === "messaging/invalid-registration-token" ||
        error.code === "messaging/registration-token-not-registered"
      ) {
        console.log(`Cleaning up invalid FCM token for user ${userId}`);
        await admin.database().ref(`/users/${userId}/fcmToken`).remove();
      }
    }
  }
);
