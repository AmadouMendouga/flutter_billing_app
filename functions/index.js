const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

const GMAIL_APP_PASSWORD = defineSecret("GMAIL_APP_PASSWORD");
const GMAIL_USER = "mboamarkets@gmail.com";

const CODE_TTL_MS = 10 * 60 * 1000;
const RESEND_COOLDOWN_MS = 60 * 1000;
const MAX_ATTEMPTS = 5;

function generateCode() {
  return String(Math.floor(100000 + Math.random() * 900000));
}

function getTransporter() {
  return nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: GMAIL_USER,
      pass: GMAIL_APP_PASSWORD.value(),
    },
  });
}

exports.sendVerificationCode = onCall(
    {secrets: [GMAIL_APP_PASSWORD]},
    async (request) => {
      const auth = request.auth;
      if (!auth) {
        throw new HttpsError("unauthenticated", "Connecte-toi d'abord.");
      }
      const uid = auth.uid;
      const email = auth.token.email;
      if (!email) {
        throw new HttpsError(
            "failed-precondition",
            "Aucun email associé à ce compte.",
        );
      }

      const db = admin.firestore();
      const docRef = db.collection("email_verifications").doc(uid);
      const now = Date.now();

      const existing = await docRef.get();
      if (existing.exists) {
        const lastSentAt = existing.data().lastSentAt;
        const lastSentMs = lastSentAt ? lastSentAt.toMillis() : 0;
        if (now - lastSentMs < RESEND_COOLDOWN_MS) {
          const waitSeconds = Math.ceil(
              (RESEND_COOLDOWN_MS - (now - lastSentMs)) / 1000,
          );
          throw new HttpsError(
              "resource-exhausted",
              `Patiente ${waitSeconds}s avant de redemander un code.`,
          );
        }
      }

      const code = generateCode();
      await docRef.set({
        code,
        email,
        attempts: 0,
        expiresAt: admin.firestore.Timestamp.fromMillis(now + CODE_TTL_MS),
        lastSentAt: admin.firestore.Timestamp.fromMillis(now),
      });

      const transporter = getTransporter();
      await transporter.sendMail({
        from: `"Billing App" <${GMAIL_USER}>`,
        to: email,
        subject: "Ton code de vérification",
        text:
          `Ton code de vérification est : ${code}\n\n` +
          "Il expire dans 10 minutes.",
        html:
          "<p>Ton code de vérification est :</p>" +
          `<h2 style="letter-spacing:4px">${code}</h2>` +
          "<p>Il expire dans 10 minutes.</p>",
      });

      return {success: true};
    },
);

exports.verifyEmailCode = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "Connecte-toi d'abord.");
  }
  const uid = auth.uid;
  const submittedCode =
    request.data && request.data.code ?
      String(request.data.code).trim() :
      "";
  if (!submittedCode) {
    throw new HttpsError("invalid-argument", "Code manquant.");
  }

  const db = admin.firestore();
  const docRef = db.collection("email_verifications").doc(uid);
  const snap = await docRef.get();

  if (!snap.exists) {
    throw new HttpsError(
        "failed-precondition",
        "Aucun code n'a été demandé.",
    );
  }

  const data = snap.data();
  const now = Date.now();

  if (data.expiresAt && data.expiresAt.toMillis() < now) {
    throw new HttpsError("deadline-exceeded", "Ce code a expiré.");
  }

  if ((data.attempts || 0) >= MAX_ATTEMPTS) {
    throw new HttpsError(
        "resource-exhausted",
        "Trop de tentatives, redemande un code.",
    );
  }

  if (data.code !== submittedCode) {
    await docRef.update({attempts: admin.firestore.FieldValue.increment(1)});
    throw new HttpsError("invalid-argument", "Code incorrect.");
  }

  await admin.auth().updateUser(uid, {emailVerified: true});
  await docRef.delete();

  return {success: true};
});
