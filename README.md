svr-track-hub
=============

Converts annotations in BEDGraph format to [BigWig](https://genome.ucsc.edu/goldenPath/help/bigWig.html) for building a [Track Hub](https://genome.ucsc.edu/goldenPath/help/hubQuickStart.html).

Currently in development, this repo includes a Makefile that will build a track hub from bed files. The produced directory is then built into a Docker image, but can also be simply hosted on a web server.
