import { useState } from 'react';


const App = () => {
  const [file, setFile] = useState();
  const lambdaUrl = "https://desn6cie5gaspaewu4j6x6qrga0ibone.lambda-url.eu-north-1.on.aws";

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
    return fetch(`${lambdaUrl}?fileName=${file.name}&stage=initial&fileSizeInByte=${file.size}`, {
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
    return fetch(lambdaUrl, {
      method: "POST",
      body: JSON.stringify(completeRequestBody),
      headers:{
        'Content-Type': 'application/json',
      }
    })
      .then((response) => response.text())
      .then((data) => {
        return data;
      })
      .catch((error) => console.log(error));
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
    console.log(uploadPartsResponse);
    console.log(completeResponse);
  }
/*
  This one is just for quick test a bucket

  const uploadSingleFileWithPutObject = async () => {
    try {
      const lambdaUrl = "";

      const response = await fetch(lambdaUrl, {
        method: "GET",
      })
        .then((response) => response.json())
        .then((data) => {
          return data;
        })
        .catch((error) => console.log(error));

      const finalResponse = await fetch(response.url, {
        method: "PUT",
        body: file,
      })
        .then((response) => response.text())
        .then((data) => {
          return data;
        })
        .catch((error) => console.log(error));
      console.log(finalResponse);

    } catch (error) {
      console.log(error);
    }
  }
*/
  return (
    <div className="App" style={{ padding: '5%' }}>
      <input type="file" onChange={(event) => setFile(event.target.files[0])}></input>
      {/* <button onClick={() => uploadSingleFileWithPutObject()} style={{ margin: '5%' }}>Upload</button> */}

      <button onClick={() => uploadFile()} style={{ margin: '5%' }}>Upload</button>
    </div>
  );
}

export default App;
