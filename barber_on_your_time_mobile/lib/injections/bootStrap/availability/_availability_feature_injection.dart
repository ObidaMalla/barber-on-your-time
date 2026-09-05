import 'package:barber_on_your_time/injections/bootStrap/availability/request_availability_injection.dart';

import 'add_availability_injection.dart';
import 'deletion_availability_injection.dart';
import 'get_availability_injection.dart';

void initAvailabilityFeature() {
  initGetItGetAvailability();
  initGetItAddAvailability();
  initGetItRequestAvailability();
  initGetItDeletionAvailability();
}
