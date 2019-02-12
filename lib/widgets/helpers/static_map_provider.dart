import 'package:uri/uri.dart';


class StaticMapProvider {
  final String googleMapsApiKey;
  static const int defaultZoomLevel = 4;
  static const int defaultWidth = 600;
  static const int defaultHeight = 400;

  StaticMapProvider(this.googleMapsApiKey);


  Uri getStaticUriWithMarkers(
      {int width, int height, double latitude, double longitude}) {
    return _buildUrl(latitude, longitude, null, width ?? defaultWidth,
        height ?? defaultHeight,);
  }

  Uri _buildUrl(double latitude, double longitude, int zoomLevel,
      int width, int height) {
    var finalUri = new UriBuilder()
      ..scheme = 'https'
      ..host = 'maps.googleapis.com'
      ..port = 443
      ..path = '/maps/api/staticmap';



      finalUri.queryParameters = {
        'markers': '$latitude, $longitude',
        'size': '${width ?? defaultWidth}x${height ?? defaultHeight}',
        'maptype': 'roadmap',
        'key': googleMapsApiKey,
        'center': '$latitude, $longitude'
      };


    var uri = finalUri.build();
    return uri;
  }

}
