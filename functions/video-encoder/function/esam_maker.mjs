const sccConstants = {
  xmlns: 'urn:cablelabs:iptvservices:esam:xsd:signal:1',
  xmlns_sig: 'urn:cablelabs:md:xsd:signaling:3.0',
  xmlns_common: 'urn:cablelabs:iptvservices:esam:xsd:common:1',
  xmlns_xsi: 'http://www.w3.org/2001/XMLSchema-instance',
  acquisitionPointIdentity: 'ESAM_SCC',
  xsi_type: 'content:MovieType',
  sig_action: 'create',
  spliceCommandType: '06',
  upidType: '9',
  segmentTypeId_for_ad: '52',
  segmentTypeId_for_video: '53',
  segmentsExpected: 1,
  batchId: 'abcd',
}
const mccConstants = {
  xmlns: 'http://www.cablelabs.com/namespaces/metadata/xsd/core/2',
  acquisitionPointIdentity: 'ESAM_MCC',
  dataPassThrough: 'true',
  spliceType: 'VOD_DAI',
  locality: 'after',
  adapt: 'true',
}

const putSccPoint = (adBreak, relativeId) => {
  const sccPoint =
    `<ResponseSignal acquisitionPointIdentity="${sccConstants.acquisitionPointIdentity}" acquisitionSignalID="${relativeId}" signalPointID="${relativeId}" action="${sccConstants.sig_action}">
        <NPTPoint nptPoint="${adBreak.startTimeInSecond}" />
        <SCTE35PointDescriptor spliceCommandType="${sccConstants.spliceCommandType}">
          <SegmentationDescriptorInfo segmentEventId="${relativeId}" segmentTypeId="${sccConstants.segmentTypeId_for_ad}" />
        </SCTE35PointDescriptor>
      </ResponseSignal>
      <ConditioningInfo acquisitionSignalIDRef="${relativeId}" startOffset="PT${adBreak.startTimeInSecond}S" duration="PT${adBreak.durationInSecond}S" />
      <ResponseSignal acquisitionPointIdentity="${sccConstants.acquisitionPointIdentity}" acquisitionSignalID="${relativeId + 1}" signalPointID="${relativeId + 1}" action="${sccConstants.sig_action}">
          <NPTPoint nptPoint="${adBreak.startTimeInSecond}" />
          <SCTE35PointDescriptor spliceCommandType="${sccConstants.spliceCommandType}">
            <SegmentationDescriptorInfo segmentEventId="${relativeId + 1}" segmentTypeId="${sccConstants.segmentTypeId_for_video}" />
          </SCTE35PointDescriptor>
      </ResponseSignal>`;
  return sccPoint;
}
const putMccPoints = (adBreak, relativeId) => {
  const conditionalDuration = 0;
  const mccPoint =
    `<ManifestResponse acquisitionPointIdentity="${mccConstants.acquisitionPointIdentity}" acquisitionSignalID="${relativeId}" duration="PT${conditionalDuration}S" dataPassThrough="${mccConstants.dataPassThrough}">
          <SegmentModify>
              <FirstSegment>
                  <Tag value="#EXT-X-CUE-OUT:${adBreak.durationInSecond}" />
              </FirstSegment>
              <LastSegment>
                  <Tag value="#EXT-X-CUE-IN" locality="${mccConstants.locality}" adapt="${mccConstants.adapt}" />
              </LastSegment>
          </SegmentModify>
    </ManifestResponse>
    <ManifestResponse acquisitionPointIdentity="${mccConstants.acquisitionPointIdentity}" acquisitionSignalID="${relativeId + 1}"></ManifestResponse>`
  return mccPoint;
}

export const generateEsamScript = ({ adBreaks }) => {
  let mccPoints = '';
  let sccPoints = '';
  let relativeId = 0;

  if (adBreaks.length) {
    adBreaks.forEach((adBreak) => {
      relativeId += 10;
      sccPoints += putSccPoint(adBreak, relativeId);
      mccPoints += putMccPoints(adBreak, relativeId);
    });
    const fullScc =
    `<SignalProcessingNotification xmlns="${sccConstants.xmlns}" xmlns:sig="${sccConstants.xmlns_sig}" xmlns:common="${sccConstants.xmlns_common}" xmlns:xsi="${sccConstants.xmlns_xsi}">
      <BatchInfo batchId="${sccConstants.batchId}">
        <Source xsi:type="${sccConstants.xsi_type}" />
      </BatchInfo>
      ${sccPoints}
</SignalProcessingNotification>
    `;

    const fullMcc =
    `<ManifestConfirmConditionNotification xmlns="${mccConstants.xmlns}">
    ${mccPoints}
</ManifestConfirmConditionNotification>`;

    return {
      manifestConfirmConditionNotificationContent: fullMcc,
      signalProcessingNotificationContent: fullScc,
    }
  }
  return {
    signalProcessingNotificationContent: '',
    manifestConfirmConditionNotificationContent: '',
  }
};