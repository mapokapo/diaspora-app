import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import serviceAccount from "./diaspora-app-9ffb9-firebase-adminsdk-2g4bm-06c28af2f8.json";
import {ServiceAccount} from "firebase-admin";
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount as ServiceAccount),
  databaseURL:
    "https://diaspora-app-9ffb9-default-rtdb.europe-west1.firebasedatabase.app",
});

export const sendMatchNotification = functions.region("europe-west3").firestore.document("users/{userId}").onUpdate(async (change) => {
  const newMatches: string[] = change.after.get("matches");
  const oldMatches: string[] = change.before.get("matches");
  // If the field that changed is matches AND if the action was addition
  const newLen: number = newMatches?.length as number;
  const oldLen: number = oldMatches?.length as number;
  if (newLen - 1 === oldLen) {
    // The user that matched somebody
    const userName = change.after.get("name");
    const newMatch = newMatches.filter((match) => !oldMatches.includes(match))[0];
    // The user that got matched by somebody
    const matchedUserDoc = await admin.firestore().collection("users").doc(newMatch).get();
    const matchedUserToken = matchedUserDoc.get("deviceToken");
    if (!matchedUserToken) return;
    admin.messaging().sendToDevice(matchedUserToken, {
      notification: {
        body: `Diaspora +${userName}`,
        color: "#A5D6A7",
        title: userName,
        tag: matchedUserDoc.id,
      },
      data: {
        matchedUserId: matchedUserDoc.id,
      },
    });
  }
});

export const sendChatNotification = functions.region("europe-west3").firestore
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
        if (messageCountDoc.get(senderId)) {
          const prevCount = parseInt(messageCountDoc.get(senderId));
          await messagesCountRef.update({
            [senderId]: prevCount + 1,
          });
        }
      } else {
        await messagesCountRef.create({
          [senderId]: 1,
        });
      }
    });
