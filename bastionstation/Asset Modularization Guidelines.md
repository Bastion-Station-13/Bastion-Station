# Asset Modularization Guidelines

Bastion station currently does not enforce code modularization, however, we do enforce _asset modularization._

What this means is that **any edits to sprites, sounds, or any other assets** need to be put inside the bastionstation folder in our repository. The purpose of this rule is to make merging PRs from upstream simpler and more viable for a longer period of time.

Here are the exact guidelines for sprite files:

- When creating new sprite(s), create a new file inside the bastionstation folder and add them there, and set any relevant code to point to the new file (try to put it in a sensible subfolder).
- Avoid removing existing sprite files, simply remove references to them from the code instead.
- When editing existing sprites, follow these steps:
  1.  Copy the original sprite file to the bastionstation folder - put it in the same subfolder(s) as the original sprite file. Create the subfolders if needed.
  2.  Make whatever edits you want to the copied file.
  3.  Change the relevant code for whatever you have edited to point to the new file.

The same general guidelines apply to sounds or other assets that you wish to change. Copy assets that you wish to edit and modify relevant code to point to the new asset.
