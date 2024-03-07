import { S3Client, CreateMultipartUploadCommand, CompleteMultipartUploadCommand, UploadPartCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
const chunkSize = 5 * 1024 * 1024;

export const handler = async (event) => {
    const region = process.env.AWS_REGION;
    const bucket = process.env.VOD_SOURCE_BUCKET;
    const folder = 'junayed/plays';
    const client = new S3Client({ region });
    const stage = event.queryStringParameters?.stage;
    console.log(JSON.stringify(event, null, 2))

    if (stage === 'initial') {
        const fileSizeInput = Number(event.queryStringParameters?.fileSizeInByte);
        const fileName = event.queryStringParameters?.fileName;
        if (fileName && (!isNaN(fileSizeInput) && fileSizeInput > chunkSize)) {
            const key = `${folder}/${fileName}`;
            const command = new CreateMultipartUploadCommand({
                Bucket: bucket,
                Key: key,
            });
            const createMultiPartResponse = await client.send(command);
            const numberOfParts = Math.ceil(fileSizeInput / chunkSize);

            const expiresIn = 3600;
            const signedUrls = [];

            const multipartParams = {
                Bucket: bucket,
                Key: createMultiPartResponse.Key,
                UploadId: createMultiPartResponse.UploadId,
            }
            for (let index = 0; index < numberOfParts; index++) {
                const PartNumber = index + 1;
                const command = new UploadPartCommand({
                    ...multipartParams,
                    PartNumber,
                });
                const signedUrl = await getSignedUrl(client, command, { expiresIn });
                signedUrls.push({
                    signedUrl,
                    PartNumber,
                });
            }
            return {
                statusCode: 200,
                body: {
                    uploadId: createMultiPartResponse.UploadId,
                    key: createMultiPartResponse.Key,
                    chunkSize,
                    signedUrls
                }
            };
        }
    }
    else if (event.requestContext.http.method === "POST") {
        const eventBody = JSON.parse(event.body);
        if ((eventBody.fileKey && eventBody.uploadId && eventBody.parts) && eventBody.stage === "complete") {
            const multipartParams = {
                Bucket: bucket,
                Key: eventBody.fileKey,
                UploadId: eventBody.uploadId,
                MultipartUpload: {
                    Parts: eventBody.parts
                },
            }
            const command = new CompleteMultipartUploadCommand(multipartParams);
            await client.send(command);
            return {
                statusCode: 200,
                body: {
                    completed: true
                }
            };

        }
    }
};