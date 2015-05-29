web
===

Includes a directory with the skeleton of a [Track Hub](https://genome.ucsc.edu/goldenPath/help/hgTrackHubHelp.html#Intro), for inclusion in building a Docker image with httpd to serve the track hub.

Since Docker can only build with files that are in the same directory as the `Dockerfile`, this directory will be copied and merged with the `Dockerfile` and the `.bw` file.
