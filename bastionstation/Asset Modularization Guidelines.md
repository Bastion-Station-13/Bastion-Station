# Asset Modularization Guidelines

Bastion station currently does not enforce code modularization, however, we do enforce *asset modularization.*

What this means is that **any edits to sprites, sounds, or any other assets** need to be put inside the bastionstation folder in our repository. The purpose of this rule is to make merging PRs from upstream simpler and more viable for a longer period of time.

Here are the exact guidelines for sprite files:

* When creating a new sprite file, create it inside the bastionstation folder.
* Avoid removing existing sprite files, simply remove references to them from the code instead.
* When editing an existing sprite file (whether adding new sprites to it or editing existing sprites), follow these steps:
	1) Copy the original sprite files to the bastionstation folder (put them in a sensible subfolder, create new subfolder(s) if needed.)
	2) Make whatever edits you want to the copied file.
	3) Change the relevant code for what you want to edit to point to the new file.

The same general guidelines apply to sounds or other assets that you wish to change. Copy assets that you wish to edit and modify relevant code to point to the new asset.

