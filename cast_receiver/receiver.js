/* global cast */

const context = cast.framework.CastReceiverContext.getInstance();
const playerManager = context.getPlayerManager();

const blockedHeaders = new Set([
  'connection',
  'content-length',
  'host',
  'proxy-connection',
  'transfer-encoding',
  'upgrade',
]);

function normalizedHeaders(value) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return {};
  return Object.fromEntries(
    Object.entries(value)
      .filter(([name, headerValue]) =>
        !blockedHeaders.has(name.toLowerCase()) &&
        typeof headerValue === 'string' &&
        headerValue.length > 0,
      ),
  );
}

function requestHeaders(loadRequest) {
  return normalizedHeaders(
    loadRequest?.customData?.headers ??
      loadRequest?.media?.customData?.headers,
  );
}

function configureNetworkRequests(headers) {
  const playbackConfig = new cast.framework.PlaybackConfig();
  const applyHeaders = (requestInfo) => {
    requestInfo.headers = {...(requestInfo.headers ?? {}), ...headers};
    return requestInfo;
  };

  playbackConfig.manifestRequestHandler = applyHeaders;
  playbackConfig.segmentRequestHandler = applyHeaders;
  playbackConfig.captionsRequestHandler = applyHeaders;
  playbackConfig.licenseRequestHandler = applyHeaders;
  playerManager.setPlaybackConfig(playbackConfig);
}

playerManager.setMessageInterceptor(
  cast.framework.messages.MessageType.LOAD,
  (loadRequest) => {
    configureNetworkRequests(requestHeaders(loadRequest));
    return loadRequest;
  },
);

context.start({
  disableIdleTimeout: true,
  statusText: 'FlixQuest',
});
