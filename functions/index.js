import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions";
import admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

export const onClientNcrCreated = onDocumentCreated("clientNcr/{ncrId}", async (event) => {
    try {
        const ncrData = event.data?.data();

        if (!ncrData) {
            logger.error("No data found in the created document");
            return null;
        }

        const { accountId, siteId, areaTitle } = ncrData;

        const usersSnapshot = await db
            .collection("users")
            .where("accountId", "==", accountId)
            .where("siteIds", "array-contains", siteId)
            .where("role", "==", "siteManager")
            .where("status", "==", "active")
            .get();

        if (usersSnapshot.empty) {
            logger.info("No active site managers found for this NCR");
            return { success: true, managersNotified: 0 };
        }

        const batch = db.batch();
        const siteSnapshot = await db.collection("sites").doc(siteId).get();
        const siteName = siteSnapshot.exists ? siteSnapshot.data()?.title : "Unknown Site";

        const userIds = usersSnapshot.docs.map((doc) => doc.id);

        //Create notifications for the site managers
        usersSnapshot.docs.forEach((doc) => {
            const notificationRef = db.collection("notifications").doc();
            batch.set(notificationRef, {
                userId: doc.id,
                title: "New NCR Created",
                message: `A new NCR has been created for ${areaTitle || ""} in ${siteName}`,
                eventId: event.params.ncrId,
                createdAt: new Date(),
                read: false,
                type: "clientNcr",
                accountId,
                siteId,
            });
        });

        //Update the ncr responsibleIds
        const ncrRef = db.collection("clientNcr").doc(event.params.ncrId);
        batch.update(ncrRef, {
            responsibleIds: userIds,
        });

        await batch.commit();

        logger.info(`Successfully notified ${usersSnapshot.size} site managers`);
        return { success: true, managersNotified: usersSnapshot.size };
    } catch (error) {
        logger.error("Error in onClientNcrCreated:", error);
        throw error;
    }
});
