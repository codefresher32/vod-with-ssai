import { useState, useRef } from 'react';
import { ToastContainer, toast } from 'react-toastify';
import VideoPlayer from './VideoPlayer';
import 'react-toastify/dist/ReactToastify.css';
import './ContentCreator.css';
import { Link } from 'react-router-dom';

const ContentCreator = () => {
  const toastId = useRef(null);
  const [file, setFile] = useState();
  const [adBreaks, setAdBreaks] = useState([]);
  const [playbackUrl, setPlaybackUrl] = useState('');
  const [uploaded, setUploaded] = useState(false);
  const adPreferences = ['craftsmen', 'sports','shows'];
  const contentTypes = ['Shows', 'Dramas', 'Movies'];
  const initialContent = { contentId: '', contentDescription: '', contentType: '', thumbnail: '', contentTitle: '' };
  const [content, setContent] = useState(initialContent);
  const [canUpdateContent, setCanUpdateContent] = useState(false);
  const [wantToReProcess, setWantToReProcess] = useState(false);



  const adsItem = {
    adPreference: '',
    startTimeInSecond: 0,
    durationInSecond: 10
  }
  const uploadLambdaUrl = "https://desn6cie5gaspaewu4j6x6qrga0ibone.lambda-url.eu-north-1.on.aws";
  const videoEncoderLambdaUrl = "https://bxmx66km7scktscfeu2qsfji5e0hkoqc.lambda-url.eu-north-1.on.aws";
  const playbackBaseUrl = "https://d1uvm016ude8zr.cloudfront.net";
  const contentCuratorLambdaUrl = "https://y5gls2sog2wcwy6ev76mabxv340yqisz.lambda-url.eu-north-1.on.aws";

  const loadContent = async () => {
    const contentBody = {
      contentId: content.contentId,
      contentType: 'Movies',
      action: 'getItem'
    }
    setCanUpdateContent(false);
    return fetch(`${contentCuratorLambdaUrl}`, {
      method: "POST",
      body: JSON.stringify(contentBody),
      headers: {
        'Content-Type': 'application/json',
      }
    })
      .then((response) => response.json())
      .then((data) => {
        const contentFromDB = data?.Items?.length > 0 ? data?.Items[0] : initialContent
        setContent(contentFromDB);
        setAdBreaks(contentFromDB.adBreaks);
        setCanUpdateContent(true);
      })
      .catch((error) => console.log(error));
  }


  const chunkFile = ({ chunkSize }) => {
    let startPointer = 0;
    let endPointer = file.size;
    const chunkedFile = [];

    while (startPointer < endPointer) {
      let newStartPointer = startPointer + chunkSize;
      chunkedFile.push(file.slice(startPointer, newStartPointer));
      startPointer = newStartPointer;
    }
    return chunkedFile
  }

  const getUploadIdAndFileKey = async () => {
    return fetch(`${uploadLambdaUrl}?fileName=${content.contentId}&stage=initial&fileSizeInByte=${file.size}`, {
      method: "GET",
    })
      .then((response) => response.json())
      .then((data) => {
        return data;
      })
      .catch((error) => console.log(error));
  }

  const uploadPart = async ({ filePart, signedUrl, partNumber }) => {
    console.log(`${partNumber}:${signedUrl}`)
    return fetch(`${signedUrl}`, {
      method: "PUT",
      body: filePart,
      headers: {
        'Content-Type': 'application/octet-stream',
      }
    })
      .then((data) => {
        return data;
      })
      .catch((error) => console.log(error));
  }

  const completeMultiPartUpload = async ({ fileKey, uploadId, parts }) => {
    const completeRequestBody = {
      fileKey,
      uploadId,
      stage: "complete",
      parts
    };
    return fetch(uploadLambdaUrl, {
      method: "POST",
      body: JSON.stringify(completeRequestBody),
      headers: {
        'Content-Type': 'application/json',
      }
    })
      .then((response) => response.text())
      .then((data) => {
        return data;
      })
      .catch((error) => console.log(error));
  }

  const onFileChange = (event) => {
    setUploaded(false);
    const file = event.target.files[0];
    setFile(file);
    const fileName = file.name.substring(0, file.name.lastIndexOf('.'));
    const defaultContentId = fileName.match(/[a-zA-Z0-9]+/g).join('_');
    setContent({ ...content, contentId: defaultContentId });
  }

  const startUpload = async (initialResponse) => {
    const { signedUrls, chunkSize } = initialResponse;
    const partNumber = signedUrls.length;
    const chunkedFile = chunkFile({ partNumber, chunkSize });
    const uploadedParts = [];

    for (const signedUrl of signedUrls) {
      const uploadResponse = await uploadPart({ filePart: chunkedFile[signedUrl.PartNumber - 1], signedUrl: signedUrl.signedUrl, partNumber: signedUrl.PartNumber });
      uploadedParts.push({
        PartNumber: signedUrl.PartNumber,
        ETag: uploadResponse.headers.get('ETag').replaceAll('"', ""),
      });
    }
    return uploadedParts;
  }

  const progressNotify = () => {
    toastId.current = toast.loading('Video file uploading.....');
  };

  const successNotify = () => {
    toast.dismiss(toastId.current);
    toast.success('Video file uploaded successfully!');
  };

  const uploadFile = async () => {
    progressNotify();
    const initialResponse = await getUploadIdAndFileKey();
    const uploadPartsResponse = await startUpload(initialResponse);
    const completeResponse = await completeMultiPartUpload({ fileKey: initialResponse.key, uploadId: initialResponse.uploadId, parts: uploadPartsResponse })
    setUploaded(true);
    successNotify();
    console.log(uploadPartsResponse);
    console.log(completeResponse);
  }
  const updateAdBreaks = (index, value, field) => {
    setAdBreaks([...adBreaks.slice(0, index), { ...adBreaks[index], [field]: value }, ...adBreaks.slice(index + 1)])
  }
  const startVideoProcessing = async () => {
    const payLoadForEncoder = {
      contentId: content.contentId,
      adBreaks
    }
    try {
      const response = await fetch(videoEncoderLambdaUrl, {
        method: "POST",
        body: JSON.stringify(payLoadForEncoder),
        headers: {
          'Content-Type': 'application/json',
        }
      });
      const data = await response.text();
      await saveContent(content);
    } catch (error) {
      return console.log(error);
    }
  }

  const saveContent = async (changedContent) => {
    const contentBody = {
      action: "putItem",
      contentType: changedContent.contentType,
      contentId: changedContent.contentId,
      contentDescription: changedContent.contentDescription,
      thumbnail: changedContent.thumbnail,
      contentTitle: changedContent.contentTitle,
      adBreaks,
    }
    console.log(changedContent);
    try {
      const response = await fetch(contentCuratorLambdaUrl, {
        method: "POST",
        body: JSON.stringify(contentBody),
        headers: {
          'Content-Type': 'application/json',
        }
      });
      const data = await response.text();
      return data;
    } catch (error) {
      return console.log(error);
    }
  }



  const blobImgToBase64 = (blobImg) => {
    const reader = new FileReader();
    reader.readAsDataURL(blobImg);
    return new Promise(resolve => {
      reader.onloadend = () => {
        resolve(reader.result);
      };
    });
  };

  const takeSnapshot = async () => {

    const video = document.querySelector('video');
    const { videoWidth, videoHeight } = video;
    const canvas = document.createElement('canvas');
    canvas.width = parseInt(videoWidth, 10);
    canvas.height = parseInt(videoHeight, 10);
    const ctx = canvas.getContext('2d');
    ctx.drawImage(video, 0, 0, videoWidth, videoHeight);
    const blobImg = await new Promise(resolve => {
      canvas.toBlob(resolve, 'image/jpeg');
    });
    const base64Img = await blobImgToBase64(blobImg);
    setContent({ ...content, thumbnail: base64Img });
    saveContent({ ...content, thumbnail: base64Img });
  };

  const setPlayer = () => {
    setPlaybackUrl('');
    console.log(content);
    setTimeout(() => {
      const manifestUrl = `${playbackBaseUrl}/outputs/${content.contentId}/hls/${content.contentId}.m3u8`;
      if (adBreaks.length) {
        const customizedAdBreaks = adBreaks.map((adBreak) => ({
          ...adBreak,
          adPreference: adBreak.adPreference.startsWith('http') ? `uri*${adBreak.adPreference}` : adBreak.adPreference
        }));
        const playerVariables = `ads.durationsInSeconds=${customizedAdBreaks.map((ad) => ad.durationInSecond).join('_')}&ads.adPreferences=${customizedAdBreaks.map((ad) => ad.adPreference).join('_')}`;
        setPlaybackUrl(`${manifestUrl}?${playerVariables}`);
      } else {
        setPlaybackUrl(manifestUrl);
      }

    }, 2000);
  }

  return (
    <div className="content-creator" style={{ padding: '2%' }}>
      <div>
        <Link to="/">
          <button>Go To PlayList</button>
        </Link>
      </div>
      <input type="file" onChange={(event) => onFileChange(event)}></input>
      <button onClick={() => uploadFile()} style={{ margin: '5%' }} disabled={content.contentId.length === 0} >Upload</button>
      <ToastContainer
        position="top-right"
        newestOnTop={true}
        pauseOnFocusLoss
        pauseOnHover
        hideProgressBar={false}
      />
      <div style={{ marginTop: '1%' }}>
        <label htmlFor="ContentId">Content Id: </label>
        <input type="text" style={{ marginLeft: '5.2%' }} value={content.contentId} name="contentId" onChange={(event) => { setContent({ ...content, contentId: event.target.value }); setCanUpdateContent(false) }} disabled={(uploaded || canUpdateContent === true)} />
      </div>
      <div style={{ marginTop: '1%' }}>
        <label htmlFor="ContentTitle" style={{ marginEnd: '100px' }}>Content Title: </label>
        <textarea style={{ marginLeft: '1%', width: '20%', height: '30px' }} type="text" value={content.contentTitle} name="contentTitle" onChange={(event) => setContent({ ...content, contentTitle: event.target.value })} />
      </div>
      <div style={{ marginTop: '1%' }}>
        <label htmlFor="ContentDescription" style={{ marginEnd: '100px' }}>Content Description: </label>
        <textarea style={{ marginLeft: '1%', width: '20%', height: '80px' }} type="text" value={content.contentDescription} name="contentDescription" onChange={(event) => setContent({ ...content, contentDescription: event.target.value })} />
      </div>
      <div>
        <label htmlFor="ContentType">Content Type: </label>
        <select name="contentType" id="contentType" style={{ marginLeft: '4%', marginTop: '1%', width: '10%' }} onChange={(event) => setContent({ ...content, contentType: event.target.value })} value={content.contentType}>
          {contentTypes.map((item, index) => (
            <option key={index} value={item}>{item}</option>
          ))}
        </select>
      </div>

      <hr />
      {
        adBreaks.map((adBreak, index) => {
          return (
            <div style={{ marginBottom: '1%' }} key={index}>
                <label htmlFor="adPreference">Ad Preference: </label>
                <select name="adPreference" id="adPreference" style={{ marginLeft: '4%', marginTop: '1%', width: '10%' }} onChange={(event) => updateAdBreaks(index, event.target.value, 'adPreference')} value={adBreaks[index].adPreference}>
                  {adPreferences.map((item, index) => (
                    <option key={index} value={item}>{item}</option>
                  ))}
                </select>
                or 
                <label htmlFor="adPreference"> Uri: </label>
                <input type="text" style={{ margin: '1%' }} value={adBreak.adPreference.startsWith('http') ? adBreak.adPreference : ''} name={adBreak.adPreferences} onChange={(event) => updateAdBreaks(index, event.target.value, 'adPreference')} />

              <label htmlFor="start time">Start Time: </label>
              <input type="number" style={{ margin: '1%' }} value={adBreak.startTimeInSecond} name={adBreak.startTimeInSecond} onChange={(event) => updateAdBreaks(index, +event.target.value, 'startTimeInSecond')} disabled={((canUpdateContent && wantToReProcess) || uploaded) === false} />

              <label htmlFor="duration">Duration: </label>
              <input type="number" style={{ margin: '1%' }} value={adBreak.durationInSecond} name={adBreak.durationInSecond} onChange={(event) => updateAdBreaks(index, +event.target.value, 'durationInSecond')} />

            </div>
          )
        })
      }
      <button style={{ margin: '1%' }} onClick={() => setAdBreaks([...adBreaks, adsItem])} disabled={(uploaded || canUpdateContent) === false}> Add Ad Break </button>
      <button style={{ margin: '1%' }} onClick={() => startVideoProcessing()} disabled={(uploaded || canUpdateContent) === false} > Create Content </button>
      <button style={{ margin: '1%' }} onClick={() => loadContent()} disabled={(content.contentId.length > 0 && uploaded === false) === false} > Find and Edit content</button>
      <button
        className="btn btn-danger"
        disabled={canUpdateContent === false}
        onClick={() => {
          if (window.confirm("Are you sure to reprocess?")) {
            setWantToReProcess(true)
          }
        }}
      >
        Re Process
      </button>
      <hr />

      <button disabled={(uploaded || canUpdateContent) === false} style={{ margin: '1%' }} onClick={() => setPlayer()}>Play Your Content</button>
      <p>{playbackUrl}</p>
      <VideoPlayer manifestUrl={playbackUrl} />
      <button style={{ margin: '1%' }} onClick={() => takeSnapshot()} disabled={content.contentId.length === 0 || playbackUrl.length === 0} >Take Snapshot</button>
      {content.thumbnail.length > 0 && (<img src={content.thumbnail} alt="Snapshot" />)}
    </div>
  );
}

export default ContentCreator;
