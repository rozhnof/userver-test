#pragma once

#include "DomainLayer/DTO.hpp"
#include <set>

namespace domain_layer {

class Order {
public:
  Order();
  
  void distributionProductionLines(std::vector<dto::OrderItem> &order_item_list, dto::ProductionLineSet &&production_line_set);

  int64_t getId() const;
  int64_t getTotalCost() const;
  std::chrono::system_clock::time_point getStartDate() const;
  std::chrono::system_clock::time_point getEndDate() const;
  
  void setId(int64_t id);
  void setTotalCost(int64_t totalCost);
  void setStartDate(std::chrono::system_clock::time_point startDate);
  void setEndDate(std::chrono::system_clock::time_point endDate);

private:
  int64_t id_;
  int64_t total_cost_ = 0;
  std::chrono::system_clock::time_point start_date;
  std::chrono::system_clock::time_point end_date;
};

} // namespace domain_layer