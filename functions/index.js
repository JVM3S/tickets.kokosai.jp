const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { PDFDocument, rgb } = require("pdf-lib");

admin.initializeApp();

exports.sendTickets = functions.https.onCall(async (data, context) => {
  console.log("Function called with data:", data);

  // Validate input
  if (!data || !Array.isArray(data.recipients) || data.recipients.length === 0) {
    console.error("No recipients array provided or array is empty!");
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing or invalid recipients array'
    );
  }

  const recipients = data.recipients;

  // Initialize counters for ticket numbers (per type)
  const counters = { 1: 1, 2: 1, 3: 1, 4: 1, 5: 1, 6: 1, 7: 1, 8: 1, 9: 1 };

  const bucket = admin.storage().bucket();

  try {
    const sendPromises = recipients.map(async (recipient) => {
      if (!recipient.email || !recipient.type || !counters[recipient.type]) {
        console.warn("Skipping invalid recipient:", recipient);
        return null;
      }

      const type = recipient.type;
      const number = counters[type]++;
      const ticketNo = `C0${type}${String(number).padStart(3, "0")}`;
      console.log(`Generating ticket ${ticketNo} for ${recipient.email}`);

      // Load template PDF
      const templatePath = `ticketData/30${type}-3.pdf`;
      let templateBuffer;
      try {
        [templateBuffer] = await bucket.file(templatePath).download();
      } catch (err) {
        console.error(`Failed to download template ${templatePath}:`, err);
        throw new functions.https.HttpsError('internal', `Template ${templatePath} not found`);
      }

      // Insert ticket number
      const pdfDoc = await PDFDocument.load(templateBuffer);
      const page = pdfDoc.getPages()[0];
      page.drawText(ticketNo, {
        x: 300,  // adjust coordinates
        y: 150,
        size: 18,
        color: rgb(0, 0, 0),
      });

      const pdfBytes = await pdfDoc.save();
      const base64Pdf = Buffer.from(pdfBytes).toString("base64");

      // Send email via Trigger Email (Firestore collection)
      await admin.firestore().collection("mail").add({
        to: recipient.email,
        message: {
          subject: "Your Ticket",
          text: `Here is your ticket: ${ticketNo}`,
          attachments: [
            {
              filename: `${ticketNo}.pdf`,
              content: base64Pdf,
              encoding: "base64",
            },
          ],
        },
      });

      return ticketNo;
    });

    const allTickets = (await Promise.all(sendPromises)).filter(Boolean);
    console.log("All tickets sent:", allTickets);

    return { success: true, count: allTickets.length, tickets: allTickets };

  } catch (err) {
    console.error("Error in sendTickets function:", err);
    throw new functions.https.HttpsError('internal', err.message || 'Unknown error');
  }
});
