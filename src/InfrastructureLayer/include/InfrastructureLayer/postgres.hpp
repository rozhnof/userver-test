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

namespace pg_grpc_service_template {

class PgService {
public:
  PgService(const userver::components::ComponentContext &component_context);

  bool LoadOrder(Order &order);
  void loadItems(Order &order,
                 userver::storages::postgres::Transaction &transaction);
  void LoadOrderItems(Order &order,
                      userver::storages::postgres::Transaction &transaction);
  void setOrderId();
  void setProductionLines();
  std::vector<ProductionDuration> getProductionCalendar(int64_t pl_id);

private:
  userver::storages::postgres::ClusterPtr pg_cluster_;
};

} // namespace pg_grpc_service_template
