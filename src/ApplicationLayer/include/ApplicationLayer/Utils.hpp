#pragma once

#include <google/protobuf/timestamp.pb.h>
#include <chrono>

google::protobuf::Timestamp ConvertTimePointToTimestamp(const std::chrono::system_clock::time_point &time_point);
