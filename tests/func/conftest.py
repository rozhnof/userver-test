import pathlib
import sys

import pytest
import grpc

from testsuite.databases.pgsql import discover

USERVER_CONFIG_HOOKS = ['_prepare_service_config']
pytest_plugins = [
    'pytest_userver.plugins.postgresql',
    'pytest_userver.plugins.grpc',
]


@pytest.fixture(scope='session')
def auth_protos():
    return grpc.protos('auth.proto')


@pytest.fixture(scope='session')
def template-services():
    return grpc.services('auth.proto')


@pytest.fixture
def grpc_service(pgsql, template-services, grpc_channel, service_client):
    return template-services.AuthenticationServiceStub(grpc_channel)

@pytest.fixture(scope='session')
def mock_grpc_auth_session(
        template-services, grpc_mockserver, create_grpc_mock,
):
    mock = create_grpc_mock(template-services.AuthenticationServiceServicer)
    template-services.add_AuthenticationServiceServicer_to_server(
        mock.servicer, grpc_mockserver,
    )
    return mock


@pytest.fixture
def mock_grpc_server(mock_grpc_auth_session):
    with mock_grpc_auth_session.mock() as mock:
        yield mock


@pytest.fixture(scope='session')
def _prepare_service_config(grpc_mockserver_endpoint):
    def patch_config(config, config_vars):
        components = config['components_manager']['components']
        # components['auth-client']['endpoint'] = grpc_mockserver_endpoint

    return patch_config

def pytest_configure(config):
    sys.path.append(str(
        pathlib.Path(__file__).parent.parent.parent / 'proto/handlers/'))


@pytest.fixture(scope='session')
def service_source_dir():
    """Path to root directory service."""
    return pathlib.Path(__file__).parent.parent.parent


@pytest.fixture(scope='session')
def initial_data_path(service_source_dir):
    """Path for find files with data"""
    return [
        service_source_dir / 'postgresql/data',
    ]


@pytest.fixture(scope='session')
def pgsql_local(service_source_dir, pgsql_local_create):
    """Create schemas databases for tests"""
    databases = discover.find_schemas(
        'template-service',
        [service_source_dir.joinpath('postgresql/schemas')],
    )
    return pgsql_local_create(list(databases.values()))
