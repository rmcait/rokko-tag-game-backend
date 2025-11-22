import {onCall} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

admin.initializeApp();

export const notifyGameEvent = onCall(
  {region: "us-central1"},
  async (request) => {
    const {data} = request;

    const {gameId, title, body} = data;

    if (!gameId || !title || !body) {
      throw new Error("Missing gameId, title, or body");
    }

    const topic = `game_${gameId}`;

    await admin.messaging().send({
      notification: {title, body},
      topic,
    });

    return {success: true};
  }
);
