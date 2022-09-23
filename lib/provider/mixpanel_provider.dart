import 'package:flutter/material.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import '../constants/api_constants.dart';

class MixpanelProvider with ChangeNotifier {
  late Mixpanel mixpanel;

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(mixpanelKey,
        optOutTrackingDefault: false, trackAutomaticEvents: true);
    notifyListeners();
  }
}
