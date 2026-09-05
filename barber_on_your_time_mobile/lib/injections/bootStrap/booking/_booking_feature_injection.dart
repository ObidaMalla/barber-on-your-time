import 'package:barber_on_your_time/injections/bootStrap/booking/respond_booking_injection.dart';

import 'cancel_booking_injection.dart';
import 'create_booking_injection.dart';
import 'get_my_bookings_injection.dart';
import 'get_staff_bookings_injection.dart';

void initBookingFeature() {
  initGetItCreateBooking();
  initGetItGetStaffBookings();
  initGetItRespondBooking();
  initGetItGetMyBookings();
  initGetItCancelBooking();
}
