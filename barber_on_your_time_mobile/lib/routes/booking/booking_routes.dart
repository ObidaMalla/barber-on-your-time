import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../core/constants/api_constants.dart';
import '../../models/booking/cancelBooking/cancel_booking_model.dart';
import '../../models/booking/createBooking/create_booking_model.dart';
import '../../models/booking/getMyBookings/get_my_bookings_model.dart';
import '../../models/booking/getStaffBookings/get_staff_bookings_model.dart';
import '../../models/booking/respondBooking/respond_booking_model.dart';

part 'booking_routes.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class BookingService {
  factory BookingService(Dio dio, {String baseUrl}) = _BookingService;

  @POST('/bookings')
  Future<CreateBookingModel> createBooking(@Body() Map<String, dynamic> body);

  @GET('/bookings/staff')
  Future<GetStaffBookingsModel> getStaffBookings();

  //respond files
  @PATCH('/bookings/{bookingId}/status')
  Future<RespondBookingModel> respondToBooking(
    @Path('bookingId') int bookingId,
    @Body() Map<String, dynamic> body,
  );

  @GET('/bookings/my')
  Future<GetMyBookingsModel> getMyBookings();

  @DELETE('/bookings/{bookingId}')
  Future<CancelBookingModel> cancelBooking(@Path('bookingId') int bookingId);
}
