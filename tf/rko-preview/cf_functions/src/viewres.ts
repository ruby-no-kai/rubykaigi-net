export function handler(
  event: AWSCloudFrontFunction.Event,
): AWSCloudFrontFunction.Response {
  const { response } = event;
  const host = event.request.headers["host"]?.value || "";

  const contentType = response.headers?.["content-type"]?.value || "";
  const metaLocation = response.headers?.["x-amz-meta-rko-location"]?.value;
  if (contentType === "application/x.rko-preview-redirector" && metaLocation) {
    response.statusCode = 302;
    response.statusDescription = "Found";
    response.headers ??= {};
    response.headers.location = {
      value: host ? `https://${host}${metaLocation}` : metaLocation,
    };
  }

  return response;
}
