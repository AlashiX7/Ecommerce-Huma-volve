/// Set this to the verified Firebase Hosting origin after Hosting is configured.
const String? productLinksHostingBaseUrl = 'https://firstflutterproject-35ff3.web.app';

Uri? buildProductShareUri(int productId, {String? hostingBaseUrl}) {
  if (productId <= 0 ||
      hostingBaseUrl == null ||
      hostingBaseUrl.trim().isEmpty) {
    return null;
  }

  final baseUri = Uri.tryParse(hostingBaseUrl.trim());
  if (baseUri == null || baseUri.scheme != 'https' || baseUri.host.isEmpty) {
    return null;
  }

  final basePath = baseUri.path.endsWith('/')
      ? baseUri.path.substring(0, baseUri.path.length - 1)
      : baseUri.path;
  return baseUri.replace(
    path: '$basePath/products/$productId',
    query: null,
    fragment: null,
  );
}
