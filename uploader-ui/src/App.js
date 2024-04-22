import { useState } from 'react';
import VideoPlayer from './VideoPlayer';

const App = () => {
  const [file, setFile] = useState();
  const [adBreaks, setAdBreaks] = useState([]);
  const [playbackUrl, setPlaybackUrl] = useState('');
  const [contentId, setContentId] = useState('');
  const[uploaded, setUploaded ] = useState(false);
  const adsItem = {
    adPreferences: 'sports',
    startTimeInSecond: 0,
    durationInSecond: 10
  }
  const uploadLambdaUrl = "https://desn6cie5gaspaewu4j6x6qrga0ibone.lambda-url.eu-north-1.on.aws";
  const videoEncoderLambdaUrl = "https://bxmx66km7scktscfeu2qsfji5e0hkoqc.lambda-url.eu-north-1.on.aws";
  const playbackBaseUrl = "https://simple-elemental.vod-ads.eu-north-1-dev.vmnd.tv"
  

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
    return fetch(`${uploadLambdaUrl}?fileName=${contentId}&stage=initial&fileSizeInByte=${file.size}`, {
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

  const onFileChange = (event)=>{
    setUploaded(false);
    const file = event.target.files[0];
    setFile(file);
    const defaultContentId = file.name.substring(0,file.name.lastIndexOf('.'));
    setContentId(defaultContentId);
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

  const uploadFile = async () => {
    const initialResponse = await getUploadIdAndFileKey();
    const uploadPartsResponse = await startUpload(initialResponse);
    const completeResponse = await completeMultiPartUpload({ fileKey: initialResponse.key, uploadId: initialResponse.uploadId, parts: uploadPartsResponse })
    setUploaded(true);
    console.log(uploadPartsResponse);
    console.log(completeResponse);
  }
  const updateAdBreaks = (index, value, field) => {
    setAdBreaks([...adBreaks.slice(0, index), { ...adBreaks[index], [field]: value }, ...adBreaks.slice(index + 1)])
  }
  const startVideoProcessing = () => {
    const payLoadForEncoder = {
      contentId,
      adBreaks
    }
    return fetch(videoEncoderLambdaUrl, {
      method: "POST",
      body: JSON.stringify(payLoadForEncoder),
      headers: {
        'Content-Type': 'application/json',
      }
    })
      .then((response) => response.text())
      .then((data) => {
        
        setPlaybackUrl(`${playbackBaseUrl}/outputs/${contentId}/hls/${contentId}.m3u8`);
        return data;
      })
      .catch((error) => console.log(error));

  }

  const setPlayer = ()=>{
    setPlaybackUrl('')
    const manifestUrl = `${playbackBaseUrl}/outputs/${contentId}/hls/${contentId}.m3u8`;
    if(adBreaks.length){
      const playerVariables = `ads.durationsInSeconds=${adBreaks.map((ad)=>ad.durationInSecond).join('_')}&ads.adPreferences=${adBreaks.map((ad)=>ad.adPreferences).join('_')}`;
      setPlaybackUrl(`${manifestUrl}?${playerVariables}`);
    }else{
      setPlaybackUrl(manifestUrl);
    }
  }

  return (
    <div className="App" style={{ padding: '2%' }}>
      <input type="file" onChange={(event) => onFileChange(event)}></input>
      <button onClick={() => uploadFile()} style={{ margin: '5%' }} disabled={contentId.length === 0 } >Upload</button>
      <div style={{ marginTop: '1%' }}>
        <label htmlFor="ContentId">Content Id: </label>
        <input type="text" style={{ margin: '1%' }} value={contentId} name="contentId" onChange={(event) => setContentId(event.target.value)} />
      </div>

      <hr />
      {
        adBreaks.map((adBreak, index) => {
          return (
            <div style={{ marginBottom: '1%' }} key={index}>
              <label htmlFor="adPreferences">Ad Preferences: </label>
              <input type="text" style={{ margin: '1%' }} value={adBreak.adPreferences} name={adBreak.adPreferences} onChange={(event) => updateAdBreaks(index, event.target.value, 'adPreferences')} />

              <label htmlFor="start time">Start Time: </label>
              <input type="number" style={{ margin: '1%' }} value={adBreak.startTimeInSecond} name={adBreak.startTimeInSecond} onChange={(event) => updateAdBreaks(index, +event.target.value, 'startTimeInSecond')} />

              <label htmlFor="duration">Duration: </label>
              <input type="number" style={{ margin: '1%' }} value={adBreak.durationInSecond} name={adBreak.durationInSecond} onChange={(event) => updateAdBreaks(index, +event.target.value, 'durationInSecond')} />
            </div>
          )
        })
      }
      <button ac style={{ margin: '1%' }} onClick={() => setAdBreaks([...adBreaks, adsItem])} disabled={contentId.length === 0 }> Add Ad Break </button>
      <button style={{ margin: '1%' }} onClick={() => startVideoProcessing()} disabled={uploaded === false} > Start Processing</button>
      <hr/>
      
      <button disabled={contentId.length === 0} style={{ margin: '1%' }} onClick={()=>setPlayer()}>Play Your Content</button>
      <p>{playbackUrl}</p>
      <VideoPlayer manifestUrl={playbackUrl} />
    </div>
  );
}

export default App;
