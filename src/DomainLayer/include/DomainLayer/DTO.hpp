#pragma once

#include <chrono>
#include <memory>
#include <stdint.h>
#include <string>
#include <vector>

namespace pg_grpc_service_template {

struct Item {
  int64_t id;
  std::string name;
  int64_t time_cost;
};

struct ProductionLine {
  int64_t id;
  int64_t money_cost_per_hour;
  std::chrono::system_clock::time_point start_date;
  std::chrono::system_clock::time_point end_date;
};

struct OrderItem {
  int64_t count;
  Item item;

  ProductionLine production_line;
};

struct ProductionDuration {
  int64_t production_line_id;
  int64_t item_id;
  int64_t order_id;
  std::chrono::system_clock::time_point from;
  std::chrono::system_clock::time_point to;
};

} // namespace pg_grpc_service_template
