import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import serviceAccount from "./diaspora-app-9ffb9-firebase-adminsdk-2g4bm-06c28af2f8.json";
import {ServiceAccount} from "firebase-admin";
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount as ServiceAccount),
  databaseURL:
    "https://diaspora-app-9ffb9-default-rtdb.europe-west1.firebasedatabase.app",
});

export const sendNotification = functions.region("europe-west3").firestore
    .document("messages/{docId}")
    .onCreate(async (snapshot) => {
      const messageText = snapshot.get("text");
      const senderId = snapshot.get("senderId");
      const receiverId = snapshot.get("receiverId");
      const senderData = await admin
          .firestore()
          .collection("users")
          .doc(senderId)
          .get();
      const receiverData = await admin
          .firestore()
          .collection("users")
          .doc(receiverId)
          .get();
      const deviceToken = receiverData.get("deviceToken");
      if (deviceToken) {
        await admin.messaging().sendToDevice(deviceToken, {
          notification: {
            body: messageText,
            color: "#A5D6A7",
            title: senderData.get("name"),
            tag: senderId,
          },
          data: {
            senderId,
          },
        });
      }
      const messagesCountRef = admin.firestore().collection("messagesCount").doc(receiverId);
      const messageCountDoc = await messagesCountRef.get();
      if (messageCountDoc.exists) {
        const prevCount = parseInt(messageCountDoc.get(senderId));
        await messagesCountRef.update({
          [senderId]: prevCount + 1,
        });
      } else {
        await messagesCountRef.create({
          [senderId]: 1,
        });
      }
    });
