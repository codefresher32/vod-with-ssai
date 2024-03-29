import { MediaConvertClient, GetJobTemplateCommand, CreateJobCommand } from "@aws-sdk/client-mediaconvert";

export const handler = async (event) => {
    const { MEDIA_CONVERT_ENDPOINT, MEDIA_CONVERT_JOB_TEMPLATE_NAME, MEDIA_CONVERT_ROLE_ARN } = process.env;
    const eventBody = JSON.parse(event.body);
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
    if (eventBody.videoSourceLocation?.length === jobTemplate.Settings.Inputs.length) {
        const Inputs = jobTemplate.Settings.Inputs.map((input, index) => ({ ...input, FileInput: eventBody.videoSourceLocation[index] }));
        jobSettings.Inputs = Inputs;
    };
    if (eventBody.manifestConfirmConditionNotificationContent?.length && eventBody.signalProcessingNotificationContent?.length) {
        jobSettings.Esam = {
            ManifestConfirmConditionNotification: { MccXml: eventBody.manifestConfirmConditionNotificationContent },
            SignalProcessingNotification: { SccXml: eventBody.signalProcessingNotificationContent },
            ResponseSignalPreroll: 4000
        };
    };
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
videoSourceLocation: []
manifestConfirmConditionNotificationContent
signalProcessingNotificationContent

*/
