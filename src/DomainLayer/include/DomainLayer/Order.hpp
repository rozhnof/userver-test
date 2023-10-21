#pragma once

#include "DomainLayer/DTO.hpp"
#include <set>

namespace pg_grpc_service_template {

class Order {

  struct ProductionLineCompareByDate {
    bool operator()(const ProductionLine &a, const ProductionLine &b) const {
      return a.end_date < b.end_date;
    }
  };

public:
  Order(std::vector<OrderItem> &order_item_list);

  static int64_t id;
  int64_t total_cost = 0;
  std::vector<OrderItem> order_item_list;

  std::chrono::system_clock::time_point start_date;
  std::chrono::system_clock::time_point end_date;

  static std::multiset<ProductionLine, ProductionLineCompareByDate>
      production_line_list;
};

} // namespace pg_grpc_service_template