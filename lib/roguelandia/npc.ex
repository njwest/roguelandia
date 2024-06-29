defmodule Roguelandia.NPC do
  @moduledoc """
  The NPC context.
  """

  import Ecto.Query, warn: false
  alias Roguelandia.Repo

  alias Roguelandia.NPC.Boss

  @doc """
  Returns the list of bosses.

  ## Examples

      iex> list_bosses()
      [%Boss{}, ...]

  """
  def list_bosses do
    Repo.all(Boss)
  end

  @doc """
  Gets a single boss.

  Raises `Ecto.NoResultsError` if the Boss does not exist.

  ## Examples

      iex> get_boss!(123)
      %Boss{}

      iex> get_boss!(456)
      ** (Ecto.NoResultsError)

  """
  def get_boss!(id), do: Repo.get!(Boss, id)

  @doc """
  Creates a boss.

  ## Examples

      iex> create_boss(%{field: value})
      {:ok, %Boss{}}

      iex> create_boss(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_boss(attrs \\ %{}) do
    %Boss{}
    |> Boss.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a boss.

  ## Examples

      iex> update_boss(boss, %{field: new_value})
      {:ok, %Boss{}}

      iex> update_boss(boss, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_boss(%Boss{} = boss, attrs) do
    boss
    |> Boss.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a boss.

  ## Examples

      iex> delete_boss(boss)
      {:ok, %Boss{}}

      iex> delete_boss(boss)
      {:error, %Ecto.Changeset{}}

  """
  def delete_boss(%Boss{} = boss) do
    Repo.delete(boss)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking boss changes.

  ## Examples

      iex> change_boss(boss)
      %Ecto.Changeset{data: %Boss{}}

  """
  def change_boss(%Boss{} = boss, attrs \\ %{}) do
    Boss.changeset(boss, attrs)
  end

  alias Roguelandia.NPC.Bot

  @doc """
  Returns the list of bots.

  ## Examples

      iex> list_bots()
      [%Bot{}, ...]

  """
  def list_bots do
    Repo.all(Bot)
  end

  @doc """
  Gets a single bot.

  Raises `Ecto.NoResultsError` if the Bot does not exist.

  ## Examples

      iex> get_bot!(123)
      %Bot{}

      iex> get_bot!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bot!(id), do: Repo.get!(Bot, id)

  @doc """
  Creates a bot.

  ## Examples

      iex> create_bot(%{field: value})
      {:ok, %Bot{}}

      iex> create_bot(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bot(attrs \\ %{}) do
    %Bot{}
    |> Bot.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bot.

  ## Examples

      iex> update_bot(bot, %{field: new_value})
      {:ok, %Bot{}}

      iex> update_bot(bot, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bot(%Bot{} = bot, attrs) do
    bot
    |> Bot.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a bot.

  ## Examples

      iex> delete_bot(bot)
      {:ok, %Bot{}}

      iex> delete_bot(bot)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bot(%Bot{} = bot) do
    Repo.delete(bot)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bot changes.

  ## Examples

      iex> change_bot(bot)
      %Ecto.Changeset{data: %Bot{}}

  """
  def change_bot(%Bot{} = bot, attrs \\ %{}) do
    Bot.changeset(bot, attrs)
  end
end
