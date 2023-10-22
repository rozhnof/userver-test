#pragma once

#include <string>
#include <string_view>

#include <ProductionLine_client.usrv.pb.hpp>
#include <ProductionLine_service.usrv.pb.hpp>

#include <userver/components/component.hpp>
#include <userver/components/component_list.hpp>
#include <userver/components/loggable_component_base.hpp>
#include <userver/ugrpc/client/client_factory_component.hpp>
#include <userver/yaml_config/merge_schemas.hpp>

#include "DomainLayer/DTO.hpp"
#include "DomainLayer/Order.hpp"
#include "InfrastructureLayer/PgService.hpp"

namespace application_layer {

class ProductionLineService final: public handlers::api::ProductionOrderServiceBase::Component {
public:
  static constexpr std::string_view kName = "handler-production-line";

  ProductionLineService(const userver::components::ComponentConfig &config,
                        const userver::components::ComponentContext &component_context);

  void LoadOrder(handlers::api::ProductionOrderServiceBase::LoadOrderCall &call,
                 handlers::api::LoadOrderRequest &&request) override;

  void GetProductionCalendar(handlers::api::ProductionOrderServiceBase::GetProductionCalendarCall&call,
      handlers::api::GetProductionCalendarRequest &&request) override;

private:
  infrastructure_layer::PgService postgres_;
  std::vector<dto::OrderItem> GetOrderItemList(handlers::api::LoadOrderRequest &request);
};

} // namespace application_layer
