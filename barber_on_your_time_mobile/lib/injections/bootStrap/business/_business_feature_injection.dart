import 'business_get_all_staff_injection.dart';
import 'business_injection.dart';
import 'delete_staff_injection.dart';
import 'getAllBusinesses.dart';
import 'init_get_it_staff_by_business_id.dart';
import 'join_business_injection.dart';
import 'staff_invite_injection.dart';

void initBusinessFeature() {
  initGetItBusiness();
  initGetItStaffInvite();
  initGetItJoinBusiness();
  initGetItGetStaff();
  initGetItDeleteStaff();
  initGetItGetAllBusinesses();
  initGetItGetStaffByBusinessId();
}
