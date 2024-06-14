# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     LiveArena.Repo.insert!(%LiveArena.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


classes = [
  %{"active_limit" => 16, "name" => "Warrior", "hp" => 50, "strength" => 8, "attack" => "Slash", "avatar_url" => "/images/rogue-warrior.png"},
  %{"active_limit" => 16, "name" => "Archer", "hp" => 55, "strength" => 6, "attack" => "Shoot", "avatar_url" => "/images/rogue-archer.png"},
  %{"active_limit" => 16, "name" => "Cleric", "hp" => 60, "strength" => 5, "attack" => "Bash", "avatar_url" => "/images/rogue-cleric.png"},
  %{"active_limit" => 16, "name" => "Robot", "hp" => 45, "strength" => 10, "attack" => "Torque", "avatar_url" => "/images/rogue-robot.png"}
]

Enum.each(classes, fn attrs ->
  case LiveArena.Pawn.Class.create_class(attrs) do
    {:ok, _class} ->
      IO.puts("Created class: #{attrs["name"]}")
    {:error, %Ecto.Changeset{} = changeset} ->
      IO.inspect(changeset)
  end
end)
