# Youtube-to-Webpage

Youtube-to-Webpage is a Perl script to create a webpage from a Youtube video with a transcript generated from the video's closed captions paired with screenshots of the video.

```./yt-to-webpage.pl project-name "videoURL"```

## Dependencies

The project is built upon:

* [yt-dlp](https://github.com/yt-dlp/yt-dlp)
* [ffmpeg](https://ffmpeg.org/)

## Using

To use, run the Perl script with a name for the folder to create, and the video URL. For example:

```./yt-to-webpage.pl project-name "https://www.youtube.com/watch?v=jNQXAC9IVRw"```

## Output

Running the script creates a folder according to the following structure:

```
project-name
├── images
│   └── (…).jpg
├── video.*.vtt
├── video (downloaded media file)
├── index.html
├── styles.css
└── viewer.js
```

* The index.html file is the generated webpage.
* The images directory contains full-resolution screenshots from the downloaded video, saved as high-quality JPEGs and named according to their timeframe ```hours-minutes-seconds-milliseconds.jpg```.
* The vtt file contains the captions.
* The downloaded media file contains the video; its extension depends on the format selected by yt-dlp.
* The CSS file styles the webpage, and viewer.js adds numbered images, Previous and Next buttons, Left and Right Arrow key navigation, and browser speech for the active caption. Moving to another image stops the previous caption immediately.

## Example

You can see an example at https://obra.github.io/Youtube2Webpage/example/
