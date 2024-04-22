import { MediaConvertClient, GetJobTemplateCommand, CreateJobCommand } from "@aws-sdk/client-mediaconvert";
import { generateEsamScript } from './esam_maker.mjs';

export const handler = async (event) => {
    const { MEDIA_CONVERT_ENDPOINT, MEDIA_CONVERT_JOB_TEMPLATE_NAME, MEDIA_CONVERT_ROLE_ARN, VOD_SOURCE_BUCKET, SOURCE_UPLOAD_FOLDER } = process.env;
    const eventBody = JSON.parse(event.body);
    const destinationFolder = `outputs/${eventBody.contentId}`
    console.log(JSON.stringify(eventBody, null, 2));

    const client = new MediaConvertClient({
        endpoint: MEDIA_CONVERT_ENDPOINT,
    });
    const getJobTemplateInput = {
        Name: MEDIA_CONVERT_JOB_TEMPLATE_NAME,
    };
    const getJobTemplateCommand = new GetJobTemplateCommand(getJobTemplateInput);
    const jobTemplateResponse = await client.send(getJobTemplateCommand);
    const jobTemplate = jobTemplateResponse.JobTemplate;
    const jobSettings = {
        ...jobTemplate.Settings
    };

    const Inputs = jobTemplate.Settings.Inputs.map((input, index) => ({ ...input, FileInput: `s3://${VOD_SOURCE_BUCKET}/${SOURCE_UPLOAD_FOLDER}/${eventBody.contentId}` }));
    jobSettings.Inputs = Inputs;

    const generatedEsamMarker = generateEsamScript({adBreaks: eventBody.adBreaks });

    if (generatedEsamMarker.manifestConfirmConditionNotificationContent?.length && generatedEsamMarker.signalProcessingNotificationContent?.length) {
        jobSettings.Esam = {
            ManifestConfirmConditionNotification: { MccXml: generatedEsamMarker.manifestConfirmConditionNotificationContent },
            SignalProcessingNotification: { SccXml: generatedEsamMarker.signalProcessingNotificationContent },
            ResponseSignalPreroll: 4000
        };
    };
    if (eventBody.contentId.length) {
        const outputGroups = jobSettings.OutputGroups.map((outputGroup) => ({
            ...outputGroup,
            OutputGroupSettings: {
                ...outputGroup.OutputGroupSettings,
                HlsGroupSettings: {
                    ...outputGroup.OutputGroupSettings.HlsGroupSettings,
                    Destination: `s3://${VOD_SOURCE_BUCKET}/${destinationFolder}/hls/`
                }
            }
        }));
        jobSettings.OutputGroups = outputGroups
    }
    const jobInput = {
        Role: MEDIA_CONVERT_ROLE_ARN,
        Queue: jobTemplate.Queue,
        BillingTagsSource: 'JOB',
        Priority: jobTemplate.Priority,
        AccelerationSettings: jobTemplate.AccelerationSettings,
        HopDestinations: jobTemplate.HopDestinations,
        Settings: jobSettings,
        StatusUpdateInterval: "SECONDS_60"
    };
    const createJobCommand = new CreateJobCommand(jobInput);
    const createJobResponse = await client.send(createJobCommand);
    return createJobResponse;
};


/*
contentId:""
videoSourceLocation: []
manifestConfirmConditionNotificationContent
signalProcessingNotificationContent

*/
