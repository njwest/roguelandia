# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Roguelandia.Repo.insert!(%Roguelandia.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Roguelandia.Pawn

classes = [
  %{"active_limit" => 30, "name" => "Warrior", "hp" => 50, "strength" => 8, "attack" => "Slash", "special" => "Frenzy", "avatar_url" => "/images/rogue-warrior.png"},
  %{"active_limit" => 30, "name" => "Archer", "hp" => 50, "strength" => 8, "attack" => "Shoot", "special" => "Focus", "avatar_url" => "/images/rogue-archer.png"},
  %{"active_limit" => 30, "name" => "Cleric", "hp" => 50, "strength" => 8, "attack" => "Bash", "special" => "Healing Wind", "avatar_url" => "/images/rogue-cleric.png"},
  %{"active_limit" => 30, "name" => "Robot", "hp" => 50, "strength" => 8, "attack" => "Robopunch", "special" => "Femtosecond Laser", "avatar_url" => "/images/rogue-robot.png"}
]

Enum.each(classes, fn attrs ->
  case Pawn.create_class(attrs) do
    {:ok, _class} ->
      IO.puts("Created class: #{attrs["name"]}")
    {:error, %Ecto.Changeset{} = changeset} ->
      IO.inspect(changeset)
  end
end)
