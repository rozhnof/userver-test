#pragma once

#include <string>
#include <string_view>

#include "DomainLayer/DTO.hpp"
#include "DomainLayer/Order.hpp"
#include <userver/components/component.hpp>
#include <userver/components/component_list.hpp>
#include <userver/utils/datetime/date.hpp>

#include <userver/storages/postgres/cluster.hpp>
#include <userver/storages/postgres/component.hpp>
#include <userver/storages/postgres/exceptions.hpp>
#include <userver/storages/postgres/transaction.hpp>

namespace infrastructure_layer {

class PgService {
public:
  PgService(const userver::components::ComponentContext &component_context);

  void loadOrder(domain_layer::Order &order, std::vector<dto::OrderItem>& order_item_list);
  void loadItems(std::vector<dto::OrderItem> &order_item_list);
  void loadOrderItems(int64_t order_id, std::vector<dto::OrderItem>& order_item_list, userver::storages::postgres::Transaction &transaction);
  int64_t getOrderId();
  dto::ProductionLineSet getProductionLineList();
  std::vector<dto::ProductionDuration> getProductionCalendar(int64_t pl_id);

private:
  userver::storages::postgres::ClusterPtr pg_cluster_;
};

} // namespace infrastructure_layer
