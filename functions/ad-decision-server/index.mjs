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
const generateVastCreatives = ({ preference = 'default', duration = 30, fileUri = 'ads/vimond_video_services_travel_30.mp4' }) => {
    const mediaFileDeliveryType = "progressive";
    const mediaFileType = "video/mp4";
    const mediaFileHeight = "1080";
    const mediaFileWidth = "1920";
    const { VOD_SOURCE_BUCKET_CDN_DOMAIN } = process.env;

    const creativeContent =
        `<Creative>
            <Linear>
                <Duration>${duration}</Duration>
                <MediaFiles>
                    <MediaFile delivery="${mediaFileDeliveryType}" type="${mediaFileType}" width="${mediaFileWidth}" height="${mediaFileHeight}">https://${VOD_SOURCE_BUCKET_CDN_DOMAIN}/${fileUri}</MediaFile>
                </MediaFiles>
            </Linear>
        </Creative>
       `
    return creativeContent;
}

const generateAdContent = async ({ durationsInSeconds, adPreferences, availIndex }) => {
    const vastVersion = "3.0";
    const durations = durationsInSeconds.split('_').map((durationInSecond) => Number(durationInSecond));
    const preferences = adPreferences.split('_');
    const adSystem = "2.0";
    const preferIndex = Number(availIndex)-1;

    let creatives = '';
    if (durations.length >1 && preferences.length && durations.length === preferences.length) {
        const matchedFile = (await findAdFileByPreferencesAndDuration({ durationInSecond: durations[preferIndex], adPreference: preferences[preferIndex] })) ?? defaultFile;
        creatives = generateVastCreatives({ preference: preferences[preferIndex], duration: durations[preferIndex], fileUri: matchedFile });
    } else {
        creatives = generateVastCreatives({});
    }

    const xmlResponse = `
        <VAST version="${vastVersion}">
            <Ad>
                <InLine>
                    <AdSystem>${adSystem}</AdSystem>
                    <AdTitle>${adPreferences}</AdTitle>
                    <Impression/>
                    <Creatives>
                        ${creatives}
                    </Creatives>
                </InLine>
            </Ad>
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
        const vastContent = await generateAdContent({ durationsInSeconds: event.queryStringParameters.durationsInSeconds, adPreferences: event.queryStringParameters.adPreferences, availIndex: event.queryStringParameters.availIndex });
        response.body = vastContent;
    } else {
        const vastContent = await generateAdContent({ durationsInSeconds: '', adPreferences: '' });
        response.body = vastContent;
    }
    console.log('Returning', response);
    return response;
};
