#include "ApplicationLayer/Utils.hpp"


google::protobuf::Timestamp ConvertTimePointToTimestamp(const std::chrono::system_clock::time_point &time_point) {
  google::protobuf::Timestamp timestamp;

  auto duration = time_point.time_since_epoch();
  auto seconds = std::chrono::duration_cast<std::chrono::seconds>(duration);
  auto nanoseconds = std::chrono::duration_cast<std::chrono::nanoseconds>(duration - seconds);

  timestamp.set_seconds(seconds.count());
  timestamp.set_nanos(nanoseconds.count());

  return timestamp;
}