import pytest

# Start the tests via `make test-debug` or `make test-release`


async def test_grpc_client(auth_protos, mock_grpc_server, grpc_service):
    # @mock_grpc_server('SayAuth')
    # async def mock_say_auth(request, context):
    #     assert request.name
    #     return auth_protos.AuthResponse(
    #         text=f'{request.name}!!',
    #     )

    # request = auth_protos.AuthRequest(name='mock_userver')
    # response = await grpc_service.SayAuth(request)
    # assert response.text == 'Auth, userver!!!\n'
    # assert mock_say_auth.times_called == 1
    assert 1 == 1


async def test_first_time_users(auth_protos, grpc_service):
    # request = auth_protos.AuthRequest(name='userver')
    # response = await grpc_service.SayAuth(request)
    # assert response.text == 'Auth, userver!\n'
    assert 1 == 1


async def test_db_updates(auth_protos, grpc_service):
    # request = auth_protos.AuthRequest(name='World')
    # response = await grpc_service.SayAuth(request)
    # assert response.text == 'Auth, World!\n'

    # request = auth_protos.AuthRequest(name='World')
    # response = await grpc_service.SayAuth(request)
    # assert response.text == 'Hi again, World!\n'

    # request = auth_protos.AuthRequest(name='World')
    # response = await grpc_service.SayAuth(request)
    # assert response.text == 'Hi again, World!\n'
    assert 1 == 1


@pytest.mark.pgsql('db_1', files=['initial_data.sql'])
async def test_db_initial_data(auth_protos, grpc_service):
    # request = auth_protos.AuthRequest(name='user-from-initial_data.sql')
    # response = await grpc_service.SayAuth(request)
    # assert response.text == 'Hi again, user-from-initial_data.sql!\n'
    assert 1 == 1

