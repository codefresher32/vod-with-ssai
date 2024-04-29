import React from 'react';
import './VideoPortal.css';
import { useState, useRef } from 'react';
import VideoPlayer from './VideoPlayer';

const videos = [
    {
        title: "Create profiles for kids fjgkfgjfkjg",
        description: "Send kids on adventures with their favorite characters in a space made just for them—free with your membership.",
        thumbnail: "https://images.pexels.com/photos/1072179/pexels-photo-1072179.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
        url: 'https://d1uvm016ude8zr.cloudfront.net/outputs/videoplayback/hls/videoplayback.m3u8?ads.durationsInSeconds=10_10&ads.adPreferences=sports_sports'
    },
    {
        title: "Create profiles for kidsffgfgf",
        description: "Send kids on adventures with their favorite characters in a space made just for them—free with your membership.",
        thumbnail: "https://images.pexels.com/photos/1072179/pexels-photo-1072179.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"
    },
    {
        title: "Create profiles for kids ffg fgfgf",
        description: "Send kids on adventures with their favorite characters in a space made just for them—free with your membership.",
        thumbnail: "https://images.pexels.com/photos/3183132/pexels-photo-3183132.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"
    },
    {
        title: "Create profiles for kids",
        description: "Send kids on adventures with their favorite characters in a space made just for them—free with your membership.",
        thumbnail: "https://images.pexels.com/photos/259915/pexels-photo-259915.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"
    },
    {
        title: "Create profiles for kids",
        description: "Send kids on adventures with their favorite characters in a space made just for them—free with your membership.",
        thumbnail: "https://images.pexels.com/photos/259915/pexels-photo-259915.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"
    },
    {
        title: "Create profiles for kids",
        description: "Send kids on adventures with their favorite characters in a space made just for them—free with your membership.",
        thumbnail: "https://images.pexels.com/photos/259915/pexels-photo-259915.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"
    },
    {
        title: "Create profiles for kids",
        description: "Send kids on adventures with their favorite characters in a space made just for them—free with your membership.",
        thumbnail: "https://images.pexels.com/photos/259915/pexels-photo-259915.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"
    }
]

const VideoPortal = ({ onVideoClick }) => {
    const [selectedVideo, setSelectedVideo] = useState(null);

    const openVideoPopup = (video) => {
        setSelectedVideo(video);
    };

    const closeVideoPopup = () => {
        setSelectedVideo(null);
    };
    return (
        <div className={`container}`}>
            <div className="content-preview">
                <div className="preview-image">
                    <img src={videos[0].thumbnail} alt={videos[0].title} />
                    <div className="preview-info">
                        <h2 className="preview-title">{videos[0].title}</h2>
                        <p className="preview-description">{videos[0].description}</p>
                        <button className="watch-now-button">Watch Now</button>
                    </div>
                </div>
            </div>
            <div className="playlist-overlay">
                <div className="playlist">
                    <div className="playlist-item">
                        <h2 className="playlist-title">Your Playlist</h2>
                        <div className="video-list">
                            {videos.map((video, index) => (
                                <div className="video-item" key={index} onClick={() => openVideoPopup(video)}>
                                    <img src={video.thumbnail} alt={video.title} className="video-thumbnail" />
                                    <div className="video-info">
                                        <h3 className="video-title">{video.title}</h3>
                                        <p className="video-description">{video.description}</p>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </div>
            {selectedVideo && (
                <div className="video-popup">
                    <div className="video-overlay" onClick={closeVideoPopup}></div>
                    <div className="video-player">
                        <VideoPlayer manifestUrl={selectedVideo.url} />
                    </div>
                </div>
            )}
        </div>
    );
};

export default VideoPortal;