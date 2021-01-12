import 'package:get/state_manager.dart';

enum DataStatus { none, loading, loaded, error }

class PurePlayerDataStatus {
  Rx<DataStatus> status = DataStatus.none.obs;

  bool get none => status.value == DataStatus.none;
  bool get loading => status.value == DataStatus.loading;
  bool get loaded => status.value == DataStatus.loaded;
  bool get error => status.value == DataStatus.error;
}
