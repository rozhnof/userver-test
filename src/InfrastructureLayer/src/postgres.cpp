#include "InfrastructureLayer/postgres.hpp"
#include <userver/storages/postgres/component.hpp>
#include <userver/storages/postgres/exceptions.hpp>
#include <userver/storages/postgres/transaction.hpp>

namespace pg_grpc_service_template {

PgService::PgService(
    const userver::components::ComponentContext &component_context)
    : pg_cluster_(
          component_context
              .FindComponent<userver::components::Postgres>("postgres-db-1")
              .GetCluster()) {
  setProductionLines();
  setOrderId();
}

bool PgService::loadOrder(Order &order) {
  userver::storages::postgres::Transaction transaction = pg_cluster_->Begin(
      userver::storages::postgres::ClusterHostType::kMaster, {});

  try {
    auto result = transaction.Execute(
        "INSERT INTO orders(id, start_date, end_date, total_cost) VALUES ($1, "
        "$2, $3, $4)",
        Order::id, order.start_date, order.end_date, order.total_cost);

    loadItems(order, transaction);
    loadOrderItems(order, transaction);

    transaction.Commit();
  } catch (...) {
    return false;
  }
  return true;
}

void PgService::loadItems(
    Order &order, userver::storages::postgres::Transaction &transaction) {
  for (const auto &it : order.order_item_list) {
    transaction.Execute(R"(
        INSERT INTO item(id, name, time_cost_hour) 
        VALUES ($1, $2, $3)
      )",
                        it.item.id, it.item.name, it.item.time_cost);
  }
}

void PgService::loadOrderItems(
    Order &order, userver::storages::postgres::Transaction &transaction) {
  for (const auto &it : order.order_item_list) {
    transaction.Execute(R"(
        INSERT INTO order_item(order_id, item_id, count, production_line_id, start_date, end_date) 
        VALUES ($1, $2, $3, $4, $5::timestamp, $6::timestamp)
      )",
                        order.id, it.item.id, it.count, it.production_line.id,
                        it.production_line.start_date,
                        it.production_line.end_date);
  }
}

void PgService::setOrderId() {
  auto result = pg_cluster_->Execute(
      userver::storages::postgres::ClusterHostType::kMaster,
      "SELECT COALESCE(MAX(id) + 1, 1) FROM orders");
  Order::id = result[0][0].As<int>();
}

void PgService::setProductionLines() {
  std::string get_production_line_list_query = R"(
      SELECT pl.id, pl.money_cost_per_hour, COALESCE(MAX(oi.end_date), '2000-1-1'::TIMESTAMP) AS end_date
      FROM production_line pl
      LEFT JOIN order_item oi ON oi.production_line_id = pl.id
      GROUP BY pl.id, pl.money_cost_per_hour
      ORDER BY pl.id;
    )";
  auto result = pg_cluster_->Execute(
      userver::storages::postgres::ClusterHostType::kMaster,
      get_production_line_list_query);

  for (const auto &it : result) {
    ProductionLine production_line;

    production_line.id = it["id"].As<int>();
    production_line.money_cost_per_hour = it["money_cost_per_hour"].As<int>();
    production_line.end_date =
        it["end_date"].As<std::chrono::system_clock::time_point>();

    Order::production_line_list.insert(std::move(production_line));
  }
}

std::vector<ProductionDuration>
PgService::getProductionCalendar(int64_t pl_id) {
  std::vector<ProductionDuration> production_line_calendar;

  std::string get_production_calendar_query = R"(
    SELECT pl.id as production_line_id, item_id, order_id, start_date, end_date
    FROM production_line pl
    JOIN order_item ON pl.id = order_item.production_line_id
    WHERE pl.id = $1;
  )";

  auto result = pg_cluster_->Execute(
      userver::storages::postgres::ClusterHostType::kMaster,
      get_production_calendar_query, pl_id);

  for (const auto &it : result) {
    ProductionDuration production_line_order;

    production_line_order.production_line_id =
        it["production_line_id"].As<int>();
    production_line_order.item_id = it["item_id"].As<int>();
    production_line_order.order_id = it["order_id"].As<int>();
    production_line_order.from =
        it["start_date"].As<std::chrono::system_clock::time_point>();
    production_line_order.to =
        it["end_date"].As<std::chrono::system_clock::time_point>();

    production_line_calendar.push_back(std::move(production_line_order));
  }

  return production_line_calendar;
}

} // namespace pg_grpc_service_template
