# Deploy Petit Monde to Netlify

This is a static site. In Netlify, choose **Add new site → Deploy manually** and upload this project folder. For a Git-connected site, set the publish directory to `.` and leave the build command empty; `netlify.toml` already sets the publish directory.

All 29 MP4 files are in `videos/`, and the app's video library uses that folder.

## Video size note

The folder is about 0.82 GB, and one video is about 145 MB. Netlify recommends keeping deploys under 50 MB and says files over 10 MB may fail to upload or serve reliably. Uploading this complete folder directly may therefore take a long time or fail. For dependable sharing, host the MP4s on a video service and replace the corresponding `videos/...` paths in `app.js` with their public video URLs, or reduce the video files before deploying. Keep the smaller static app files in the Netlify publish directory.

After deployment, open the Netlify URL on a phone or computer and check the video library. Anyone with the site link can visit it.
