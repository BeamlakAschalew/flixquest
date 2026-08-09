# FlixQuest Cast Receiver

This is the custom CAF Web Receiver used when a source requires request
headers for its HLS/DASH manifest, media segments, captions, or license.

## Register and deploy

1. Host this directory at a public HTTPS URL. The receiver and every media
   origin still need valid CORS responses; request handlers cannot bypass the
   browser's CORS enforcement.
2. Register a **Custom Receiver** in the Google Cast SDK Developer Console and
   point it at `index.html`.
3. Replace `CC1AD845` with the assigned receiver application ID in:
   - `android/app/src/main/AndroidManifest.xml`
4. Register test Cast devices in the developer console while the receiver is
   unpublished, then rebuild the mobile app.

The sender copies `BetterPlayerCastConfiguration.requestHeaders` into Cast
load custom data. Never put long-lived secrets there: custom data is delivered
to the receiver. Prefer short-lived signed media URLs or a controlled relay for
authenticated streams.
