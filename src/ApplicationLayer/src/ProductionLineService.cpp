#include "ApplicationLayer/ProductionLineService.hpp"

namespace pg_grpc_service_template {

ProductionLineService::ProductionLineService(
    const userver::components::ComponentConfig &config,
    const userver::components::ComponentContext &component_context)
    : handlers::api::ProductionOrderServiceBase::Component(config,
                                                           component_context),
      postgres_(PgService(component_context)) {}

void ProductionLineService::LoadOrder(
    handlers::api::ProductionOrderServiceBase::LoadOrderCall &call,
    handlers::api::LoadOrderRequest &&request) {

  std::vector<OrderItem> order_item_list = GetOrderList(request);
  handlers::api::LoadOrderResponse response;

  Order order(order_item_list);
  if (postgres_.loadOrder(order)) {
    response.set_order_id(order.id);
    response.set_total_cost(std::move(std::to_string(order.total_cost)));
    ++Order::id;
    call.Finish(response);
  } else {
    call.FinishWithError(grpc::Status::CANCELLED);
  }
}

void ProductionLineService::GetProductionCalendar(
    handlers::api::ProductionOrderServiceBase::GetProductionCalendarCall &call,
    handlers::api::GetProductionCalendarRequest &&request) {
  int64_t production_line_id = request.production_line_id();
  auto production_calendar =
      postgres_.getProductionCalendar(production_line_id);

  handlers::api::GetProductionCalendarResponse response;
  for (const auto &it : production_calendar) {
    auto production_line_order = response.add_calendar_list();
    production_line_order->set_item_id(it.item_id);
    production_line_order->set_order_id(it.order_id);
    production_line_order->set_production_line_id(it.production_line_id);
    production_line_order->set_allocated_from(
        ConvertTimePointToTimestamp(it.from));
    production_line_order->set_allocated_to(ConvertTimePointToTimestamp(it.to));
  }

  call.Finish(response);
}

google::protobuf::Timestamp *ProductionLineService::ConvertTimePointToTimestamp(
    const std::chrono::system_clock::time_point &time_point) {
  google::protobuf::Timestamp *timestamp = new google::protobuf::Timestamp;

  auto duration = time_point.time_since_epoch();
  auto seconds = std::chrono::duration_cast<std::chrono::seconds>(duration);
  auto nanoseconds =
      std::chrono::duration_cast<std::chrono::nanoseconds>(duration - seconds);

  timestamp->set_seconds(seconds.count());
  timestamp->set_nanos(nanoseconds.count());

  return timestamp;
}

std::vector<OrderItem>
ProductionLineService::GetOrderList(handlers::api::LoadOrderRequest &request) {
  std::vector<OrderItem> order_item_list;
  auto order_list_proto = request.order_item_list();

  for (const auto &it : order_list_proto) {
    OrderItem order;
    auto item_proto = it.item();

    order.count = it.count();
    order.item = {item_proto.id(), item_proto.name(), item_proto.time_cost()};

    order_item_list.push_back(std::move(order));
  }

  return order_item_list;
}

} // namespace pg_grpc_service_template
