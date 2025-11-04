# rko-preview

Infrastructure for hosting PR previews of the rubykaigi.org website on S3 and CloudFront.

## What it does

- **Custom subdomain routing via CloudFront Functions**: Uses viewer-request function to rewrite request URIs based on the Host header. PR subdomains like `pr-123.rko-preview.rubykaigi.net` get rewritten to `/pr-123/...` paths in S3. This enables a single S3 bucket and CloudFront distribution to serve multiple PR previews with isolated URL namespaces.

- **S3 metadata-based redirects**: Implements a custom redirector via viewer-response function that converts S3 objects with content-type `application/x.rko-preview-redirector` and `x-amz-meta-rko-location` metadata into HTTP 302 redirects. This allows storing redirect rules as S3 objects but without enabling (neglected and insecure) S3 static website hosting.

- **Deploy via GitHub Actions**: Provides IAM role (`GhaRkoPreview`) for GitHub Actions workflows to upload PR preview builds to the S3 bucket. See also [rubykaigi.org//.github/workflows/preview.yml](https://github.com/ruby-no-kai/rubykaigi.org/blob/master/.github/workflows/preview.yml).

## CloudFront Functions

The custom routing logic is implemented in TypeScript CloudFront Functions located in [`cf_functions/src/`](./cf_functions/src/):

- [`viewreq.ts`](./cf_functions/src/viewreq.ts) - Viewer-request function that rewrites URIs based on subdomain
- [`viewres.ts`](./cf_functions/src/viewres.ts) - Viewer-response function that handles metadata-based redirects
