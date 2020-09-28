import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';

final key = '&key=0df1e18e68604b879dfa7911971e642e';

ajax(String url, data, Function fun, {Function netError}) async {
  var dio = Dio();
  try {
    Response res = await dio.get(
      "$url$key",
      // data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
        },
      ),
    );
    fun(res.data);
  } on DioError catch (e) {
    print(e);
    if (netError != null) {
      netError(e);
    }
    if (e.response != null) {
    } else {}
  }
}

checkNetWork() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    return false;
  } else {
    return true;
  }
}
