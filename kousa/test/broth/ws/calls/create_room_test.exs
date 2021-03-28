defmodule KousaTest.Broth.Ws.CreateRoomTest do
  use ExUnit.Case, async: true
  use Kousa.Support.EctoSandbox

  alias Beef.Schemas.User
  alias Beef.Users
  alias Broth.WsClient
  alias Broth.WsClientFactory
  alias Kousa.Support.Factory

  require WsClient

  setup do
    user = Factory.create(User)
    client_ws = WsClientFactory.create_client_for(user)

    {:ok, user: user, client_ws: client_ws}
  end

  describe "the websocket create_room operation" do
    test "creates a new room", t do
      user_id = t.user.id

      ref =
        WsClient.send_call(
          t.client_ws,
          "create_room",
          %{
            "name" => "foo room",
            "description" => "baz quux",
            "privacy" => "private"
          }
        )

      WsClient.assert_reply(
        ref,
        %{
          "room" => %{
            "creatorId" => ^user_id,
            "description" => "baz quux",
            "id" => room_id,
            "name" => "foo room",
            "isPrivate" => true
          }
        }
      )

      assert %{currentRoomId: ^room_id} =
        Users.get_by_id(user_id)
    end
  end
end
