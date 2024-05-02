import React from 'react';
import './VideoPortal.css';
import { useState, useEffect } from 'react';
import VideoPlayer from './VideoPlayer';
import { Link } from 'react-router-dom';


const VideoPortal = ({ onVideoClick }) => {
    const [playbackUrl, setPlaybackUrl] = useState("");
    const [videos, setVideos] = useState([]);
    const contentCuratorLambdaUrl = "https://y5gls2sog2wcwy6ev76mabxv340yqisz.lambda-url.eu-north-1.on.aws";
    const playbackBaseUrl = "https://d1uvm016ude8zr.cloudfront.net";
    const adFreeBaseUrl = "https://djztwzqnm27yi.cloudfront.net";
    const [hoveredIndex, setHoveredIndex] = useState();

    useEffect(() => {
        loadContent();
    }, []);

    const loadContent = async () => {
        const contentBody = {
            contentType: 'Movies',
            action: 'getItem'
        }
        try {
            const response = await fetch(`${contentCuratorLambdaUrl}`, {
                method: "POST",
                body: JSON.stringify(contentBody),
                headers: {
                    'Content-Type': 'application/json',
                }
            });
            const data = await response.json();
            const contentsFromDB = data?.Items;
            console.log(contentsFromDB);
            setVideos(contentsFromDB);

        } catch (error) {
            return console.log(error);
        }
    }

    const openVideoPopup = (content) => {
        const manifestUrl = `${playbackBaseUrl}/outputs/${content.contentId}/hls/${content.contentId}.m3u8`;
        if (content.adBreaks?.length) {
            const customizedAdBreaks = content.adBreaks.map((adBreak) => ({
                ...adBreak,
                adPreference: adBreak.adPreference.startsWith('http') ? `uri*${adBreak.adPreference}` : adBreak.adPreference
              }));
            const playerVariables = `ads.durationsInSeconds=${customizedAdBreaks.map((ad) => ad.durationInSecond).join('_')}&ads.adPreferences=${customizedAdBreaks.map((ad) => ad.adPreference).join('_')}`;
            setPlaybackUrl(`${manifestUrl}?${playerVariables}`);
        } else {
            setPlaybackUrl(manifestUrl);
        }
    };

    const closeVideoPopup = () => {
        setPlaybackUrl('');
    };
    return (
        <div className={`container}`}>

            <div className="content-preview">
                <div className="preview-image">
                    {videos.length && (
                        <>
                            <img src={videos[0].thumbnail} alt={videos[0].contentTitle} />
                            <div className="preview-info">
                                <h2 className="preview-title">{videos[0].contentTitle.toUpperCase()}</h2>
                                <p className="preview-description">{videos[0].contentDescription}</p>
                                <button className="watch-now-button" onClick={() => openVideoPopup(videos[0])}>Watch Now</button>
                            </div>
                        </>

                    )}
                    <Link to="/content-creator">
                        <button className="create-content-button">Create Your Content</button>
                    </Link>
                </div>
            </div>
            <div className="playlist-overlay">
                <div className="playlist">
                    <div className="playlist-item">
                        <h2 className="playlist-title">Your Playlist</h2>
                        <div className="video-list">
                            {videos.map((video, index) => (
                                <div className="video-item" key={index} onMouseEnter={() => setHoveredIndex(index)} onMouseLeave={() => setHoveredIndex(-999)} >

                                    <img src={video.thumbnail} alt={video.title} className="video-thumbnail" onClick={() => openVideoPopup(video)} />
                                    {hoveredIndex === index && (
                                        <button className="watch-now-button-sm" onClick={() => setPlaybackUrl(`${adFreeBaseUrl}/outputs/${video.contentId}/hls/${video.contentId}.m3u8`)}>Play as Ad Free</button>
                                    )}
                                    <div className="video-info">
                                        <h3 className="video-title">{video.contentTitle.toUpperCase()}</h3>
                                        <p className="video-description">{video.contentDescription}</p>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </div>
            {playbackUrl.length && (
                <div className="video-popup">
                    <div className="video-overlay" onClick={closeVideoPopup}></div>
                    <div className="video-player">
                        <VideoPlayer manifestUrl={playbackUrl} />
                    </div>
                </div>
            )}
        </div>
    );
};

export default VideoPortal;


//aws mediatailor tag-resource --resource-arn arn:aws:mediatailor:eu-central-1:786994645791:playbackConfiguration/simple-elemental-vod-ads --tags team_name=simple_elemental | cat

//https://djztwzqnm27yi.cloudfront.net/ads/cmProductsAd.mp4