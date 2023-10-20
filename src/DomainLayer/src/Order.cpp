#include "DomainLayer/Order.hpp"
#include <iostream>
#include <set>

namespace pg_grpc_service_template {

std::multiset<ProductionLine, Order::ProductionLineCompareByDate>
    Order::production_line_list;

int64_t Order::id = 1;

Order::Order(std::vector<OrderItem> &order_item_list)
    : order_item_list(order_item_list) {
  start_date = std::chrono::system_clock::now();
  end_date = start_date;

  for (auto &it : this->order_item_list) {
    auto firstLine = production_line_list.begin();
    it.production_line = *firstLine;
    production_line_list.erase(firstLine);

    int64_t cost_item_order = it.item.time_cost * it.count;

    it.production_line.start_date = it.production_line.end_date > start_date
                                        ? it.production_line.end_date
                                        : start_date;
    it.production_line.end_date =
        it.production_line.start_date + std::chrono::hours(cost_item_order);
    total_cost += cost_item_order * it.production_line.money_cost_per_hour;

    if (it.production_line.end_date > end_date) {
      end_date = it.production_line.end_date;
    }

    production_line_list.insert(it.production_line);
  }
}

} // namespace pg_grpc_service_template