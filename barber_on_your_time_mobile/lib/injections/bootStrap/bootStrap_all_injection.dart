// injections/bootstrap.dart
import 'package:barber_on_your_time/injections/bootStrap/profile/profile_injection.dart';
import 'package:barber_on_your_time/injections/bootStrap/services/_services_feature_injection.dart';

import 'auth/_auth_injection.dart';
import 'availability/_availability_feature_injection.dart';
import 'availability_owner/_availability_owner_feature_injection.dart';
import 'booking/_booking_feature_injection.dart';
import 'business/_business_feature_injection.dart';
import 'notifications/notifications_injection.dart';

void setupDependencies() {
  initAuthFeature();
  initGetItProfile();
  initBusinessFeature();
  initServicesFeature();
  initAvailabilityFeature();
  initAvailabilityOwnerFeature();
  initBookingFeature();
  initGetItNotifications();
}
