#include "ApplicationLayer/ProductionLineService.hpp"
#include "ApplicationLayer/Utils.hpp"


namespace application_layer {

ProductionLineService::ProductionLineService(
    const userver::components::ComponentConfig &config,
    const userver::components::ComponentContext &component_context)
    : handlers::api::ProductionOrderServiceBase::Component(config,
                                                           component_context),
      postgres_(infrastructure_layer::PgService(component_context)) {}

void ProductionLineService::LoadOrder(
    handlers::api::ProductionOrderServiceBase::LoadOrderCall &call,
    handlers::api::LoadOrderRequest &&request) {

  std::vector<dto::OrderItem> order_item_list = GetOrderItemList(request);

  postgres_.loadItems(order_item_list);

  domain_layer::Order order;
  order.distributionProductionLines(order_item_list, postgres_.getProductionLineList());
  
  try {
    handlers::api::LoadOrderResponse response;
    postgres_.loadOrder(order, order_item_list);
    response.set_order_id(order.getId());
    response.set_total_cost(std::to_string(order.getTotalCost()));
    call.Finish(response);
  } catch (...) {
    call.FinishWithError(grpc::Status::CANCELLED);
  }
}

void ProductionLineService::GetProductionCalendar(
    handlers::api::ProductionOrderServiceBase::GetProductionCalendarCall &call,
    handlers::api::GetProductionCalendarRequest &&request) {
  int64_t production_line_id = request.production_line_id();
  auto production_calendar = postgres_.getProductionCalendar(production_line_id);

  handlers::api::GetProductionCalendarResponse response;
  for (const auto &it : production_calendar) {
    auto production_line_order = response.add_calendar_list();
    production_line_order->set_item_id(it.item_id);
    production_line_order->set_order_id(it.order_id);
    production_line_order->set_production_line_id(it.production_line_id);
    production_line_order->mutable_from()->CopyFrom(ConvertTimePointToTimestamp(it.from));
    production_line_order->mutable_to()->CopyFrom(ConvertTimePointToTimestamp(it.to));
  }

  call.Finish(response);
}

std::vector<dto::OrderItem>
ProductionLineService::GetOrderItemList(handlers::api::LoadOrderRequest &request) {
  std::vector<dto::OrderItem> order_item_list;
  auto order_list_proto = request.order_item_list();

  for (const auto &it : order_list_proto) {
    dto::OrderItem order;
    auto item_proto = it.item();

    order.count = it.count();
    order.item = {item_proto.id(), item_proto.name(), item_proto.time_cost()};

    order_item_list.push_back(order);
  }

  return order_item_list;
}

} // namespace application_layer
