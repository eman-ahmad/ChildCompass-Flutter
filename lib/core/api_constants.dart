class ApiConstants {
  static const String baseUrl = "http://192.168.0.40:5000/api";
  // static const String baseUrl = "http://10.135.88.110:5000/api";




  // *********************Child EndPoints***********************************

  static const String childRegisteration = "$baseUrl/child/register";





  // *********************Parent EndPoints***********************************

  static const String parentRegister = "$baseUrl/parent/register";
  static const String emailVerification = "$baseUrl/parent/verify-email";
  static const String parentLogin = "$baseUrl/parent/login";
  static const String connectChild = "$baseUrl/parent/add-child";

}
