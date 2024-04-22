import { S3Client, ListObjectsV2Command } from '@aws-sdk/client-s3';


const findClosedDurationFile = ({ fileByPreferences, targetDuration }) => {
    let closestFile = null;
    let minDiff = Infinity;
    for (let filename of fileByPreferences) {
        let parts = filename.split('_');
        if (parts.length < 2) continue;

        let durationString = parts.pop();
        let duration = parseInt(durationString);
        if (isNaN(duration)) continue;

        let diff = Math.abs(duration - targetDuration);
        if (diff < minDiff) {
            minDiff = diff;
            closestFile = filename;
        }
    }
    return closestFile;

}

const findAdFileByPreferencesAndDuration = async ({ durationInSecond, adPreference }) => {
    const { VOD_SOURCE_BUCKET, AWS_REGION } = process.env;
    const s3Client = new S3Client({ region: AWS_REGION });

    const bucketParams = {
        Bucket: VOD_SOURCE_BUCKET,
        Prefix: 'ads',
    };
    try {
        const response = await s3Client.send(new ListObjectsV2Command(bucketParams));
        const allAdKeys = response.Contents.map((content) => content.Key);
        const fileKeysByPreferences = allAdKeys.filter((key) => key.includes(adPreference));
        const matchedFile = findClosedDurationFile({ targetDuration: durationInSecond, fileByPreferences: fileKeysByPreferences.length > 0 ? fileKeysByPreferences : allAdKeys });
        return matchedFile;
    } catch (err) {
        console.error('Error listing files:', err);
        return [];
    }

}
const generateVastContent = ({preference = 'default', duration=30, fileUri ='ads/vimond_travel_hd_travel_10.mp4' }) => {

    const adSystem = "2.0";
    const mediaFileDeliveryType = "progressive";
    const mediaFileType = "video/mp4";
    const mediaFileHeight = "1080";
    const mediaFileWidth = "1920";
    const { VOD_SOURCE_BUCKET_CDN_DOMAIN } = process.env;

    const vastContent =
        `<Ad>
            <InLine>
                <AdSystem>${adSystem}</AdSystem>
                <AdTitle>${preference}</AdTitle>
                <Impression/>
                <Creatives>
                    <Creative>
                        <Linear>
                            <Duration>${duration}</Duration>
                            <MediaFiles>
                                <MediaFile delivery="${mediaFileDeliveryType}" type="${mediaFileType}" width="${mediaFileWidth}" height="${mediaFileHeight}">
                                    <![CDATA[https://${VOD_SOURCE_BUCKET_CDN_DOMAIN}/${fileUri}]]>
                                </MediaFile>
                            </MediaFiles>
                        </Linear>
                    </Creative>
                </Creatives>
            </InLine>
       </Ad>`
       return vastContent;
}

const generateAdContent = async ({ durationsInSeconds, adPreferences }) => {
    const vastVersion = "3.0";
    const durations =  durationsInSeconds.split('_').map((durationInSecond)=> Number(durationInSecond));
    const preferences = adPreferences.split('_');

    let vastContent = '';
    if (durations.length && adPreferences.length && durations.length === adPreferences.length) {
        for (let index = 0; index < durations.length; index++) {
            const matchedFile = (await findAdFileByPreferencesAndDuration({ durationInSecond: durations[index], adPreference: preferences[index] })) ?? defaultFile;
            vastContent += generateVastContent({duration: durations[index], duration: durations[index], fileUri: matchedFile  });
        }
    }else{
        vastContent += generateVastContent({});
    }

    const xmlResponse = `
    <VAST version="${vastVersion}">
        ${vastContent}
    </VAST>`
    return xmlResponse;
}

export const handler = async (event) => {
    console.log(JSON.stringify(event, null, 2));
    const response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/xml',
        }
    };
    if (event.queryStringParameters.durationsInSeconds.length && event.queryStringParameters.adPreferences.length) {
        const vastContent = await generateAdContent({ durationsInSeconds: event.queryStringParameters.durationsInSeconds, adPreferences: event.queryStringParameters.adPreferences });
        response.body = vastContent;
    }else{
        const vastContent = await generateAdContent({ durationsInSeconds: '', adPreferences: '' });
        response.body = vastContent;
    }
    console.log('Returning', response);
    return response;
};
