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
#include "InfrastructureLayer/postgres.hpp"
#include <google/protobuf/timestamp.pb.h>

namespace pg_grpc_service_template {

class ProductionLineService final
    : public handlers::api::ProductionOrderServiceBase::Component {
public:
  static constexpr std::string_view kName = "handler-order";

  ProductionLineService(
      const userver::components::ComponentConfig &config,
      const userver::components::ComponentContext &component_context);

  void LoadOrder(handlers::api::ProductionOrderServiceBase::LoadOrderCall &call,
                 handlers::api::LoadOrderRequest &&request) override;

  void GetProductionCalendar(
      handlers::api::ProductionOrderServiceBase::GetProductionCalendarCall
          &call,
      handlers::api::GetProductionCalendarRequest &&request) override;

private:
  PgService postgres_;

  google::protobuf::Timestamp *ConvertTimePointToTimestamp(
      const std::chrono::system_clock::time_point &time_point);

  std::vector<OrderItem> getOrderList(handlers::api::LoadOrderRequest &request);
};

} // namespace pg_grpc_service_template
