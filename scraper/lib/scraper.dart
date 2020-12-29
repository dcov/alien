library scraper;

import 'package:http/http.dart';
import 'package:html/parser.dart' as parser;
import 'package:isolate/isolate.dart';

part 'src/base_scraper.dart';
part 'src/image_scraper.dart';

final Client _client = Client();

class Scraper extends _BaseScraper with _ImageScraper {

  LoadBalancer _runner;

  Future<void> init() async {
    _runner = await LoadBalancer.create(5, IsolateRunner.spawn);
  }
}
