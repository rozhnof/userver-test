#include "DomainLayer/Order.hpp"
#include <iostream>
#include <set>
#include "DomainLayer/Utils.hpp"

namespace domain_layer {

Order::Order() {}

void Order::distributionProductionLines(std::vector<dto::OrderItem> &order_item_list, dto::ProductionLineSet &&production_line_set) {
  start_date = std::chrono::system_clock::now();
  end_date = start_date;

  for (auto &it : order_item_list) {
    auto firstLine = production_line_set.begin();
    it.production_line = *firstLine;
    production_line_set.erase(firstLine);

    int64_t hour_cost_item_order = it.item.time_cost * it.count;
    it.production_line.start_date = it.production_line.end_date > start_date ? it.production_line.end_date : start_date;

    auto start_work_day = changeTime(it.production_line.start_date, 0, 0, 0);
    if (it.production_line.start_date >= changeTime(it.production_line.start_date, 0, 0, 0) && 
            it.production_line.start_date < start_work_day) {
        it.production_line.start_date = start_work_day;
    }
    
    int64_t number_of_days = hour_cost_item_order / 12;
    it.production_line.end_date = it.production_line.start_date + std::chrono::days(number_of_days);
    it.production_line.end_date += std::chrono::hours(hour_cost_item_order % 12);

    if (it.production_line.end_date >= changeTime(it.production_line.end_date, 0, 0, 0) && 
            it.production_line.end_date < changeTime(it.production_line.end_date, 12, 0, 0)) {
        it.production_line.end_date = changeTime(it.production_line.end_date, 12);
    }
    total_cost_ += hour_cost_item_order * it.production_line.money_cost_per_hour;

    if (it.production_line.end_date > end_date) {
      end_date = it.production_line.end_date;
    }

    production_line_set.insert(it.production_line);
  }
}

int64_t Order::getId() const {
    return id_;
}

int64_t Order::getTotalCost() const {
    return total_cost_;
}

std::chrono::system_clock::time_point Order::getStartDate() const {
    return start_date;
}

std::chrono::system_clock::time_point Order::getEndDate() const {
    return end_date;
}

void Order::setId(int64_t id) {
    id_ = id;
}

void Order::setTotalCost(int64_t totalCost) {
    total_cost_ = totalCost;
}

void Order::setStartDate(std::chrono::system_clock::time_point startDate) {
    start_date = startDate;
}

void Order::setEndDate(std::chrono::system_clock::time_point endDate) {
    end_date = endDate;
}


} // namespace domain_layer