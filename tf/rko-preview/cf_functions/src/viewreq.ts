const HOST_SUFFIX = "rko-preview.rubykaigi.net";
const HOST_SUFFIX_ESCAPED = HOST_SUFFIX.replace(/\./g, "\\.");
const PR_HOST_PATTERN = new RegExp(`^pr-(\\d+)\\.${HOST_SUFFIX_ESCAPED}$`);

export function handler(
  event: AWSCloudFrontFunction.Event,
): AWSCloudFrontFunction.Request {
  const { request } = event;

  const host = request.headers["host"]?.value || "";
  const originalUri = request.uri;

  const prMatch = host.match(PR_HOST_PATTERN);
  if (prMatch) {
    const prNumber = prMatch[1];
    request.uri = `/pr-${prNumber}${originalUri}`;
  } else if (host === HOST_SUFFIX) {
    request.uri = `/apex${originalUri}`;
  } else {
    request.uri = "/four-oh-four";
  }
  return request;
}
