import React, { useEffect, useRef } from 'react';
import shaka from 'shaka-player';

const VideoPlayer =({ manifestUrl })=> {
  const videoRef = useRef(null);

  useEffect(() => {
    shaka.polyfill.installAll();
    if (shaka.Player.isBrowserSupported()) {
      const player = new shaka.Player(videoRef.current);
      player.load(manifestUrl)
        .then(() => {
          console.log('The video has been loaded.');
        })
        .catch((error) => {
          console.error('Error loading the video:', error);
        });
    } else {
      console.error('Browser not supported.');
    }
  }, [manifestUrl]);

  return (
    <div>
      <video ref={videoRef} width="640" height="360" controls autoPlay />
    </div>
  );
}

export default VideoPlayer;