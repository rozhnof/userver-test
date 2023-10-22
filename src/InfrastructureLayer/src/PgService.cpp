#include "InfrastructureLayer/PgService.hpp"
#include <userver/storages/postgres/component.hpp>
#include <userver/storages/postgres/exceptions.hpp>
#include <userver/storages/postgres/transaction.hpp>
#include <iostream>

namespace infrastructure_layer {

static const userver::storages::postgres::Query insert_orders = {R"(
  INSERT INTO orders(id, start_date, end_date, total_cost) 
  VALUES ($1, $2::timestamp, $3::timestamp, $4);
)"};

static const userver::storages::postgres::Query insert_item = {R"(
  INSERT INTO item(id, name, time_cost_hour) 
  VALUES ($1, $2, $3);
)"};

static const userver::storages::postgres::Query insert_order_item = {R"(
  INSERT INTO order_item(order_id, item_id, count, production_line_id, start_date, end_date) 
  VALUES ($1, $2, $3, $4, $5::timestamp, $6::timestamp)
)"};

static const userver::storages::postgres::Query get_new_order_id = {R"(
  SELECT COALESCE(MAX(id) + 1, 1) FROM orders;
)"};

static const userver::storages::postgres::Query get_production_line_list = {R"(
  SELECT pl.id, pl.money_cost_per_hour, COALESCE(MAX(oi.end_date), '2000-1-1'::TIMESTAMP) AS end_date
  FROM production_line pl
  LEFT JOIN order_item oi ON oi.production_line_id = pl.id
  GROUP BY pl.id, pl.money_cost_per_hour
  ORDER BY pl.id;
)"};

static const userver::storages::postgres::Query get_production_calendar = {R"(
  SELECT pl.id as production_line_id, item_id, order_id, start_date, end_date
  FROM production_line pl
  JOIN order_item ON pl.id = order_item.production_line_id
  WHERE pl.id = $1;
)"};


PgService::PgService(
    const userver::components::ComponentContext &component_context)
    : pg_cluster_(
          component_context
              .FindComponent<userver::components::Postgres>("postgres-db-1")
              .GetCluster()) {
}

void PgService::loadOrder(domain_layer::Order &order, std::vector<dto::OrderItem>& order_item_list) {
  userver::storages::postgres::Transaction transaction = pg_cluster_->Begin(
      userver::storages::postgres::ClusterHostType::kMaster, {});

    order.setId(getOrderId());
    auto result = transaction.Execute(insert_orders, order.getId(), order.getStartDate(), order.getEndDate(), order.getTotalCost());

    loadOrderItems(order.getId(), order_item_list, transaction);

    transaction.Commit();
}

void PgService::loadItems(std::vector<dto::OrderItem>& order_item_list) {
  for (const auto &it : order_item_list) {
    pg_cluster_->Execute(userver::storages::postgres::ClusterHostType::kMaster, insert_item, it.item.id, it.item.name, it.item.time_cost);
  }
}

void PgService::loadOrderItems(int64_t order_id, std::vector<dto::OrderItem>& order_item_list, userver::storages::postgres::Transaction &transaction) {
  for (const auto &it : order_item_list) {
    transaction.Execute(insert_order_item, order_id, it.item.id, it.count, it.production_line.id, it.production_line.start_date, it.production_line.end_date);
  }
}

int64_t PgService::getOrderId() {
  auto result = pg_cluster_->Execute(userver::storages::postgres::ClusterHostType::kMaster, get_new_order_id);
  return result[0][0].As<int>();
}

dto::ProductionLineSet PgService::getProductionLineList() {
  auto result = pg_cluster_->Execute(userver::storages::postgres::ClusterHostType::kMaster, get_production_line_list);

  dto::ProductionLineSet production_line_list;

  for (const auto &it : result) {
    dto::ProductionLine production_line;

    production_line.id = it["id"].As<int>();
    production_line.money_cost_per_hour = it["money_cost_per_hour"].As<int>();
    production_line.end_date = it["end_date"].As<std::chrono::system_clock::time_point>();

    production_line_list.insert(production_line);
  }

  return production_line_list;
}

std::vector<dto::ProductionDuration>
PgService::getProductionCalendar(int64_t pl_id) {
  std::vector<dto::ProductionDuration> production_line_calendar;

  auto result = pg_cluster_->Execute(
      userver::storages::postgres::ClusterHostType::kMaster,
      get_production_calendar, pl_id);

  for (const auto &it : result) {
    dto::ProductionDuration production_line_order;

    production_line_order.production_line_id = it["production_line_id"].As<int>();
    production_line_order.item_id = it["item_id"].As<int>();
    production_line_order.order_id = it["order_id"].As<int>();
    production_line_order.from = it["start_date"].As<std::chrono::system_clock::time_point>();
    production_line_order.to = it["end_date"].As<std::chrono::system_clock::time_point>();

    production_line_calendar.push_back(production_line_order);
  }

  return production_line_calendar;
}

} // namespace infrastructure_layer
