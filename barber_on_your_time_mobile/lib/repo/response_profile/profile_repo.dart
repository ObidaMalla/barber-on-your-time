import '../../models/profile/profile_model.dart';
import '../../models/profile/updateDataProfile/update_profile_model.dart';
import '../../models/profile/updatePasswordProfile/update_password_model.dart';
import '../../routes/profile_route/profile.dart';
import '../apiExceptionHandler.dart';

class ProfileRepository {
  final ProfileService profileService;
  ProfileRepository(this.profileService);

  Future<ProfileModel> getProfile() {
    return ApiExceptionHandler.handle<ProfileModel>(
      () => profileService.getProfile(),
      fallbackErrorMessage: 'فشل جلب بياناتك 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }

  Future<UpdateProfileModel> updateProfile({String? name, String? email}) {
    return ApiExceptionHandler.handle<UpdateProfileModel>(
      () => profileService.updateProfile({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
      }),
      fallbackErrorMessage: 'فشل تحديث بياناتك 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }

  Future<UpdatePasswordModel> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return ApiExceptionHandler.handle<UpdatePasswordModel>(
      () => profileService.updatePassword({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
      fallbackErrorMessage: 'فشل تغيير الباسورد 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
